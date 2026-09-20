CREATE EXTERNAL TABLE order_items (
    order_id string,
    order_item_id string,
    product_id string,
    seller_id string,
    shipping_limit_date string,
    price double,
    freight_value double
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
    'separatorChar' = ',',
    'quoteChar' = '"',
    'escapeChar' = '\\'
)
STORED AS TEXTFILE
LOCATION 's3://YOUR_BUCKET_NAME/raw/olist/order_items/'
TBLPROPERTIES (
    'skip.header.line.count' = '1'
);