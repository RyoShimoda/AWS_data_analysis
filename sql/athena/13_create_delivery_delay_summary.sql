WITH delivery_summary AS (
    SELECT
        order_id,
        date_diff(
            'day',
            CAST(CAST(order_estimated_delivery_date AS timestamp) AS date),
            CAST(CAST(order_delivered_customer_date AS timestamp) AS date)
        ) AS delivery_delay_days
    FROM orders
    WHERE order_delivered_customer_date IS NOT NULL
      AND TRIM(order_delivered_customer_date) <> ''
      AND order_estimated_delivery_date IS NOT NULL
      AND TRIM(order_estimated_delivery_date) <> ''
),
review_summary AS (
    SELECT
        order_id,
        ROUND(AVG(CAST(review_score AS double))) AS review_score
    FROM reviews
    WHERE order_id IS NOT NULL
      AND TRIM(order_id) <> ''
      AND review_score IN ('1','2','3','4','5')
    GROUP BY order_id
)
SELECT
    d.order_id,
    r.review_score,
    d.delivery_delay_days
FROM delivery_summary d
JOIN review_summary r
    ON d.order_id = r.order_id
ORDER BY
    r.review_score,
    d.order_id;