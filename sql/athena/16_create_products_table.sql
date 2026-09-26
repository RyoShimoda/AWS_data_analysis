-- 商品CSVをAthenaから参照する外部テーブルを作成する。
-- LOCATIONのYOUR_BUCKET_NAMEは、自分のS3バケット名に置き換える。
-- このSQLはCSVデータをコピーせず、Athenaで読むための列定義と場所を登録する。

CREATE EXTERNAL TABLE products (
    product_id string,
    product_category_name string,
    product_name_lenght int,
    product_description_lenght int,
    product_photos_qty int,
    product_weight_g int,
    product_length_cm int,
    product_height_cm int,
    product_width_cm int
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
    'separatorChar' = ',',
    'quoteChar' = '"',
    'escapeChar' = '\\'
)
STORED AS TEXTFILE
LOCATION 's3://YOUR_BUCKET_NAME/raw/olist/products/'
TBLPROPERTIES (
    'skip.header.line.count' = '1'
);
