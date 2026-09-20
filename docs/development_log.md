# Development Log

このファイルでは、Olist Brazilian E-Commerce Public Datasetを用いた
AWSデータ分析ポートフォリオの開発過程を記録する。

---

## Project Overview

### Goal

AWS上にデータ分析環境を構築し、

S3 → Athena → Redshift → EC2 / Python

というデータ分析フローを実践する。

最終的には、EDA、統計分析、機械学習まで行い、
データからビジネス上の示唆を導くことを目標とする。

---

## 2026-09-19

### 1. S3環境構築

- Olistデータセットを使用することを決定
- S3バケットを作成
- RawデータをS3にアップロード
- CSVをテーブル単位のフォルダに整理

### 2. Athena環境構築

- Athenaを使用してS3上のCSVをSQLで分析する環境を構築
- Athenaのクエリ結果保存先をS3に設定
- `olist`データベースを作成


## 2026-09-20
### 1. ordersテーブル作成

- S3上の`olist_orders_dataset.csv`をAthenaの外部テーブルとして登録
- CSVのヘッダーを読み飛ばす設定を追加
- 動作確認を実施

### 2. customersテーブル作成

- S3上の`olist_customers_dataset.csv`をAthenaの外部テーブルとして登録
- `customers`テーブルの読み込みを確認

### 3. orders × customers JOIN

- `customer_id`をキーとしてordersとcustomersをJOIN
- 注文情報と顧客の地域情報を組み合わせて取得できることを確認

### 4. Timestamp型について

- ordersテーブルの日時列を`timestamp`型として定義した際にエラーが発生
- `string`型では正常に読み込み・JOINできることを確認
- 現時点では日時列を`string`として保持し、分析時にtimestampへ変換する方針とした

### 5. GitHub管理

- GitHubリポジトリを作成
- SourceTreeとGitHubを接続
- `sql/athena/`ディレクトリを作成
- Athenaで使用したSQLをGitHubで管理する方針とした

### 6. order_itemsテーブル作成

- S3上の`olist_order_items_dataset.csv`をAthenaの外部テーブルとして登録
- 注文ID、商品ID、販売者ID、商品価格、送料などの項目を取得できることを確認
- 今後の売上・商品・配送に関する分析に使用する予定
---

## Next Steps

- order_itemsテーブル作成
- paymentsテーブル作成
- reviewsテーブル作成
- 複数テーブルを使用したSQL分析
- Redshift環境構築
- EC2環境構築
- PythonによるEDA
- 統計分析
- 機械学習
- ビジネス上の示唆の整理