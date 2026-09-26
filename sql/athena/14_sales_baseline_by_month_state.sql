-- 顧客の州・購入月別に売上の基準値を集計する。
-- GMVは配達済み注文に含まれる商品価格の合計とし、送料は含めない。
-- 月は配送日ではなく、注文の購入日を基準にする。

WITH order_item_summary AS (
    -- order_itemsは商品明細単位のため、注文・顧客テーブルと結合する前に
    -- 注文単位へ集約し、結合後に金額が重複するのを防ぐ。
    SELECT
        order_id,
        SUM(price) AS order_gmv,
        SUM(freight_value) AS order_freight
    FROM order_items
    WHERE order_id IS NOT NULL
      AND TRIM(order_id) <> ''
    GROUP BY order_id
),

delivered_orders AS (
    SELECT
        order_id,
        customer_id,
        CAST(SUBSTR(order_purchase_timestamp, 1, 10) AS date) AS purchase_date
    FROM orders
    WHERE order_status = 'delivered'
      AND order_id IS NOT NULL
      AND TRIM(order_id) <> ''
      AND order_purchase_timestamp IS NOT NULL
      AND TRIM(order_purchase_timestamp) <> ''
),

order_sales AS (
    -- 注文単位の明細集計と顧客情報を結合し、1注文1行のデータを作る。
    SELECT
        DATE_FORMAT(
            CAST(DATE_TRUNC('month', CAST(d.purchase_date AS timestamp)) AS timestamp),
            '%Y-%m'
        ) AS purchase_month,
        c.customer_state,
        d.order_id,
        i.order_gmv,
        i.order_freight
    FROM delivered_orders d
    JOIN order_item_summary i
        ON d.order_id = i.order_id
    JOIN customers c
        ON d.customer_id = c.customer_id
    WHERE c.customer_state IS NOT NULL
      AND TRIM(c.customer_state) <> ''
)

SELECT
    purchase_month,
    customer_state,
    COUNT(DISTINCT order_id) AS order_count,
    SUM(order_gmv) AS gmv,
    SUM(order_freight) AS total_freight,
    SUM(order_gmv) / COUNT(DISTINCT order_id) AS average_order_value
FROM order_sales
GROUP BY
    purchase_month,
    customer_state
ORDER BY
    purchase_month,
    customer_state;
