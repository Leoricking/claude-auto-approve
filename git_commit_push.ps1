$ErrorActionPreference = "Stop"

$RepoPath = "C:\Users\Rossi\Documents\Claude\claude-auto-approve"
$CommitMessage = "docs: add setup and usage guide"

Write-Host "============================================================"
Write-Host "Claude Auto Approve - Git Commit and Push"
Write-Host "Repository: $RepoPath"
Write-Host "============================================================"

if (-not (Test-Path -LiteralPath $RepoPath)) {
    throw "Repository not found: $RepoPath"
}

Write-Host "`n[1/7] Git status"
git -C "$RepoPath" status
if ($LASTEXITCODE -ne 0) { throw "git status failed." }

Write-Host "`n[2/7] Add README.md"
git -C "$RepoPath" add "README.md"
if ($LASTEXITCODE -ne 0) { throw "git add README.md failed." }

if (Test-Path -LiteralPath (Join-Path $RepoPath "settings.json")) {
    Write-Host "`n[3/7] Add settings.json"
    git -C "$RepoPath" add "settings.json"
    if ($LASTEXITCODE -ne 0) { throw "git add settings.json failed." }
} else {
    Write-Host "`n[3/7] settings.json not found; skipping."
}

Write-Host "`n[4/7] Add git_commit_push.ps1"
git -C "$RepoPath" add "git_commit_push.ps1"
if ($LASTEXITCODE -ne 0) { throw "git add git_commit_push.ps1 failed." }

Write-Host "`n[5/7] Review staged changes"
git -C "$RepoPath" diff --cached --stat
git -C "$RepoPath" diff --cached
if ($LASTEXITCODE -ne 0) { throw "git diff --cached failed." }

Write-Host "`n[6/7] Commit"
git -C "$RepoPath" commit -m "$CommitMessage"
if ($LASTEXITCODE -ne 0) {
    Write-Host "No commit created. There may be no staged changes."
    exit $LASTEXITCODE
}

Write-Host "`n[7/7] Push"
git -C "$RepoPath" push origin main
if ($LASTEXITCODE -ne 0) { throw "git push failed." }

Write-Host "`n[Final] Git status"
git -C "$RepoPath" status
if ($LASTEXITCODE -ne 0) { throw "Final git status failed." }

Write-Host "`nCompleted successfully."
