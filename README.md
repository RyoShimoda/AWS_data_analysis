# AWS_data_analysis

OlistのブラジルECサイトデータを使い、注文金額・送料・配送状況と顧客レビューの関係を分析するプロジェクトです。AWS（S3・Athena）とSQLでデータを準備し、Python（Positron / Jupyter Notebook）で分析しています。分析結果を売り上げ向上、顧客体験や配送・販売施策の改善に結びつけることを目的としてます。

## プロジェクトの目的

- 注文金額・送料・配送状況とレビュー評価の関係を明らかにする
- 顧客の低評価につながる要因や、改善の優先順位を検討する
- 低評価予測を活用し、問題が起きやすい注文を早期に把握できる可能性を評価する
- 結果の実務上の意味と限界を整理し、具体的な改善施策の検討につなげる

## データ

- **データセット:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- **主なデータ:** 注文、商品、送料、支払い、レビュー、配送に関する情報
- **利用条件:** データ提供元の利用条件に従います。元データはこのリポジトリに含めません。

## 使用技術

- **AWS:** Amazon S3、Amazon Athena
- **SQL:** Athena用クエリ（Redshift用ディレクトリも用意）
- **分析:** Python、R、Positron、Jupyter Notebook
- **分析手法:** 記述統計、箱ひげ図、Kruskal–Wallis検定、Dunn検定（Bonferroni補正）、ロジスティック回帰

## リポジトリ構成

```text
AWS_data_analysis/
├── data/             # ローカルの分析データ（公開対象に含めない）
├── docs/
│   └── development_log.md
├── images/           # 公開可能な分析図
├── notebooks/        # Python / Rによる分析
├── sql/
│   ├── athena/       # Athena用SQL
│   └── redshift/     # Redshift用SQL
├── src/              # 分析用コード
└── README.md
```

## 分析内容

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

- [低評価予測Notebook](notebooks/predict_row_review.ipynb)
- 低評価：レビュー1～2点（`low_review = 1`）
- 説明変数：注文金額、送料、配送遅延日数
- モデル：ロジスティック回帰
- 評価：混同行列、Accuracy、Precision、Recall、F1-score、ROC-AUC、ROC曲線、Precision–Recall曲線

データ中の低評価は12.77%、通常評価は87.23%でした。クラスに偏りがあるため、Accuracyだけでは性能を判断せず、PrecisionやRecallなども確認しています。

初期分析ではROC-AUC 0.6744でした。低評価を事前に把握する仕組みが業務上有用か、またどの程度の誤検知・見逃しが許容されるかを判断するには、性能の改善と運用コストの検討が必要です。この段階ではTestデータをしきい値比較にも使っているため、数値は学習用の途中結果です。最終性能とは扱わず、次にTrain / Validation / Testへ分割し、Validationでしきい値を決めてからTestで評価します。

## 実行環境について

Notebookの実行には、OlistデータセットとAWS環境（S3・Athena）が必要です。データの取得とAWSの設定は、各自の環境で行ってください。SQL内のデータ保存先や接続設定は、利用環境に合わせて確認してください。

## ビジネス上の示唆と今後の課題

- Train / Validation / Testの3分割で予測モデルを再評価する
- Validationデータでしきい値を決め、Testデータで最終評価する
- 配送遅延や注文条件など、改善可能な要因と低評価の関係を追加分析する
- 低評価の早期把握を業務に使う場合の対応方法、誤検知・見逃しのコスト、期待効果を検討する
- 結果の限界と適用条件を明らかにし、施策の判断に使える形で示唆をまとめる
- NotebookとSQLの実行条件、前処理を整理して分析の再現性を高める
- 確認できた結果とビジネス上の示唆を、このREADMEと[`development_log.md`](docs/development_log.md)に反映する

## 更新方針

READMEはプロジェクトの概要と、現時点で確認できた主な結果を伝える入口として保ちます。分析の試行錯誤や日ごとの判断は[`development_log.md`](docs/development_log.md)に記録し、節目ごとにREADMEへ確定した内容を反映します。
