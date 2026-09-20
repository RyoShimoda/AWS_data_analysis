CREATE EXTERNAL TABLE payments (
    order_id string,
    payment_sequential string,
    payment_type string,
    payment_installments string,
    payment_value double
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
    'separatorChar' = ',',
    'quoteChar' = '"',
    'escapeChar' = '\\'
)
STORED AS TEXTFILE
LOCATION 's3://YOUR_BUCKET_NAME/raw/olist/payments/'
TBLPROPERTIES (
    'skip.header.line.count' = '1'
);