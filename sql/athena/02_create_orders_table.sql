CREATE EXTERNAL TABLE orders (
    order_id string,
    customer_id string,
    order_status string,
    order_purchase_timestamp string,
    order_approved_at string,
    order_delivered_carrier_date string,
    order_delivered_customer_date string,
    order_estimated_delivery_date string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
    'separatorChar' = ',',
    'quoteChar' = '"',
    'escapeChar' = '\\'
)
STORED AS TEXTFILE
LOCATION 's3://YOUR_BUCKET_NAME/raw/olist/orders/'
TBLPROPERTIES (
    'skip.header.line.count' = '1'
);