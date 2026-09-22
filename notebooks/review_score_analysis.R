library(dplyr)
library(ggplot2)

# data読み込み
getwd()
df_review_order <- read.csv("data/analysis/review_order_summary.csv")

psych::describeBy(
  df_review_order$total_price, 
  group = df_review_order$review_score
)

box_total_price <- ggplot(
  df_review_order, 
  aes(x = factor(review_score), 
      y = total_price)) +
  geom_boxplot() +
  labs(x = "Review Score", 
       y = "Total Price") +
  ggtitle("Boxplot of Total Price by Review Score")

box_total_price

# グループ要約（中央値・平均・分位点・最大/最小）
summary <- df_review_order |>
  group_by(review_score) |>
  summarise(
    n = n(),
    mean = mean(total_price, na.rm = TRUE),
    median = median(total_price, na.rm = TRUE),
    p25 = quantile(total_price, 0.25, na.rm = TRUE),
    p75 = quantile(total_price, 0.75, na.rm = TRUE),
    p99 = quantile(total_price, 0.99, na.rm = TRUE),
    min = min(total_price, na.rm = TRUE),
    max = max(total_price, na.rm = TRUE),
    .groups = "drop"
  ) |>
  arrange(review_score)

# 1) log1p 変換した箱ひげ図（外れ値は表示しない）
df_log <- df_review_order |>
  mutate(log_price = log1p(total_price))

p1 <- ggplot(df_log, aes(x = factor(review_score), y = log_price)) +
  geom_boxplot(outlier.shape = NA) +
  scale_y_continuous(
    breaks = log1p(c(1, 10, 50, 100, 500, 1000, 5000, 10000)),
    labels = c(1, 10, 50, 100, 500, 1000, 5000, 10000)
  ) +
  labs(
    x = "Review Score",
    y = "Total Price (original scale)",
    title = "Boxplot of Total Price by Review Score (log1p)"
  ) +
  theme_minimal()

# 2) 上位1%をクリップして線形スケールで描画
p99 <- quantile(df_review_order$total_price, 0.99, na.rm = TRUE)
df_clipped <- df_review_order |>
  mutate(price_clipped = pmin(total_price, p99))

p2 <- ggplot(df_clipped, aes(x = factor(review_score), y = price_clipped)) +
  geom_boxplot() +
  labs(
    x = "Review Score",
    y = "Total Price (clipped)",
    title = paste0("Boxplot clipped at 99th percentile = ", round(p99))
  ) +
  theme_minimal()

# 表示（ノートブックで実行）
print(summary)
print(p1)
print(p2)

# 結果オブジェクトを返す
summary