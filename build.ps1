# Converts a Markdown file to an N-Pulse PDF (Windows).
# Usage: .\build.ps1 docs\file.md [subteam] [title]
param(
    [Parameter(Mandatory = $true)][string]$Src,
    [string]$Subteam = "",
    [string]$Title = ""
)
$ErrorActionPreference = "Stop"

Set-Location $PSScriptRoot
$name = [IO.Path]::GetFileNameWithoutExtension($Src)
if (-not $Title) { $Title = $name }
New-Item -ItemType Directory -Force -Path output | Out-Null

# Typst expects forward slashes in paths, even on Windows.
$Src = $Src -replace '\\', '/' -replace '^\./', ''
typst compile --root . `
    --input "src=$Src" --input "subteam=$Subteam" --input "title=$Title" `
    template/main.typ "output/$name.pdf"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Created output/$name.pdf"
