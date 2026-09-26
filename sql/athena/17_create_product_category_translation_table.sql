-- 商品カテゴリ名の翻訳CSVをAthenaから参照する外部テーブルを作成する。
-- LOCATIONのYOUR_BUCKET_NAMEは、自分のS3バケット名に置き換える。
-- このSQLはCSVデータをコピーせず、Athenaで読むための列定義と場所を登録する。

CREATE EXTERNAL TABLE product_category_name_translation (
    product_category_name string,
    product_category_name_english string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
    'separatorChar' = ',',
    'quoteChar' = '"',
    'escapeChar' = '\\'
)
STORED AS TEXTFILE
LOCATION 's3://YOUR_BUCKET_NAME/raw/olist/category_translation/'
TBLPROPERTIES (
    'skip.header.line.count' = '1'
);
