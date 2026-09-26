# AWS_data_analysis

OlistのブラジルECサイトデータを使い、売上増加につながる改善候補を探るプロジェクトです。AWS（S3・Athena）とSQLでデータを準備し、Python（Positron / Jupyter Notebook）で注文・顧客体験を分析します。売上指標の基準値を作り、地域・商品・販売者などの違いから施策仮説を選び、実施可能な施策は比較検証することを目指します。

## プロジェクトの目的

- 売上（GMV）・注文数・平均注文額の基準値と変化を把握する
- 地域・商品カテゴリ・販売者などに分け、売上機会と顧客体験の課題を探る
- 配送やレビューとの関連を、施策対象を見つけるための補助情報として使う
- 施策仮説を立て、可能であれば比較群を設けて売上・利益への効果を検証する

## データ

- **データセット:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- **主なデータ:** 注文、商品、送料、支払い、レビュー、配送に関する情報
- **ライセンス:** [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/)
- **出典表記:** Olist, “Brazilian E-Commerce Public Dataset by Olist” ([Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)). このプロジェクトで加工したデータを共有する場合は、出典・ライセンス・変更内容を明記し、ライセンス条件を確認します。
- **データの保管:** 元データと注文単位の分析用CSVはローカルの`data/`に置き、GitHubには含めません。`data/`は`.gitignore`で除外しています。

## 使用技術

- **AWS:** Amazon S3、Amazon Athena
- **SQL:** Athena用クエリ（Redshift用ディレクトリも用意）
- **分析:** Python、R、Positron、Jupyter Notebook
- **分析手法:** 記述統計、箱ひげ図、Kruskal–Wallis検定、Dunn検定（Bonferroni補正）、ロジスティック回帰

## リポジトリ構成

```text
AWS_data_analysis/
├── data/             # ローカル分析データ（Git管理対象外）
├── docs/
│   └── development_log.md
├── images/           # 分析図
├── notebooks/        # Python / Rによる分析
├── sql/
│   ├── athena/       # Athena用SQL
│   └── redshift/     # Redshift用SQL
├── src/              # 分析用コード
└── README.md
```

## 分析内容

### 売上増加に向けた基準分析

配達済み注文の商品価格合計をGMV（売上の代理指標）とし、購入月・顧客州別に注文数、GMV、平均注文額を集計しました。注文商品価格の合計と注文数から計算した平均注文額は、全体で137.04（データ上の金額単位）でした。

- 対象：96,478注文、2016年9月～2018年8月の23か月
- GMV合計：13,221,498.11
- 送料合計：2,198,275.64（GMVとは分けて集計）
- 注文数・GMVが最大の州：SP（40,501注文、GMV 5,067,633.16）
- 月別GMVが最大：2017年11月（987,765.37、7,289注文）
- [月別・州別の売上基準集計SQL](sql/athena/14_sales_baseline_by_month_state.sql)

SPは注文数・GMVの規模が最大ですが、平均注文額は125.12で、全体平均137.04を下回りました。商品構成などの違いを次に確認するための仮説候補として扱い、この集計だけで施策の効果や原因とは判断しません。利益・原価・販促費の情報がないため、利益額や利益への効果も測定できません。2016年の初期月は注文数が非常に少なく、月ごとの比較から除外して慎重に扱う必要があります。

### 注文金額・送料とレビュー評価

注文に複数の商品が含まれることを考慮し、商品単位の明細を注文単位に集約してからレビュー情報と結合しました。レビュー評価別に注文金額と送料を比較しています。

- [レビュー評価別の注文金額分析](notebooks/review_price_analysis.ipynb)
- [レビュー評価別の注文金額・送料の図](images/Order_Price_by_Review_Score_Box.png)、[送料の図](images/Order_Freight_by_Review_Score.png)

Kruskal–Wallis検定では、注文金額・送料ともにレビュー評価群間で統計的な差が確認されました。一方、効果量 ε² は注文金額0.003015、送料0.009481で、どちらも小さい値でした。大きなサンプルでは、p値だけでなく効果量も確認する必要があります。観察データの分析であり、因果関係を示すものではありません。

### 配送遅延とレビュー評価

実配送日と予定配送日の差を`delivery_delay_days`として集計しました。負の値は予定より早い配送、0は予定どおり、正の値は予定より遅い配送です。

