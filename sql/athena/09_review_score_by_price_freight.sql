SELECT 
    r.review_score,
    COUNT(*) AS review_count,
    AVG(oi.price) AS average_price,
    AVG(oi.freight_value) AS average_freight
FROM order_items oi
JOIN reviews r
    ON oi.order_id = r.order_id
GROUP BY r.review_score
ORDER BY r.review_score;