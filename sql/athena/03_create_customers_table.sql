CREATE EXTERNAL TABLE customers (
    customer_id string,
    customer_unique_id string,
    customer_zip_code_prefix string,
    customer_city string,
    customer_state string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
    'separatorChar' = ',',
    'quoteChar' = '"',
    'escapeChar' = '\\'
)
STORED AS TEXTFILE
LOCATION 's3://YOUR_BUCKET_NAME/raw/olist/customers/'
TBLPROPERTIES (
    'skip.header.line.count' = '1'
);
