WITH order_summary AS (
    SELECT
        order_id,
        SUM(price) AS total_price,
        SUM(freight_value) AS total_freight
    FROM order_items
    GROUP BY order_id
),
review_summary AS (
    SELECT
        order_id,
        ROUND(AVG(CAST(review_score AS double))) AS review_score
    FROM reviews
    WHERE order_id IS NOT NULL
      AND TRIM(order_id) <> ''
      AND review_score IN ('1', '2', '3', '4', '5')
    GROUP BY order_id
)
SELECT
    rsm.review_score,
    COUNT(*) AS order_count,
    AVG(osm.total_price) AS average_order_price,
    AVG(osm.total_freight) AS average_order_freight
FROM order_summary osm
JOIN review_summary rsm
    ON osm.order_id = rsm.order_id
GROUP BY rsm.review_score
ORDER BY rsm.review_score;