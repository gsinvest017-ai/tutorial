# 量化策略研究 / 量化開發 Onboarding 知識庫

> 為量化策略研究員（Quantitative Strategy Researcher）與量化開發工程師（Quantitative Developer）所準備的入職培訓知識庫。
>
> 涵蓋四大主軸：**策略驗證術語**、**產業供應鏈知識**、**系統架構**、**研究／開發框架（Harness）工程**。

---

## 📖 目錄

- [學習路徑建議](#學習路徑建議)
- [知識庫結構](#知識庫結構)
- [模組一：策略驗證術語（strategy/）](#模組一策略驗證術語-strategy)
- [模組二：產業知識 — 台灣半導體供應鏈（industry/）](#模組二產業知識--台灣半導體供應鏈-industry)
- [模組三：系統架構（system-architecture/）](#模組三系統架構-system-architecture)
- [模組四：研究框架工程（harness-engineering/）](#模組四研究框架工程-harness-engineering)
- [實作環境與工具](#實作環境與工具)
- [角色職責對照](#角色職責對照)
- [學習檢核清單](#學習檢核清單)
- [延伸閱讀與資源](#延伸閱讀與資源)

---

## 學習路徑建議

依照角色不同，建議的閱讀順序：

### 🎯 量化策略研究員（Quant Researcher）

1. **第一週** — 模組一：策略驗證術語 ➜ 建立統計與績效評估語彙
2. **第二週** — 模組二：產業供應鏈 ➜ 培養基本面與標的選擇直覺
3. **第三週** — 模組三：系統架構 ➜ 了解策略從研究到上線的資料流
4. **第四週** — 模組四：研究框架 ➜ 學會使用內部回測與部署工具

### 🛠 量化開發工程師（Quant Developer）

1. **第一週** — 模組三：系統架構 ➜ 掌握整體技術棧
2. **第二週** — 模組四：研究框架 ➜ 熟悉 Harness 開發規範
3. **第三週** — 模組一：策略驗證術語 ➜ 理解研究員語言以利協作
4. **第四週** — 模組二：產業供應鏈 ➜ 補足領域知識背景

---

## 知識庫結構

```
tutorial/
├── README.md                              ← 本檔案（總覽與導讀）
├── strategy/
│   └── strategy-validation-terms.md       ← 策略驗證術語詞彙表（中英對照）
├── industry/
│   ├── semiconductor-supply-chain.md      ← 台灣半導體供應鏈關係網路（Mermaid）
│   └── semiconductor-supply-chain.html    ← 同上 HTML 渲染版
├── system-architecture/
│   └── arch.drawio                        ← 系統架構圖（draw.io 格式）
└── harness-engineering/
    └── roadmap.drawio                     ← Harness 工程藍圖（draw.io 格式）
```

---

## 模組一：策略驗證術語（`strategy/`）

📄 **檔案：** [`strategy/strategy-validation-terms.md`](./strategy/strategy-validation-terms.md)

此模組以中英雙語建立量化策略開發中**最常被混淆卻最關鍵**的術語語彙。所有研究員與開發者在進行策略討論、Code Review 與績效報告時，都應以此為共通語言。

### 核心詞彙（節錄）

| 類別 | 術語 | 中文 | 重點 |
|------|------|------|------|
| 單位與成本 | bps（Basis Points） | 基點 | 1 bp = 0.01%，交易成本與績效精確表達單位 |
| 部位管理 | Rolling Position Cost | 滾動持倉成本 | 加權平均成本，P&L 歸因基礎 |
| 驗證方法 | Walk-Forward Analysis | 滾動向前驗證 | IS / OOS 滾動切割，避免前視偏差 |
| 參數搜索 | Grid Search | 網格搜索 | 簡單但易過擬合，須搭配 OOS 驗證 |
| 樣本內統計 | IS Sharpe | 樣本內夏普 | 必要非充分條件，幾乎總是被高估 |
| 樣本外統計 | OOS Sharpe | 樣本外夏普 | 前瞻績效黃金標準；OOS / IS ≥ 0.5 為可接受 |
| 技術指標 | ADX + Wilder Criterion | 平均趨向指標 + Wilder 平滑 | 趨勢「強度」而非方向，ADX > 25 視為強趨勢 |
| 多重檢定 | Bonferroni Correction | Bonferroni 校正 | α* = α / k，控制族系誤差率 FWER |
| 統計推論 | Bootstrap Sharpe | 自助抽樣夏普 | 信賴區間 + p 值，有自相關時用 block bootstrap |
| 績效指標 | CAGR | 複合年均成長率 | 須搭配 Sharpe、Max DD、Calmar 比率併報 |

### 學習目標

- ✅ 能在策略報告中正確使用 IS / OOS、Sharpe、CAGR、Max Drawdown、Calmar 等術語
- ✅ 理解為何 Grid Search 後的 IS Sharpe 不可直接信任，並能設計合理 OOS 驗證
- ✅ 知道何時該套用 Bonferroni / Holm-Bonferroni / Benjamini-Hochberg FDR
- ✅ 能判斷 ADX > 25 等技術門檻在策略設計中的角色

---

## 模組二：產業知識 — 台灣半導體供應鏈（`industry/`）

📄 **檔案：** [`industry/semiconductor-supply-chain.md`](./industry/semiconductor-supply-chain.md)

台灣股市量化策略**無法繞開半導體產業**。此模組以 Mermaid 流程圖視覺化呈現從矽智財（IP）→ IC 設計（Fabless）→ 晶圓代工（Foundry）→ 封裝（OSAT）→ 測試（Test）的完整供應鏈與廠商關係。

### 供應鏈六大環節

```
🪨 上游原材料／基板    → 環球晶圓、欣興、景碩、南亞 PCB
💡 EDA／矽智財 IP     → 力旺、晶心、創意
🖥 IC 設計（Fabless）  → 聯發科、聯詠、瑞昱、群聯、慧榮、譜瑞、奇景、祥碩、立錡、盛群
🏭 晶圓代工（Foundry） → 台積電、聯電、世界先進、力積電、穩懋
⚙️ 整合元件（IDM）    → 華邦、南亞科、旺宏
📦 封裝（OSAT）       → 日月光（含矽品）、力成、南茂、菱生
🔍 測試（Test）       → 京元電、探微、ASE/SPIL turnkey
```

### 為何量化研究員必須懂供應鏈

1. **配對交易（Pairs Trading）標的選擇** — 同供應鏈節點的廠商（如台積電 vs. 聯電）具備天然共整合性
2. **事件驅動策略** — 上游漲價、客戶調整投片量會沿供應鏈傳導，可預期傳導順序
3. **因子建構** — 半導體景氣循環因子需結合 BB Ratio、晶圓代工稼動率、CoWoS 產能等領域知識
4. **基本面結合技術面** — 例如 HBM 主題需理解南亞科 ➜ 力成（封裝）➜ 京元電（測試）的價值鏈

### 學習目標

- ✅ 能說出台灣前 20 大半導體上市櫃公司在供應鏈中的位置
- ✅ 能解釋 CoWoS、HBM、ABF 載板等主題的受惠標的鏈
- ✅ 能設計以供應鏈關係為基礎的配對交易或籃子策略

---

## 模組三：系統架構（`system-architecture/`）

📄 **檔案：** [`system-architecture/arch.drawio`](./system-architecture/arch.drawio)
（請以 [draw.io](https://app.diagrams.net) / VS Code Draw.io 擴充套件開啟）

此圖描述策略從**研究 → 回測 → 部署 → 監控**的端到端系統架構，量化開發工程師應特別熟悉此圖。

### 涵蓋面向

- 資料層：TEJ API、Tick／Bar 資料、基本面、籌碼面
- 研究層：Jupyter / Notebook、特徵工程、模型訓練
- 回測層：Zipline-TEJ（請參考 `/home/kevin/gs-zipline-tej`）
- 執行層：訂單路由、風控、券商 API
- 監控層：績效歸因、Drawdown 告警、即時部位

### 學習目標

- ✅ 能畫出資料從券商或 TEJ 進入系統，最終落到回測引擎的完整路徑
- ✅ 能定位某個 bug 或績效異常該由哪個模組負責
- ✅ 了解 Zipline-TEJ 在整體系統中的角色（見下方「實作環境」）

---

## 模組四：研究框架工程（`harness-engineering/`）

📄 **檔案：** [`harness-engineering/roadmap.drawio`](./harness-engineering/roadmap.drawio)

Harness Engineering 指的是**支撐策略研發的工具鏈**：沙箱、權限控管、自動錯誤偵測、Telemetry 編排、Runtime 隔離等。此模組是量化開發工程師的核心領域。

### 關鍵概念（節錄自 roadmap）

- **NanoClaw Sandbox** — 策略執行的隔離沙箱
- **Finite Authorization** — 預先指定應用程式／埠口的有限授權
- **Auto Error Identify & Auto-Fix** — 自動錯誤偵測與修復
- **Telemetry Orchestration** — 遙測訊號編排
- **Cloud Service** — 雲端服務整合
- **Security / Runtime** — 安全層與執行期管理

### 學習目標

- ✅ 理解策略 Code 在沙箱中執行時的權限邊界
- ✅ 能讀懂 Telemetry 並從中診斷策略異常
- ✅ 能依 roadmap 規範擴充新工具或執行期模組

---

## 實作環境與工具

### 主要技術棧

| 元件 | 工具 | 路徑 / 連結 |
|------|------|-----------|
| 回測引擎 | **Zipline-TEJ** | `/home/kevin/gs-zipline-tej` |
| 資料來源 | TEJ API（台灣經濟新報） | <https://api.tej.com.tw> |
| Python 環境 | Conda 虛擬環境 + Python 3.9–3.12 | `zipline-tej.yml` |
| 容器化 | Docker（`tej87681088/tquant`） | Docker Hub |
| 視覺化 | Matplotlib、Plotly、Mermaid、draw.io | — |

### Zipline-TEJ 快速啟動

```bash
# 1. 建立 conda 環境
conda env create -f /home/kevin/gs-zipline-tej/zipline-tej.yml
conda activate zipline-tej

# 2. 設定環境變數
export TEJAPI_KEY=<your_key>
export TEJAPI_BASE=https://api.tej.com.tw
export ticker="2330 2317"
export mdate="20200101 20220101"

# 3. Ingest 資料並執行回測
zipline ingest -b tquant
zipline run -f buy_and_hold.py --start 20200101 --end 20220101 \
            -o bah.pickle --no-benchmark --no-treasury
```

詳細指令請參考 `/home/kevin/gs-zipline-tej/README.md` 與 `simple_run_zw.md`。

---

## 角色職責對照

| 任務 | Quant Researcher | Quant Developer |
|------|:---:|:---:|
| 提出策略假設與經濟邏輯 | ✅ 主責 | 🔵 協助 |
| 文獻回顧與因子設計 | ✅ 主責 | — |
| 撰寫 Notebook 原型 | ✅ 主責 | 🔵 協助 |
| 設計 OOS / Walk-Forward 驗證 | ✅ 主責 | 🔵 協助 |
| 將原型重構為 Production Code | 🔵 協助 | ✅ 主責 |
| 開發回測引擎／Harness 工具 | — | ✅ 主責 |
| 維護資料管線與 TEJ Ingest | 🔵 協助 | ✅ 主責 |
| 上線監控與 Drawdown 告警 | 🔵 協助 | ✅ 主責 |
| 績效歸因與報告 | ✅ 主責 | 🔵 協助 |

---

## 學習檢核清單

完成 onboarding 前，請逐項自我檢核：

### 基礎能力

- [ ] 能解釋 IS Sharpe 與 OOS Sharpe 的差異，以及為何 OOS Sharpe 通常較低
- [ ] 能說明 Walk-Forward Analysis 的步驟與關鍵參數
- [ ] 能計算 CAGR、Max Drawdown、Calmar 比率
- [ ] 能解釋 Bonferroni 校正為何在 Grid Search 後是必要的

### 產業知識

- [ ] 能畫出 TSMC、聯電、世界先進、力積電、穩懋的差異與定位
- [ ] 能列出至少 5 組同供應鏈的潛在配對交易標的
- [ ] 能解釋 HBM、CoWoS 主題的台股受惠鏈

### 工程能力

- [ ] 已成功安裝 zipline-tej 並執行 buy-and-hold 範例
- [ ] 能在 Jupyter 中切換 conda 環境並執行 `run_algorithm`
- [ ] 能讀懂 `arch.drawio` 並指出策略部署的關鍵節點
- [ ] 了解 NanoClaw Sandbox 的權限模型

### 流程能力

- [ ] 能依「理論推論 → 文獻佐證 → 程式回測 → 中文摘要報告」完成一份策略提案
- [ ] 知道何時該觸發 `/review-strategy` 進行同儕審查
- [ ] 能撰寫符合內部規範的策略 PR 與回測報告

---

## 延伸閱讀與資源

### 內部資源

- `/home/kevin/gs-zipline-tej/README.md` — Zipline-TEJ 完整安裝與使用文件
- `/home/kevin/gs-zipline-tej/simple_run_zw.md` — 中文快速入門
- `/home/kevin/.claude/CLAUDE.md` — 全域 AI 助手協作慣例

### 外部資源

- [TEJ 官網](https://www.tej.com.tw/) — 台灣經濟新報，台股量化資料主要來源
- [TQuant Lab 教學](https://github.com/tejtw/TQuant-Lab) — TEJ 官方 Zipline 教學集
- [Wilder, J. W. (1978)](https://www.amazon.com/New-Concepts-Technical-Trading-Systems/dp/0894590278) — *New Concepts in Technical Trading Systems*（ADX 原始文獻）
- [López de Prado (2018)](https://www.wiley.com/en-us/Advances+in+Financial+Machine+Learning-p-9781119482086) — *Advances in Financial Machine Learning*（多重檢定與過擬合）

### Claude Code 內可用 Skill

- `/quant-researcher` — 產生新策略時自動執行四階段流程（理論 → 文獻 → 回測 → 摘要）
- `/review-strategy` — 以 Jane Street 等級嚴謹度審查策略 Markdown 規格

---

*最後更新：2026-05-11*
*維護者：gsinvest017-kevin*
