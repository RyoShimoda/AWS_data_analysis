-- 売上集計と配送遅延分析で、注文数に差が出る条件を確認する。
-- 注文IDのみを集計し、顧客情報などの個人を特定しうる値は出力しない。

WITH order_item_orders AS (
    -- 商品明細が1件以上ある注文を注文単位で抽出する。
    SELECT order_id
    FROM order_items
    WHERE order_id IS NOT NULL
      AND TRIM(order_id) <> ''
    GROUP BY order_id
),

sales_eligible_orders AS (
    -- 月別・州別売上SQLと同じ条件で、売上集計対象の注文を作る。
    SELECT o.order_id
    FROM orders o
    JOIN order_item_orders i
        ON o.order_id = i.order_id
    JOIN customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
      AND o.order_id IS NOT NULL
      AND TRIM(o.order_id) <> ''
      AND o.order_purchase_timestamp IS NOT NULL
      AND TRIM(o.order_purchase_timestamp) <> ''
      AND c.customer_state IS NOT NULL
      AND TRIM(c.customer_state) <> ''
),

valid_delivery_dates AS (
    -- 配送遅延SQLと同じく、実配送日と予定配送日の両方がある注文。
    SELECT order_id
    FROM orders
    WHERE order_id IS NOT NULL
      AND TRIM(order_id) <> ''
      AND order_delivered_customer_date IS NOT NULL
      AND TRIM(order_delivered_customer_date) <> ''
      AND order_estimated_delivery_date IS NOT NULL
      AND TRIM(order_estimated_delivery_date) <> ''
),

valid_review_orders AS (
    -- 配送遅延SQLと同じく、有効な1～5点のレビューがある注文。
    SELECT order_id
    FROM reviews
    WHERE order_id IS NOT NULL
      AND TRIM(order_id) <> ''
      AND review_score IN ('1', '2', '3', '4', '5')
    GROUP BY order_id
),

delivery_analysis_orders AS (
    -- sql/athena/13_create_delivery_delay_summary.sqlと同じ結合条件。
    SELECT d.order_id
    FROM valid_delivery_dates d
    JOIN valid_review_orders r
        ON d.order_id = r.order_id
),

sales_reconciliation AS (
    -- 売上集計対象の各注文について、配送日とレビューの有無を分類する。
    SELECT
        s.order_id,
        CASE
            WHEN d.order_id IS NOT NULL AND r.order_id IS NOT NULL
                THEN '配送日と有効レビューの両方あり'
            WHEN d.order_id IS NULL AND r.order_id IS NOT NULL
                THEN '配送日の不足'
            WHEN d.order_id IS NOT NULL AND r.order_id IS NULL
                THEN '有効レビューの不足'
            ELSE '配送日と有効レビューの両方が不足'
        END AS condition_group
    FROM sales_eligible_orders s
    LEFT JOIN valid_delivery_dates d
        ON s.order_id = d.order_id
    LEFT JOIN valid_review_orders r
        ON s.order_id = r.order_id
),

delay_orders_not_in_sales AS (
    -- 配送遅延分析対象のうち、売上集計対象には含まれない注文を数える。
    SELECT d.order_id
    FROM delivery_analysis_orders d
    LEFT JOIN sales_eligible_orders s
        ON d.order_id = s.order_id
    WHERE s.order_id IS NULL
)

SELECT
    '売上集計対象の注文数' AS check_item,
    COUNT(*) AS order_count
FROM sales_eligible_orders

UNION ALL

SELECT
    '配送遅延分析対象の注文数（配送日と有効レビューあり）' AS check_item,
    COUNT(*) AS order_count
FROM delivery_analysis_orders

UNION ALL

SELECT
    condition_group AS check_item,
    COUNT(*) AS order_count
FROM sales_reconciliation
GROUP BY condition_group

UNION ALL

SELECT
    '配送遅延分析にはあるが売上集計にはない注文数' AS check_item,
    COUNT(*) AS order_count
FROM delay_orders_not_in_sales

ORDER BY check_item;
