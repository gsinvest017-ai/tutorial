# Strategy Validation Terms: Quantitative Strategy Terminology Glossary
# 策略驗證術語：量化策略術語詞彙表

---

## bps (Basis Points) ／ 基點

**English:**
One basis point equals 1/100th of one percent (0.01%). Used to express small changes in yields, spreads, fees, or performance figures without ambiguity. A strategy returning 50 bps per day earns 0.50% daily. Transaction costs are often quoted in bps (e.g., 2 bps per trade).

**繁體中文：**
一個基點等於 1/100 個百分點（0.01%）。常用於精確表達殖利率、利差、手續費或績效變動，避免百分比描述的歧義。每日報酬 50 bps 即日報酬率 0.50%。交易成本常以基點計價（例如每筆交易 2 bps）。

---

## Rolling Position Cost ／ 滾動持倉成本

**English:**
The continuously updated average cost basis of a position as new trades are added or partially closed. At each new trade, the cost is recalculated by a weighted average:

```
New rolling cost = (old_qty × old_cost + new_qty × new_price) / (old_qty + new_qty)
```

Tracking rolling cost is essential for P&L attribution, tax lot accounting, and determining whether adding to a position improves or worsens the breakeven price.

**繁體中文：**
持倉成本隨每次加減碼而持續更新的加權平均買入價。每次新交易後重新計算：

```
新滾動成本 = (舊數量 × 舊成本 + 新數量 × 新價格) / (舊數量 + 新數量)
```

追蹤滾動持倉成本是 P&L 歸因、稅務批次會計，以及評估加碼是否改善損益平衡點的基礎工具。

---

## Walk-Forward Analysis ／ 滾動向前驗證

**English:**
A methodology that simulates live trading by repeatedly fitting a model on a fixed-length historical window (in-sample, IS) and immediately testing it on the next unseen period (out-of-sample, OOS), then rolling the window forward. This produces a chain of OOS segments whose stitched-together equity curve approximates real deployment. It guards against look-ahead bias and measures how well parameters generalise over time.

Key parameters: IS length, OOS length, anchored vs. rolling window.

**繁體中文：**
模擬實盤部署的方法論：在固定長度的歷史視窗（樣本內，IS）上反覆擬合模型，立即在下一段未見數據（樣本外，OOS）上測試，再向前滾動視窗。各段 OOS 拼接而成的資產曲線近似真實上線績效。此方法防止前視偏差，並衡量參數跨時間的泛化能力。

關鍵參數：IS 長度、OOS 長度、錨定視窗 vs. 滾動視窗。

---

## Grid Search ／ 網格搜索

**English:**
Exhaustive hyperparameter optimisation that evaluates every combination in a discretised parameter space. For example, searching over `fast_ma ∈ {5,10,20}` and `slow_ma ∈ {50,100,200}` tests 3×3 = 9 combinations. Grid search is simple and parallelisable but suffers from the curse of dimensionality and severely inflates the risk of in-sample overfitting — the best-found configuration is typically optimistically biased. Always combine with out-of-sample validation or a multiple-testing correction.

**繁體中文：**
在離散化的參數空間中窮舉所有組合的超參數優化方法。例如搜索 `fast_ma ∈ {5,10,20}` 與 `slow_ma ∈ {50,100,200}` 共測試 9 種組合。網格搜索簡單且易於並行化，但面臨維度詛咒，且嚴重放大樣本內過擬合風險——所找到的最佳組合通常具有樂觀偏差。必須搭配樣本外驗證或多重檢定校正使用。

---

## IS Sharpe (In-Sample Sharpe Ratio) ／ 樣本內夏普比率

**English:**
The Sharpe ratio computed on the same data used to fit or select the strategy's parameters. Because the model has been tuned to this data, the IS Sharpe is almost always inflated relative to live performance. It measures how well a strategy *fits* the historical data, not how well it will *generalise*.

```
IS Sharpe = mean(IS returns) / std(IS returns) × √(annualisation factor)
```

A high IS Sharpe is a necessary but not sufficient condition for a viable strategy.

