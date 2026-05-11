# Progress — Tailscale frontend sharing setup

## 目標

讓 `/home/kevin/tutorial/future-option-rule/` 這個專案（與其他在這台 WSL 上開發的前端）
能無痛地把 dev server 分享給 tailnet 內其他 client（`laptop-pkgnbng8`、
`desktop-p44q3ni` Windows 等）查看。

WSL 本身已是 tailnet 節點：

- Tailscale IPv4: `100.104.1.39`
- MagicDNS: `desktop-p44q3ni-1.tailffb0ce.ts.net`

## 計畫 milestone

| M | 描述 | 產出 |
|---|---|---|
| M1 | 偵測 tailscale 狀態、MagicDNS 名稱 | 確認 `desktop-p44q3ni-1.tailffb0ce.ts.net` 可用 |
| M2 | 寫 `scripts/share-frontend.sh` | helper script（HTTPS serve 為首選） |
| M3 | 實測 + pivot（tailnet 未開 serve，改用 direct-IP 為主路徑） | helper 改為 url/check/serve 三組 subcommands |
| M4 | 寫 `SHARING.md` + 本 progress doc | 文件齊備 |

## 進度日誌

### M1 — 偵測環境
- `tailscale version`：1.96.4，已 logged in
- `tailscale status --json` 取得 `Self.DNSName = desktop-p44q3ni-1.tailffb0ce.ts.net.`
- `Self.CertDomains` 為空，暗示 tailnet 未開 HTTPS cert
- 系統無 ufw / 其他常見防火牆擋路

### M2 — helper 初版（commit `3c0ab56`）
- 先做 `tailscale serve` 路徑為預設（HTTPS）
- 支援 `--http` fallback、`status`、`stop` 子指令

### M3 — 實測時發現 tailnet 沒開 Serve；pivot（commit `1d59b53`）
- 跑 `tailscale serve --bg http://127.0.0.1:5173` 被回 "Serve is not enabled on your tailnet"
- 解法：admin 要在 <https://login.tailscale.com/admin> 啟用，**我無法代做**
- 主路徑改為「dev server 綁 0.0.0.0 + 直接用 Tailscale IP / MagicDNS 加 port 存取」
- 實測：用 `python -m http.server 5173 --bind 0.0.0.0` 起 server，從 `100.104.1.39:5173`
  與 `desktop-p44q3ni-1.tailffb0ce.ts.net:5173` 兩個 URL `curl` 都成功
- Helper 改成 4 個 subcommand：
  - `url <port>`：印出兩個可用 URL
  - `check <port>`：診斷 bind 是否為 0.0.0.0，錯了給修正提示
  - `serve <port>`：保留 `tailscale serve` 進階路徑（需 admin 啟用）
  - `serve-status` / `serve-stop`
- `check` 三種情境驗證過：OK / nothing listening / 127.0.0.1-only

### M4 — 文件
- `SHARING.md`：使用指南（含 9 種常見框架的 0.0.0.0 旗標表、troubleshooting、進階 serve/funnel）
- `docs/progress-tailscale-sharing.md`：本檔

## Fallback 指引

要接手或回滾：

- 最小單位是兩個檔：`scripts/share-frontend.sh` + `SHARING.md`
- 若 tailnet 之後啟用 Serve / HTTPS，不用改 helper —— `serve` subcommand 已就位
- 若要砍掉重來：`git revert <M2-commit>..<M4-commit>` 或 `rm scripts/share-frontend.sh SHARING.md docs/progress-tailscale-sharing.md`

## 已知限制 / 下一步

- HMR websocket 在某些框架（Vite + Next.js）配 MagicDNS 用會需要額外 config，
  `SHARING.md` 已列 troubleshooting。實際做專案時再針對使用框架補一次設定。
- 沒做 systemd service / 開機自動分享 —— dev server 本來就是 dev 才開的，
  常駐沒意義。
- `tailscale funnel`（公網）刻意不在 helper 內：dev server 多半沒認證，
  自動公開太危險。需要時 SHARING.md 有手動指令。
