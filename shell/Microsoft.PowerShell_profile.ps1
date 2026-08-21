# Portable PowerShell defaults. Keep machine-specific values in an untracked profile.local.ps1.
$env:EDITOR = 'nvim'
$env:VISUAL = 'nvim'
$env:GIT_EDITOR = 'nvim'

$PSStyle.FileInfo.Directory = $PSStyle.Foreground.BrightBlue

if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine
    Set-PSReadLineOption -EditMode Windows
    if ($Host.UI.SupportsVirtualTerminal -and -not [Console]::IsOutputRedirected) {
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin -PredictionViewStyle ListView
    }
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
}

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    $ZoxideInit = & zoxide init powershell | Out-String
    Invoke-Expression $ZoxideInit
}

function dev { Set-Location (Join-Path $HOME 'dev') }
function which([string]$Name) { Get-Command $Name -ErrorAction SilentlyContinue }

$LocalProfile = Join-Path $PSScriptRoot 'profile.local.ps1'
if (Test-Path -LiteralPath $LocalProfile) {
    . $LocalProfile
}
