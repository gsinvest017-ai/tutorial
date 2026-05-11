# 把這台 WSL 的前端 dev server 分享給 Tailnet

這台 WSL 已經是 Tailscale 節點：

| 欄位 | 值 |
|---|---|
| Tailscale IPv4 | `100.104.1.39` |
| MagicDNS | `desktop-p44q3ni-1.tailffb0ce.ts.net` |

其他登入同一個 tailnet 的 client（例如 `laptop-pkgnbng8`、`desktop-p44q3ni` Windows）
都能直接用 IP 或 MagicDNS 連到這台 WSL 上跑的 dev server。

## 主路徑：直接 IP / MagicDNS（推薦）

不需要 tailnet admin 任何設定，任何 port 都能用。

### 1. 啟動 dev server 並綁 `0.0.0.0`

各框架對應旗標：

| 框架 | 指令 |
|---|---|
| Vite | `npm run dev -- --host 0.0.0.0` |
| Next.js | `next dev -H 0.0.0.0 -p 3000` |
| CRA | `HOST=0.0.0.0 npm start` |
| Nuxt 3 | `nuxt dev --host 0.0.0.0` |
| SvelteKit | `vite dev --host 0.0.0.0`（同 Vite） |
| Astro | `astro dev --host 0.0.0.0` |
| Streamlit | `streamlit run app.py --server.address 0.0.0.0` |
| FastAPI/uvicorn | `uvicorn app:app --host 0.0.0.0 --port 8000 --reload` |
| Flask | `flask run --host 0.0.0.0` 或 `app.run(host='0.0.0.0')` |
| Django | `python manage.py runserver 0.0.0.0:8000` |
| Python http.server | `python -m http.server 5173 --bind 0.0.0.0` |

> 重點：預設 `localhost` / `127.0.0.1` bind 在 Tailscale 看不到。一定要 `0.0.0.0`。

### 2. 用 helper 取得 URL 與檢查 bind

```bash
./scripts/share-frontend.sh url 5173
# Direct-IP / MagicDNS URLs (dev server must bind 0.0.0.0:5173):
#   http://100.104.1.39:5173/
#   http://desktop-p44q3ni-1.tailffb0ce.ts.net:5173/

./scripts/share-frontend.sh check 5173
# OK    listening on 0.0.0.0:5173 — reachable from Tailscale peers
```

`check` 會診斷常見錯誤（綁錯在 127.0.0.1、port 沒人聽）並提示修正。

### 3. 在其他 tailnet client 開瀏覽器

複製 `url` 印出來的網址即可。Vite/Next 等框架的 HMR websocket 走同一個 port，會跟著通。

---

## 進階路徑：`tailscale serve`（HTTPS + 短網址）

優點：自動 LE 憑證、不用記 port、`https://desktop-p44q3ni-1.tailffb0ce.ts.net` 一個網址搞定。
缺點：需要 tailnet admin 在 <https://login.tailscale.com/admin> 啟用 **HTTPS Certificates**
與 **Serve** 功能；目前這個 tailnet **未啟用**，跑 `serve` 會被擋。

啟用後：

```bash
./scripts/share-frontend.sh serve 5173        # HTTPS at :443
./scripts/share-frontend.sh serve 5173 --http # HTTP at :80（少數 HMR 場景用）
./scripts/share-frontend.sh serve-status
./scripts/share-frontend.sh serve-stop
```

---

## 對外公開（Tailnet 以外，例如要 demo 給客戶）

需要 `tailscale funnel`（也需 admin 開啟 Funnel feature）。本 repo 不預設提供，
若需要請手動：

```bash
tailscale funnel --bg 5173
tailscale funnel --https=443 off   # 用完關掉
```

Funnel 會給一個公開 `*.ts.net` HTTPS URL。**注意**：dev server 內若沒驗證，
任何拿到網址的人都能存取。

---

## Troubleshooting

| 症狀 | 原因 | 解法 |
|---|---|---|
| 同台 WSL 上 `curl http://127.0.0.1:PORT` 通，但別台連不到 | dev server 綁 127.0.0.1 | 改綁 `0.0.0.0`（見上表） |
| Vite HMR 一直斷線 | HMR websocket host 對不到 | 在 `vite.config.ts` 設 `server.hmr.host = '100.104.1.39'` |
| Next.js 連得到但 _next/webpack-hmr 失敗 | 同上 | 設 `WATCHPACK_POLLING=true` 或 `assetPrefix` |
| 連線 reset / timeout | host 防火牆擋 | `sudo ufw allow PORT/tcp` 或關掉 WSL `/etc/iptables` rule |
| `serve` 報 "Serve is not enabled" | tailnet admin 未啟用 | 改走主路徑（直接 IP），或請 admin 在網頁開啟 |

---

## 設計取捨

- **預設不開 funnel**：funnel 等於把 dev server 推上公網，多數 dev 環境沒做認證，
  外洩風險高。需要時手動觸發即可。
- **不自動修改 dev server config**：各框架旗標不一致，硬塞容易踩到既有設定。
  改成由 helper 印出旗標 + `check` 驗證 bind 是否正確，使用者自己改 npm script。
- **不裝額外服務**：不需要 nginx / caddy / cloudflared。Tailscale 本身就是 mesh VPN。
