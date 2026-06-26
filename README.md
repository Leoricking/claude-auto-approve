# Claude Auto Approve

讓 Claude Code 在可信任的本機開發環境中，自動通過常見且安全的工具權限，避免開發流程停在：

```text
Do you want to proceed?
1. Yes
2. Yes, and don't ask again
3. No
```

本專案以 Claude Code 原生的 `permissions.allow`、`permissions.deny` 與 `defaultMode` 設定為核心，不依賴 OCR、滑鼠座標或螢幕自動點擊。

## 主要功能

- 自動允許讀取、搜尋、編輯與寫入檔案
- 自動允許 Python、pytest、Git 與常用 Shell 指令
- 自動接受 Claude Code 的檔案修改
- 可套用至單一專案或所有專案
- 明確封鎖高風險與破壞性指令
- 避免 Claude Code 因權限確認長時間等待
- 保留每個專案額外擴充專用規則的能力

## 適用環境

- Windows 10 / Windows 11
- PowerShell
- Claude Code CLI
- Git
- Python 專案、Node.js 專案及一般程式開發專案

## 檔案說明

```text
claude-auto-approve/
├─ README.md
├─ settings.json
├─ .gitignore
└─ git_commit_push.ps1
```

| 檔案 | 用途 |
|---|---|
| `settings.json` | Claude Code 全域權限設定範本 |
| `.gitignore` | 排除 `.claude/` 與本機專用設定 |
| `git_commit_push.ps1` | 從腳本所在目錄自動檢查、提交並推送本專案 |
| `README.md` | 安裝、使用與安全說明 |

## 安裝方式

### 方式一：套用至所有 Claude Code 專案

將本專案的 `settings.json` 複製到：

```text
C:\Users\<你的 Windows 帳號>\.claude\settings.json
```

xxx 的預設路徑為：

```text
C:\Users\xxx\.claude\settings.json
```

PowerShell：

```powershell
New-Item -ItemType Directory -Force "C:\Users\xxx\.claude"
Copy-Item -Force ".\settings.json" "C:\Users\xxx\.claude\settings.json"
```

重新啟動 Claude Code 後，所有專案都會載入這份全域設定。

### 方式二：只套用至單一專案

將設定檔放到目標專案：

```text
<專案路徑>\.claude\settings.local.json
```

PowerShell 範例：

```powershell
New-Item -ItemType Directory -Force "D:\code\Claude\my-project\.claude"
Copy-Item -Force ".\settings.json" "D:\code\Claude\my-project\.claude\settings.local.json"
```

## 設定優先順序

Claude Code 通常會依照下列層級套用設定：

```text
企業或系統管理政策
→ 命令列參數
→ 專案 .claude/settings.local.json
→ 專案 .claude/settings.json
→ 使用者 ~/.claude/settings.json
```

建議用途：

- 全域 `settings.json`：放通用 Python、Git、測試與搜尋規則
- 專案 `settings.local.json`：放該專案特有的 CLI 或測試命令

## 核心設定

### 自動接受檔案修改

```json
{
  "permissions": {
    "defaultMode": "acceptEdits"
  }
}
```

### 通用允許規則

範例：

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "Edit",
      "Write",
      "NotebookEdit",
      "Bash(python:*)",
      "Bash(pytest:*)",
      "Bash(git:*)",
      "Bash(ls:*)",
      "Bash(grep:*)"
    ]
  }
}
```

### 危險指令封鎖

範例：

```json
{
  "permissions": {
    "deny": [
      "Bash(git reset --hard:*)",
      "Bash(git clean:*)",
      "Bash(git push --force:*)",
      "Bash(git push -f:*)",
      "Bash(rm -rf:*)",
      "Bash(del /s:*)",
      "Bash(format:*)",
      "Bash(shutdown:*)",
      "Bash(diskpart:*)"
    ]
  }
}
```

## 使用方式

1. 安裝或複製設定檔。
2. 關閉目前的 Claude Code 工作階段。
3. 重新開啟 Claude Code。
4. 執行：

```text
/permissions
```

5. 確認全域或專案設定已載入。
6. 執行 Python、pytest、Git status 或檔案搜尋操作，確認不再反覆要求權限。

## 能解決的等待情況

此設定主要處理工具執行權限，例如：

```text
python -m pytest -q
python main.py health
git status
git diff
ls
grep
wc
```

它不會自動回答 Claude 在聊天內容中提出的需求澄清問題，例如：

```text
你要修改方案 A 還是方案 B？
是否要刪除現有資料？
請提供缺少的 API Key。
```

這些屬於對話決策，不是工具權限提示。

## 安全原則

本專案採用「常用操作自動允許、破壞性操作明確封鎖」的方式。

請注意：

- `Bash(git:*)` 允許範圍很廣
- `Bash(python:*)` 可執行任何本機 Python 程式
- 只應用於你信任的程式碼與專案
- 不要在來源不明的 Repository 直接使用寬鬆設定
- 執行提交、推送、安裝套件或刪除資料前，仍應確認 Git 狀態與變更內容
- `deny` 規則不能取代完整的備份與版本控制

## 完全略過權限提示

Claude Code 也可使用：

```powershell
claude --dangerously-skip-permissions
```

這會略過全部工具權限確認，風險高於本專案的 allow/deny 方式，只適合可信任且隔離的環境。

## 更新設定

修改全域設定後，重新複製：

```powershell
Copy-Item -Force ".\settings.json" "C:\Users\xxx\.claude\settings.json"
```

然後重新啟動 Claude Code。

## Git 提交與推送

執行：

```powershell
powershell -ExecutionPolicy Bypass -File ".\git_commit_push.ps1"
```

腳本使用 `$PSScriptRoot` 自動識別 Repository，不綁定特定電腦路徑，並依序執行：

```text
git status
git add 指定檔案
git diff --cached
git commit
git push origin main
git status
```

## Repository

```text
https://github.com/Leoricking/claude-auto-approve
```

## License

建議依實際發布方式加入 MIT License。
