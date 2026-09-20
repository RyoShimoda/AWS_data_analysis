SELECT
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    oi.product_id,
    oi.price,
    oi.freight_value,
    r.review_score
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN reviews r
    ON o.order_id = r.order_id
LIMIT 20;