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
### 3. ordersテーブル作成

- S3上の`olist_orders_dataset.csv`をAthenaの外部テーブルとして登録
- CSVのヘッダーを読み飛ばす設定を追加
- 動作確認を実施

### 4. customersテーブル作成

- S3上の`olist_customers_dataset.csv`をAthenaの外部テーブルとして登録
- `customers`テーブルの読み込みを確認

### 5. orders × customers JOIN

- `customer_id`をキーとしてordersとcustomersをJOIN
- 注文情報と顧客の地域情報を組み合わせて取得できることを確認

### 6. Timestamp型について

- ordersテーブルの日時列を`timestamp`型として定義した際にエラーが発生
- `string`型では正常に読み込み・JOINできることを確認
- 現時点では日時列を`string`として保持し、分析時にtimestampへ変換する方針とした

### 7. GitHub管理

- GitHubリポジトリを作成
- SourceTreeとGitHubを接続
- `sql/athena/`ディレクトリを作成
- Athenaで使用したSQLをGitHubで管理する方針とした

### 8. order_itemsテーブル作成

- S3上の`olist_order_items_dataset.csv`をAthenaの外部テーブルとして登録
- 注文ID、商品ID、販売者ID、商品価格、送料などの項目を取得できることを確認
- 今後の売上・商品・配送に関する分析に使用する予定
---

### 9.paymentsテーブル作成

- S3上の`olist_order_payments_dataset.csv`をAthenaの外部テーブルとして登録
- 注文ID、支払い方法、支払い回数、支払い金額などの項目を取得できることを確認
- 今後の支払い方法や注文金額に関する分析に使用する予定

### 10.データ型について

- `string`はIDや文字列として扱う項目に使用
- `double`は商品価格や送料など、小数を含む数値項目に使用
- 日時項目については、現時点では`string`として読み込み、分析時に必要に応じて`timestamp`へ変換する方針

### 11.reviewsテーブル作成

- S3上の`olist_order_reviews_dataset.csv`をAthenaの外部テーブルとして登録
- レビューID、注文ID、評価スコア、レビューコメント、レビュー日時などの項目を取得できることを確認
- 今後のレビュー評価と配送状況・商品・注文情報などの関係分析に使用する予定

### 12.int型について

- reviewsテーブルの`review_score`を`int`型として定義した際にエラーが発生
- `string`型では正常に読み込みできることを確認
- 現時点では`revies_socore`を`string`として保持し、分析時に`int`へ変換する方針とした

### 13. orders・order_items・reviewsのJOIN

- `order_id`をキーとして`orders`、`order_items`、`reviews`の3テーブルをJOIN
- 注文情報、商品価格、送料、レビュー評価を1つのデータセットとして取得
- 今後、商品価格・送料・配送状況とレビュー評価の関係を分析するための基礎データとして使用する

### 14. レビュー評価別の価格・送料集計

- `order_items`と`reviews`を`order_id`でJOIN
- レビュー評価（1～5）ごとにデータをグループ化（GROUP BY）
- 評価ごとの件数、平均商品価格、平均送料を集計（AVG）
- レビュー評価と商品価格・送料の関係を確認するための基礎集計を実施
- 今後、観察された傾向について統計的な検証を行う予定

## Next Steps
- 複数テーブルを使用したSQL分析
- Redshift環境構築
- EC2環境構築
- PythonによるEDA
- 統計分析
- 機械学習
- ビジネス上の示唆の整理