**繁體中文：**
在用於擬合或選擇策略參數的相同數據上計算的夏普比率。由於模型已針對此數據調整，樣本內夏普幾乎總是高估實盤績效。它衡量策略對歷史數據的「擬合程度」，而非「泛化能力」。

```
IS Sharpe = mean(IS 報酬) / std(IS 報酬) × √(年化係數)
```

高 IS Sharpe 是策略可行性的必要條件，但非充分條件。

---

## OOS Statistics & OOS Sharpe ／ 樣本外統計量與夏普比率

**English:**
Statistics (mean return, volatility, Sharpe, max drawdown, hit rate, etc.) computed on data the model has *never seen* during parameter selection. The OOS Sharpe is the gold-standard estimate of forward-looking performance. A common rule of thumb: OOS Sharpe ≥ 0.5 × IS Sharpe is acceptable; a ratio near 1 suggests little overfitting. Degradation below 30% of IS Sharpe often indicates overfit.

Other OOS statistics to monitor:
- **OOS hit rate** — fraction of OOS periods with positive return
- **OOS max drawdown** — worst peak-to-trough in OOS segment
- **t-stat of OOS mean** — tests whether OOS mean is significantly > 0

**繁體中文：**
在模型「從未見過」的數據上計算的統計量（均值報酬、波動率、夏普、最大回撤、勝率等）。OOS 夏普是前瞻績效的黃金標準估計。常用經驗法則：OOS Sharpe ≥ 0.5 × IS Sharpe 屬可接受；比值接近 1 表示過擬合極少。若 OOS Sharpe 低於 IS Sharpe 的 30%，通常是過擬合訊號。

其他 OOS 統計量：
- **OOS 勝率** — OOS 期間報酬為正的比例
- **OOS 最大回撤** — OOS 段內的最大峰谷跌幅
- **OOS 均值 t 統計量** — 檢定 OOS 均值是否顯著大於 0

---

## ADX (Average Directional Index) & Wilder Criterion ／ 平均趨向指標與 Wilder 準則

**English:**
**ADX** measures trend *strength* (not direction) on a 0–100 scale, derived from J. Welles Wilder Jr.'s *New Concepts in Technical Trading Systems* (1978). It is calculated from the smoothed ratio of directional movement to true range:

```
+DM = max(High − prev_High, 0)  if  High − prev_High > prev_Low − Low, else 0
−DM = max(prev_Low − Low, 0)    if  prev_Low − Low > High − prev_High, else 0
DX  = |+DI − −DI| / (+DI + −DI) × 100
ADX = Wilder-smoothed average of DX over N periods (default N=14)
```

