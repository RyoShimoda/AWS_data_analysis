WITH order_summary AS (
    SELECT
        order_id,
        SUM(price) AS total_price,
        SUM(freight_value) AS total_freight
    FROM order_items
    GROUP BY order_id
)

SELECT
    osm.order_id,
    osm.total_price,
    osm.total_freight,
    r.review_score
FROM order_summary osm
JOIN reviews r
    ON osm.order_id = r.order_id
LIMIT 20;