- [配送遅延分析Notebook](notebooks/review_delivery_analysis.ipynb)
- 分析対象：95,830注文
- レビュー評価別の中央値：1点 -7日、2点 -10日、3点 -11日、4点 -12日、5点 -13日
- Kruskal–Wallis検定：H = 3890.1397、p < 0.001
- Dunn検定（Bonferroni補正）：全てのレビュー評価群間で有意差
- 効果量：ε² = 0.040555

レビュー評価が高いグループほど、配送遅延日数の中央値が小さい傾向でした。配送状況を顧客体験の改善候補として検討する根拠になりますが、外れ値やレビュー評価ごとの件数の偏りがあり、この分析だけで配送遅延が低評価の原因だとは判断できません。施策の優先順位を決めるには、地域・商品・販売者など他の要因もあわせた検討が必要です。

### 低評価予測モデル

- [低評価予測Notebook](notebooks/predict_low_review.ipynb)
- 低評価：レビュー1～2点（`low_review = 1`）
- 説明変数：注文金額、送料、配送遅延日数
- モデル：ロジスティック回帰
- 評価：混同行列、Accuracy、Precision、Recall、F1-score、ROC-AUC、ROC曲線、Precision–Recall曲線

データ中の低評価は12.77%、通常評価は87.23%でした。クラスに偏りがあるため、Accuracyだけでは性能を判断せず、PrecisionやRecallなども確認しています。

Train / Validation / Testを60 / 20 / 20に分割し、ValidationでF1が最大となったしきい値0.24を選び、Testで最終評価しました。

| Test指標 | 結果 |
|---|---:|
| Accuracy | 0.8860 |
| Precision | 0.5919 |
| Recall | 0.3472 |
| F1-score | 0.4377 |
| ROC-AUC | 0.6838 |

このモデルは低評価の傾向を一定程度識別しましたが、低評価注文の約65%は見逃しています。現時点では改善施策の対象を選ぶための探索分析であり、売上増加や配送改善の因果効果を示すものではありません。説明変数には配送後に確定する配送遅延日数が含まれるため、購入前の予測にはそのまま使えません。

## 実行環境について

Pythonの依存パッケージはプロジェクト直下の`.venv`に分離します。Windows PowerShellでは、初回に次のコマンドを実行してください。

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

次回以降は`.\.venv\Scripts\Activate.ps1`で有効化します。Positron / Jupyter Notebookを使う場合は、Pythonインタープリターとしてプロジェクト内の`.venv`を選択してください。

Notebookの実行には、OlistデータセットとAWS環境（S3・Athena）が必要です。SQLの結果をローカルの`data/`に保存してください。現在の分析Notebookは`data/review_order_summary.csv`と`data/delivery_delay_review_summary.csv`を読み込みます。これらは[`12_create_review_order_summary.sql`](sql/athena/12_create_review_order_summary.sql)と[`13_create_delivery_delay_summary.sql`](sql/athena/13_create_delivery_delay_summary.sql)から作成できます。データファイル自体はライセンス条件と再配布の可否を確認し、GitHubには含めない運用です。AWSの接続設定や認証情報はREADMEやNotebookに記載しないでください。

## ビジネス上の示唆と今後の課題

- 月次・顧客州別の売上基準値を確認し、季節性や期間途中の月を考慮して比較する
- 商品カテゴリ・販売者別の売上と注文数を追加し、機会のあるセグメントを特定する
- 売上規模に加え、平均注文額・低評価率・遅延率を使って施策候補を絞る
- 再購入や利益を測れるデータの有無を確認し、売上増加と利益改善を区別する
- 施策を試せる場合は比較群を設け、施策前後の売上・注文数・利益を評価する
- 低評価予測モデルは、運用上の対応方法と費用対効果が明確になった段階で再評価する
- NotebookとSQLの実行条件、前処理を整理して分析の再現性を高める
- 確認できた結果とビジネス上の示唆を、このREADMEと[`development_log.md`](docs/development_log.md)に反映する

## 更新方針

READMEはプロジェクトの概要と、現時点で確認できた主な結果を伝える入口として保ちます。分析の試行錯誤や日ごとの判断は[`development_log.md`](docs/development_log.md)に記録し、節目ごとにREADMEへ確定した内容を反映します。