**Wilder smoothing** (Wilder criterion / Wilder's EMA) uses a smoothing factor α = 1/N rather than the standard EMA's 2/(N+1), making it slower to respond:

```
Wilder_smooth(t) = Wilder_smooth(t−1) × (N−1)/N + value(t) × 1/N
```

**ADX interpretation:**
| ADX value | Trend strength |
|-----------|----------------|
| < 20      | Absent / weak  |
| 20 – 25   | Developing     |
| 25 – 40   | Strong         |
| > 40      | Very strong    |

Trend-following strategies often gate entry on ADX > 25 to avoid choppy markets.

**繁體中文：**
**ADX** 衡量趨勢的「強度」（而非方向），取值範圍 0–100，源自 J. Welles Wilder Jr. 1978 年著作《技術交易系統的新概念》。由方向性運動相對於真實波幅的平滑比率計算而來：

```
+DM = max(High − prev_High, 0)，若 High−prev_High > prev_Low−Low，否則 0
−DM = max(prev_Low − Low, 0)，若 prev_Low−Low > High−prev_High，否則 0
DX  = |+DI − −DI| / (+DI + −DI) × 100
ADX = 對 DX 進行 N 期 Wilder 平滑（預設 N=14）
```

**Wilder 平滑法**（Wilder 準則 / Wilder EMA）使用平滑係數 α = 1/N，比標準 EMA 的 2/(N+1) 反應更慢：

```
Wilder_smooth(t) = Wilder_smooth(t−1) × (N−1)/N + value(t) × 1/N
```

**ADX 解讀：**
| ADX 值    | 趨勢強度       |
|-----------|----------------|
| < 20      | 無趨勢 / 弱勢  |
| 20 – 25   | 趨勢形成中     |
| 25 – 40   | 強趨勢         |
| > 40      | 極強趨勢       |

趨勢追蹤策略通常以 ADX > 25 作為進場過濾條件，以避開震盪市場。

---

## Bonferroni Correction ／ Bonferroni 校正

**English:**
A multiple-testing correction that adjusts the significance threshold when performing *k* simultaneous hypothesis tests to control the family-wise error rate (FWER). Instead of using α = 0.05 for each test, each individual test must meet:

```
α* = α / k
```

In strategy research, if you grid-search 100 parameter combinations, the effective p-value threshold for declaring a strategy significant drops to 0.05/100 = 0.0005. The correction is conservative (it assumes tests are independent); for correlated tests, Holm-Bonferroni or Benjamini-Hochberg FDR corrections are more appropriate.

**繁體中文：**
在同時進行 *k* 個假設檢定時，用於控制族系誤差率（FWER）的多重檢定校正方法。與其對每個檢定使用 α = 0.05，每個檢定必須達到：

```
α* = α / k
```

在策略研究中，若網格搜索 100 個參數組合，宣告策略顯著的有效 p 值門檻降至 0.05/100 = 0.0005。此校正較保守（假設各檢定獨立）；對於相關檢定，Holm-Bonferroni 或 Benjamini-Hochberg FDR 校正更為適合。

---

## Bootstrap Sharpe ／ 自助抽樣夏普比率

**English:**
A distribution of Sharpe ratios obtained by repeatedly resampling (with replacement) the strategy's return series and recomputing the Sharpe each time (typically 1,000–10,000 iterations). This yields:

1. **Confidence intervals** on the true Sharpe (e.g., 5th–95th percentile band)
2. **p-value** for H₀: Sharpe ≤ 0 (proportion of bootstrap samples with Sharpe ≤ 0)
3. **Bias estimate** — difference between mean bootstrap Sharpe and observed Sharpe

Block bootstrap (resampling contiguous blocks) is preferred over i.i.d. bootstrap when returns exhibit autocorrelation or volatility clustering, preserving the time-series structure.

**繁體中文：**
透過對策略報酬序列反覆有放回抽樣並重新計算夏普比率（通常 1,000–10,000 次）而得到的夏普比率分佈。提供：

1. **夏普比率的信賴區間**（如第 5–95 百分位區間）
2. **p 值**，用於檢定 H₀：Sharpe ≤ 0（bootstrap 樣本中 Sharpe ≤ 0 的比例）
3. **偏差估計** — bootstrap 夏普均值與觀測夏普的差值

當報酬存在自相關或波動率聚集時，應採用**區塊自助抽樣**（抽取連續區塊）而非 i.i.d. 抽樣，以保留時間序列結構。

---

## CAGR (Compound Annual Growth Rate) ／ 複合年均成長率

**English:**
The constant annual rate at which an investment would have grown from its starting value to its ending value, assuming all returns are reinvested:

```
CAGR = (End Value / Start Value)^(1 / years) − 1
```

CAGR smooths out volatility and gives a single annualised return figure. It does **not** capture the path of returns (drawdowns, volatility). For a complete picture, always report CAGR alongside Sharpe ratio, max drawdown, and Calmar ratio (CAGR / max drawdown).

**繁體中文：**
假設所有報酬再投入，投資從起始值成長至終值所對應的恆定年化增長率：

```
CAGR = (期末價值 / 期初價值)^(1 / 年數) − 1
```

CAGR 平滑了波動性，給出單一年化報酬數字，但**不**捕捉報酬路徑（回撤、波動率）。完整評估策略時，應同時報告 CAGR、夏普比率、最大回撤，以及 Calmar 比率（CAGR / 最大回撤）。

---

*Last updated: 2026-05-07*
