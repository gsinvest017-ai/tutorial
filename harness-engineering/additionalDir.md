# 讓 Claude Code 永遠感知特定資料夾的設定步驟

## 目標
不論在哪個 cwd 開啟 Claude Code，都能自動感知並讀寫指定資料夾（以 `~/gs-zipline-tej` 為例）。

## 機制
1. **`additionalDirectories`**（`settings.json`）：授予讀寫權限，避免「超出 cwd」被擋。
2. **全域 `CLAUDE.md` + `@` 引用**：每次啟動自動載入指定檔案內容。

---

## 步驟 1：編輯 `~/.claude/settings.json`

加入 `permissions.additionalDirectories`：

```json
{
  "theme": "dark",
  "skipDangerousModePermissionPrompt": true,
  "permissions": {
    "additionalDirectories": [
      "/home/kevin/gs-zipline-tej"
    ]
  }
}
```

要加更多資料夾就在陣列追加路徑。

---

## 步驟 2：建立 `~/.claude/CLAUDE.md`

用 `@` 語法引用入口檔（每次啟動自動載入），其他檔案讓 Claude 按需讀取，避免 token 成本過高：

```markdown
# Persistent Project Awareness

## gs-zipline-tej

Path: `/home/kevin/gs-zipline-tej`
A Zipline fork integrated with TEJ (Taiwan Economic Journal) data for Taiwan-market backtesting.

Entry doc:
@/home/kevin/gs-zipline-tej/README.md

Other key files (read on demand):
- `simple_run.md` / `simple_run_zw.md` — quick-start guides (EN / 中文)
- `pyproject.toml`, `setup.py` — build config
- `zipline-tej*.yml` — conda env specs (linux/mac/generic)
- `src/` — source code
- `tests/` — test suite
- `tools/`, `dockerfile/` — utility scripts and container setup
```

---

## 驗證

重啟 Claude Code 後，在任意 cwd 試：

```
read /home/kevin/gs-zipline-tej/setup.py
```

應該不會跳權限提示，且 README 內容已自動載入背景。

---

## 維護

- **加自動載入內容**：在 `CLAUDE.md` 追加 `@/path/to/file`（注意 token 成本，建議只 @ 索引/入口檔）。
- **加可讀寫資料夾**：在 `settings.json` 的 `additionalDirectories` 追加路徑。
- **臨時擴充（不改設定檔）**：啟動時用 `claude --add-dir /some/path`。
