-- 配達済み注文の商品カテゴリ・顧客州別に売上基準を集計する。
-- GMVは商品価格の合計とし、送料は含めない。
-- カテゴリ名は英語翻訳を優先し、翻訳がない場合は元のカテゴリ名を使う。

WITH delivered_orders AS (
    -- 月別・州別の売上基準集計と同じ注文条件を使う。
    SELECT
        order_id,
        customer_id
    FROM orders
    WHERE order_status = 'delivered'
      AND order_id IS NOT NULL
      AND TRIM(order_id) <> ''
      AND order_purchase_timestamp IS NOT NULL
      AND TRIM(order_purchase_timestamp) <> ''
),

category_order_items AS (
    -- 商品明細の価格に、商品カテゴリと購入者の州を付与する。
    -- 商品情報・翻訳情報は欠けていても明細を落とさないようLEFT JOINにする。
    SELECT
        c.customer_state,
        COALESCE(
            NULLIF(TRIM(t.product_category_name_english), ''),
            NULLIF(TRIM(p.product_category_name), ''),
            'uncategorized'
        ) AS product_category,
        oi.order_id,
        oi.price
    FROM delivered_orders d
    JOIN customers c
        ON d.customer_id = c.customer_id
    JOIN order_items oi
        ON d.order_id = oi.order_id
    LEFT JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_name_translation t
        ON p.product_category_name = t.product_category_name
    WHERE c.customer_state IS NOT NULL
      AND TRIM(c.customer_state) <> ''
)

SELECT
    customer_state,
    product_category,
    COUNT(DISTINCT order_id) AS category_order_count,
    COUNT(*) AS order_item_line_count,
    SUM(price) AS category_gmv,
    SUM(price) / COUNT(DISTINCT order_id) AS category_gmv_per_order
FROM category_order_items
GROUP BY
    customer_state,
    product_category
ORDER BY
    customer_state,
    category_gmv DESC;
