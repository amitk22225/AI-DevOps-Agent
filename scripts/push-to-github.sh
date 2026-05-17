#!/bin/bash
# Push AgentForge output to GitHub — run from folder where you extracted the ZIP
set -e
if [ ! -d .git ]; then git init; fi
git add .
git status
git commit -m "Add infrastructure from AgentForge" || echo "Nothing to commit or commit failed"
git branch -M main
if git remote get-url origin 2>/dev/null; then git remote set-url origin https://github.com/amitk22225/AI-DevOps-Agent.git; else git remote add origin https://github.com/amitk22225/AI-DevOps-Agent.git; fi
git push -u origin main
echo "Done. Open https://github.com/amitk22225/AI-DevOps-Agent to verify files."
