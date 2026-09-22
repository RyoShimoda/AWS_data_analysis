CREATE EXTERNAL TABLE reviews (
    review_id string,
    order_id string,
    review_score string,
    review_comment_title string,
    review_comment_message string,
    review_creation_date string,
    review_answer_timestamp string
)

ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
    'separatorChar' = ',',
    'quoteChar' = '"',
    'escapeChar' = '\\'
)

STORED AS TEXTFILE
LOCATION 's3://YOUR_BUCKET_NAME/raw/olist/reviews/'
TBLPROPERTIES (
    'skip.header.line.count' = '1'
);