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
        AVG(CAST(review_score AS double)) AS review_score
    FROM reviews
    WHERE order_id IS NOT NULL
      AND TRIM(order_id) <> ''
      AND review_score IN ('1', '2', '3', '4', '5')
    GROUP BY order_id
)

SELECT
    osm.order_id,
    osm.total_price,
    osm.total_freight,
    rsm.review_score
FROM order_summary osm
JOIN review_summary rsm
    ON osm.order_id = rsm.order_id
LIMIT 20;