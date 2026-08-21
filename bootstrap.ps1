[CmdletBinding()]
param(
    [switch]$Check,
    [switch]$Apply,
    [switch]$Packages
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($Check -and $Apply) { throw 'Choose either -Check or -Apply.' }
if (-not $Check -and -not $Apply) { $Check = $true }
if ($Packages -and -not $Apply) { throw '-Packages must be combined with -Apply.' }

$RepoRoot = $PSScriptRoot
$BackupRoot = $null
$ExistingGitName = $null
$ExistingGitEmail = $null
if (Get-Command git -ErrorAction SilentlyContinue) {
    $ExistingGitName = git config --global --get user.name 2>$null
    $ExistingGitEmail = git config --global --get user.email 2>$null
}

function Write-Log([string]$Message) { Write-Host "[dotfiles] $Message" }
function Get-BackupRoot {
    if (-not $script:BackupRoot) {
        $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $script:BackupRoot = Join-Path $env:LOCALAPPDATA "dotfiles\backups\$stamp"
        New-Item -ItemType Directory -Force -Path $script:BackupRoot | Out-Null
    }
    return $script:BackupRoot
}

function Test-TargetExists([string]$Target) {
    return $null -ne (Get-Item -LiteralPath $Target -Force -ErrorAction SilentlyContinue)
}

function Backup-Target([string]$Target) {
    $root = Get-BackupRoot
    $relative = $Target.Replace(':', '').TrimStart('\', '/')
    $destination = Join-Path $root $relative
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
    Write-Log "backing up conflict: $Target"
    try {
        Move-Item -LiteralPath $Target -Destination $destination
    } catch {
        throw "Unable to move '$Target' into the backup. Close programs and shells using that path, then rerun -Apply. $($_.Exception.Message)"
    }
    Write-Log "backed up $Target -> $destination"
}

function Backup-Copy([string]$Target) {
    $root = Get-BackupRoot
    $relative = $Target.Replace(':', '').TrimStart('\', '/')
    $destination = Join-Path $root $relative
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
    Copy-Item -LiteralPath $Target -Destination $destination
    Write-Log "backed up $Target -> $destination"
}

function Test-ManagedLink([string]$Source, [string]$Target) {
    $item = Get-Item -LiteralPath $Target -Force -ErrorAction SilentlyContinue
    if (-not $item -or $item.LinkType -notin @('HardLink', 'Junction', 'SymbolicLink')) { return $false }
    $sourceFull = [IO.Path]::GetFullPath($Source).TrimEnd('\')

    # PowerShell reports no Target for hard links, so ask NTFS for every path
    # belonging to the same file and compare those paths instead.
    if ($item.LinkType -eq 'HardLink') {
        $volume = [IO.Path]::GetPathRoot($Target).TrimEnd('\')
        foreach ($hardLink in @(& fsutil hardlink list $Target 2>$null)) {
            $candidate = "$volume$hardLink"
            if ([IO.Path]::GetFullPath($candidate).TrimEnd('\') -ieq $sourceFull) { return $true }
        }
        return $false
    }

    foreach ($linkTarget in @($item.Target)) {
        if (-not $linkTarget) { continue }
        $candidate = if ([IO.Path]::IsPathRooted($linkTarget)) {
            [IO.Path]::GetFullPath($linkTarget)
        } else {
            [IO.Path]::GetFullPath((Join-Path (Split-Path -Parent $Target) $linkTarget))
        }
        if ($candidate.TrimEnd('\') -ieq $sourceFull) { return $true }
    }
    return $false
}

function Install-ManagedLink([string]$Source, [string]$Target, [switch]$Directory) {
    if (-not (Test-Path -LiteralPath $Source)) { throw "Link source does not exist: $Source" }
    if (Test-ManagedLink $Source $Target) {
        Write-Log "ok: $Target"
        return
    }
    if ($Check) {
        $action = if (Test-TargetExists $Target) { 'would back up and link' } else { 'would link' }
        Write-Log "$action`: $Target"
        return
    }
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Target) | Out-Null
    if (Test-TargetExists $Target) { Backup-Target $Target }
    if ($Directory) {
        New-Item -ItemType Junction -Path $Target -Target $Source | Out-Null
    } else {
        try {
            New-Item -ItemType HardLink -Path $Target -Target $Source | Out-Null
        } catch {
            throw "Unable to hard-link $Target. Keep the repo and profile on the same drive. $($_.Exception.Message)"
        }
    }
    Write-Log "linked $Target -> $Source"
}

function Get-LocalValue([string]$Name) {
    $path = Join-Path $RepoRoot 'local.env'
    if (-not (Test-Path -LiteralPath $path)) { return $null }
    $line = Get-Content -LiteralPath $path | Where-Object { $_ -match "^$([regex]::Escape($Name))=" } | Select-Object -Last 1
    if (-not $line) { return $null }
    return ($line -replace '^[^=]+=', '').Trim().Trim('"').Trim("'")
}

function Configure-GitIdentity {
    $target = Join-Path $HOME '.config\git\config.local'
    if (Test-Path -LiteralPath $target) {
        Write-Log "ok: $target (preserved local identity)"
        return
    }
    $name = Get-LocalValue 'DOTFILES_GIT_NAME'
    $email = Get-LocalValue 'DOTFILES_GIT_EMAIL'
    if (-not $name) { $name = $ExistingGitName }
    if (-not $email) { $email = $ExistingGitEmail }
    if (-not $name -or -not $email) {
        Write-Warning 'Git identity is unset; copy local.example.env to local.env before applying.'
        return
    }
    if ($Check) {
        Write-Log "would create untracked Git identity: $target"
        return
    }
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null
    git config --file $target user.name $name
    git config --file $target user.email $email
    Write-Log "created local Git identity: $target"
}

function Configure-CodexDefaults {
    $defaultsPath = Join-Path $RepoRoot 'config\codex\defaults.toml'
    $target = Join-Path $HOME '.codex\config.toml'
    $desired = [ordered]@{}
    foreach ($line in Get-Content -LiteralPath $defaultsPath) {
        if ($line -match '^\s*([A-Za-z0-9_.-]+)\s*=') { $desired[$Matches[1]] = $line }
    }

    $current = if (Test-Path -LiteralPath $target) { @(Get-Content -LiteralPath $target) } else { @() }
    $result = [Collections.Generic.List[string]]::new()
    $seen = @{}
    $inTable = $false
    foreach ($line in $current) {
        if (-not $inTable -and $line -match '^\s*\[') {
            $missing = @($desired.Keys | Where-Object { -not $seen.ContainsKey($_) })
            foreach ($key in $missing) { $result.Add($desired[$key]) }
            if ($missing.Count) { $result.Add('') }
            $inTable = $true
        }
        if (-not $inTable -and $line -match '^\s*([A-Za-z0-9_.-]+)\s*=' -and $desired.Contains($Matches[1])) {
            $key = $Matches[1]
            $result.Add($desired[$key])
            $seen[$key] = $true
        } else {
            $result.Add($line)
        }
    }
    if (-not $inTable) {
        foreach ($key in $desired.Keys) {
            if (-not $seen.ContainsKey($key)) { $result.Add($desired[$key]) }
        }
    }

    $candidate = ($result -join [Environment]::NewLine) + [Environment]::NewLine
    $existing = if (Test-Path -LiteralPath $target) { Get-Content -Raw -LiteralPath $target } else { $null }
    if ($existing -ceq $candidate) {
        Write-Log "ok: $target (tracked defaults present)"
        return
    }
    if ($Check) {
        Write-Log "would merge tracked defaults into: $target"
        return
    }
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null
    $targetItem = Get-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue
    if ($targetItem -and $targetItem.LinkType) {
        Backup-Target $target
    } elseif ($targetItem) {
        Backup-Copy $target
    }
    [IO.File]::WriteAllText($target, $candidate, [Text.UTF8Encoding]::new($false))
    Write-Log "merged tracked defaults into: $target"
}

function Get-ManifestLines([string]$Path) {
    Get-Content -LiteralPath $Path | ForEach-Object { ($_ -replace '\s+#.*$', '').Trim() } | Where-Object { $_ }
}

function Refresh-Path {
    $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $user = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$machine;$user"
}

function Install-Packages {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) { throw 'winget is required to install Windows packages.' }
    foreach ($id in Get-ManifestLines (Join-Path $RepoRoot 'packages\winget.txt')) {
        winget list --id $id --exact --accept-source-agreements 2>$null | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Log "winget already installed: $id"
        } else {
            Write-Log "installing winget package: $id"
            winget install --id $id --exact --silent --accept-package-agreements --accept-source-agreements
        }
    }

    Refresh-Path
    if (Get-Command rustup -ErrorAction SilentlyContinue) {
        $versions = Get-Content -Raw (Join-Path $RepoRoot 'packages\versions.env')
        $toolchain = [regex]::Match($versions, 'RUST_TOOLCHAIN="([^"]+)"').Groups[1].Value
        rustup toolchain install $toolchain --profile minimal --component rustfmt rust-analyzer
        rustup default $toolchain
    }
    if (Get-Command cargo -ErrorAction SilentlyContinue) {
        foreach ($line in Get-ManifestLines (Join-Path $RepoRoot 'packages\cargo-windows.txt')) {
            $crate, $version = $line -split '\s+', 2
            cargo install --locked --version $version $crate
        }
    }
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        foreach ($package in Get-ManifestLines (Join-Path $RepoRoot 'packages\npm.txt')) {
            npm install --global $package
        }
    }
}

Write-Log "mode: $(if ($Check) { 'check' } else { 'apply' })"
Install-ManagedLink (Join-Path $RepoRoot 'nvim') (Join-Path $env:LOCALAPPDATA 'nvim') -Directory
Install-ManagedLink (Join-Path $RepoRoot 'config\git\config') (Join-Path $HOME '.gitconfig')
Install-ManagedLink (Join-Path $RepoRoot 'config\psmux\psmux.conf') (Join-Path $HOME '.psmux.conf')
Install-ManagedLink (Join-Path $RepoRoot 'shell\Microsoft.PowerShell_profile.ps1') $PROFILE.CurrentUserCurrentHost
Install-ManagedLink (Join-Path $RepoRoot 'agents\AGENTS.md') (Join-Path $HOME '.codex\AGENTS.md')
Install-ManagedLink (Join-Path $RepoRoot 'agents\AGENTS.md') (Join-Path $HOME '.config\opencode\AGENTS.md')
Install-ManagedLink (Join-Path $RepoRoot 'config\opencode\opencode.jsonc') (Join-Path $HOME '.config\opencode\opencode.jsonc')
Install-ManagedLink (Join-Path $RepoRoot 'config\ponytail\config.json') (Join-Path $HOME '.config\ponytail\config.json')

if ($Packages) { Install-Packages }
Configure-GitIdentity
Configure-CodexDefaults
if ($BackupRoot) { Write-Log "backups retained at $BackupRoot" }
if ($Check) { Write-Log 'check complete; no changes were made' } else { Write-Log 'apply complete; restart PowerShell and psmux' }
