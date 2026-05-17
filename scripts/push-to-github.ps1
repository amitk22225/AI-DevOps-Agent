# Push AgentForge output to GitHub — run in PowerShell from extracted ZIP folder
Set-Location $PSScriptRoot\..
if (-not (Test-Path .git)) { git init }
git add .
git status
git commit -m "Add infrastructure from AgentForge"
git branch -M main
$remote = "https://github.com/amitk22225/AI-DevOps-Agent.git"
try { git remote set-url origin $remote } catch { git remote add origin $remote }
git push -u origin main
Write-Host "Done. Check https://github.com/amitk22225/AI-DevOps-Agent"
