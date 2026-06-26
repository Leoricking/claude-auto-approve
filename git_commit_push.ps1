param(
    [string]$CommitMessage = "feat: add reusable Claude permission template"
)

$ErrorActionPreference = "Stop"
$RepoPath = $PSScriptRoot

Write-Host "============================================================"
Write-Host "Claude Auto Approve - Git Commit and Push"
Write-Host "Repository: $RepoPath"
Write-Host "Commit: $CommitMessage"
Write-Host "============================================================"

if ([string]::IsNullOrWhiteSpace($RepoPath) -or -not (Test-Path -LiteralPath $RepoPath)) {
    throw "Unable to resolve repository path from script location."
}

if (-not (Test-Path -LiteralPath (Join-Path $RepoPath ".git"))) {
    throw "Not a Git repository: $RepoPath"
}

Write-Host "`n[1/8] Verify current branch and repository"
git -C "$RepoPath" rev-parse --show-toplevel
if ($LASTEXITCODE -ne 0) { throw "Git repository verification failed." }

git -C "$RepoPath" branch --show-current
if ($LASTEXITCODE -ne 0) { throw "Unable to read current branch." }

Write-Host "`n[2/8] Git status before staging"
git -C "$RepoPath" status
if ($LASTEXITCODE -ne 0) { throw "git status failed." }

$FilesToStage = @(
    "README.md",
    "settings.json",
    ".gitignore",
    "git_commit_push.ps1"
)

Write-Host "`n[3/8] Stage known repository files"
foreach ($File in $FilesToStage) {
    $FullPath = Join-Path $RepoPath $File
    if (Test-Path -LiteralPath $FullPath) {
        Write-Host "  Adding $File"
        git -C "$RepoPath" add -- "$File"
        if ($LASTEXITCODE -ne 0) { throw "git add failed for $File" }
    } else {
        Write-Host "  Skipping missing file: $File"
    }
}

Write-Host "`n[4/8] Review staged summary"
git -C "$RepoPath" diff --cached --stat
if ($LASTEXITCODE -ne 0) { throw "git diff --cached --stat failed." }

Write-Host "`n[5/8] Check whether staged changes exist"
git -C "$RepoPath" diff --cached --quiet
$DiffExitCode = $LASTEXITCODE

if ($DiffExitCode -eq 0) {
    Write-Host "No staged changes. Nothing to commit or push."
    git -C "$RepoPath" status
    exit 0
}

if ($DiffExitCode -ne 1) {
    throw "Unable to determine whether staged changes exist."
}

Write-Host "`n[6/8] Commit"
git -C "$RepoPath" commit -m "$CommitMessage"
if ($LASTEXITCODE -ne 0) { throw "git commit failed." }

Write-Host "`n[7/8] Push origin main"
git -C "$RepoPath" push origin main
if ($LASTEXITCODE -ne 0) { throw "git push failed." }

Write-Host "`n[8/8] Final status"
git -C "$RepoPath" status
if ($LASTEXITCODE -ne 0) { throw "Final git status failed." }

Write-Host "`nCompleted successfully."
