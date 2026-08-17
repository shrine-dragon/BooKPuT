# アプリ名
BooKPuT(bookとoutputを組み合わせた造語)

# 概要
- 読書とSNSを融合させた近代的なアプリ。Xの簡素版。
- 自身が好きな本の内容を50〜350文字以内でアウトプット可。
- SNS認証を用いた新規登録やログイン、投稿の評価・コメント・お気に入り追加など、基本的な機能が備わっています。

# 制作背景
約5年前にテックキャンプでプログラミングを勉強し、ほとんど同じ内容のオリジナルアプリを開発したことがあります。
しかし、制作期間が限られており、技術も学びたてだったため、上記アプリは不完全な状態で｢完成｣扱いとし、デプロイをしました。すでにアプリは削除済みです。
しかし、5年経った今、再度プログラミングを勉強してアプリを作成してみたいとふと感じ、アップグレード版「BooKPuT」を開発するに至りました。

# 機能一覧

## 新規登録
- ニックネーム・画像(任意)・生年月日・性別・メールアドレス・パスワードをそれぞれ入力または選択して登録。
- メールアドレスとSNS(Google・X・Facebook・LINE)の二通りで登録可。
- 未ログインユーザーのみ。

## ログイン
- 登録済みのメールアドレスとパスワードを入力してログイン。
- メールアドレスとSNS(Google・X・Facebook・LINE)の二通りでログイン可。
- 未ログインユーザーのみ。

## ログアウト
- ログインユーザー用のモーダルを開き、「ログアウト」をタップまたはクリックしてログアウト可。
- ログインユーザーのみ。

## マイページ
- ログインユーザー用のモーダルを開き、「マイページ」をタップまたはクリックするとマイページに遷移できる。
- プロフィール・ログイン情報・自身の投稿リスト・高評価リスト・お気に入りリストをそれぞれ閲覧可。
- ログインユーザーのみ。

## アカウント解約
- マイページにある「アカウントを解約する」ボタンをタップまたはクリックし、「解約する」「本当に解約する」ボタンを順に押すと解約可。
- ログインユーザーのみ。

## 新規投稿
- タイトル・画像(任意)・本の種類・本のジャンル・内容項目をそれぞれ入力または選択すると投稿可。
- ログインユーザーのみ。

## 投稿詳細
- トップページの投稿一覧から投稿をタップまたはクリックすると投稿詳細ページに遷移し、投稿内容(タイトル・画像・本の種類・本のジャンル・内容項目)を閲覧可。

## 投稿編集
- 投稿詳細ページ右上の「編集」ボタンをタップまたはクリックすると投稿編集ページに遷移し、投稿内容を編集可。
- ログイン済みのbook投稿者のみ。

## 投稿削除
- 投稿詳細ページ右上の「削除」ボタンをタップまたはクリックすると削除可。
- ログイン済みのbook投稿者のみ。

## 投稿通報
- 投稿詳細ページ右上の「通報」ボタンをタップまたはクリックすると削除可。
- book投稿者以外のログインユーザーのみ。

## 投稿高評価
- 投稿詳細ページ右上の上向きの親指ボタンをタップまたはクリックすると高評価できる。
- book投稿者以外のログインユーザーのみ。

## 投稿低評価
- 投稿詳細ページ右上の下向きの親指ボタンをタップまたはクリックすると低評価できる。
- book投稿者以外のログインユーザーのみ。

## 投稿お気に入り追加
- 投稿詳細ページ右上の星型のボタンをタップまたはクリックするとお気に入りに追加できる。
- book投稿者以外のログインユーザーのみ。

## 投稿検索
- トップページ上部の検索バーに好きなキーワードを入力すると検索可。

## コメント投稿
- 投稿詳細ページ下部のコメントフォームに文字を入力するとコメント可。
- book投稿者以外のログインユーザーのみ。

## コメント編集
- 投稿済みのコメント内にある「編集」ボタンをタップまたはクリックすると編集可。
- ログイン済みのコメント投稿者のみ。

## コメント削除
- 投稿済みのコメント内にある「削除」ボタンをタップまたはクリックすると削除可。
- ログイン済みのコメント投稿者のみ。

## コメント非表示
- 投稿済みのコメント内にある「非表示」ボタンをタップまたはクリックすると編集可。
- コメント投稿者以外のログインユーザーのみ。

## コメント通報
- 投稿済みのコメント内にある「通報」ボタンをタップまたはクリックすると通報可。
- コメント投稿者以外のログインユーザーのみ。

## コメント高評価
- 投稿済みのコメント内にある上向きの親指ボタンをタップまたはクリックすると高評価できる。
- コメント投稿者以外のログインユーザーのみ。

## コメント低評価
- 投稿済みのコメント内にある下向きの親指ボタンをタップまたはクリックすると低評価できる。
- コメント投稿者以外のログインユーザーのみ。

# 工夫・苦労したポイント
- SNS認証機能
- 投稿機能における本のジャンル選択機能
- 投稿機能における内容項目の追加・削除
- 評価機能、コメント投稿機能などにおける非同期通信
- スマホ版・タブレット版のレスポンシブデザインの適用

# 使用技術（開発環境）

## バックエンド
Ruby, Ruby on Rails

## フロントエンド
JavaScript, jQuery

## データベース
MySQL

## 本番環境
Heroku

## ソース管理
Github, GitHubDesktop

## エディタ
Visual Studio Code

## テスト
Rspec

# ローカルでの動作方法
Rubyのバージョン →  3.2.9

# ER図
https://gyazo.com/74505254313630d1aad0da89967785b3

# テーブル設計

## users テーブル
|         Column         |   Type  |          Options          |
|------------------------|---------|---------------------------|
|        nickname        |  string |       null: false         |
|        birth_date      |   date  |       null: false         |
|        gender_id       | integer |       null: false         |
|          email         |  string | null: false, unique: true |
|   encrypted_password   |  string |       null: false         |

### Association
- has_many :books
- has_many :favorites
- has_many :comments
- has_many :hidden_comments
- has_many :reported_comments
- has_many :comment_goods
- has_many :comment_bads

## booksテーブル
|       Column       |    Type    |            Options             |
|--------------------|------------|--------------------------------|
|        title       |   string   |          null: false           |
|     category_id    |   integer  |          null: false           |
|      genre_id      |   integer  |          null: false           |
|       content      |    text    |          null: false           |
|        user        | references | null: false, foreign_key: true |

### Association
- belongs_to :user
- has_many   :book_contents
- has_many   :reported_books
- has_many   :book_goods
- has_many   :book_bads
- has_many   :favorites
- has_many   :comments

## book_contentsテーブル
|  Column |    Type    |            Options             |
|---------|------------|--------------------------------|
| content |    text    | null: false                    |
|   book  | references | null: false, foreign_key: true |

### Association
- belongs_to :book

## reported_booksテーブル
| Column |    Type    |            Options             |
|--------|------------|--------------------------------|
|  user  | references | null: false, foreign_key: true |
|  book  | references | null: false, foreign_key: true |

### Association
- belongs_to :user
- belongs_to :book

## book_goodsテーブル
| Column |    Type    |            Options             |
|--------|------------|--------------------------------|
|  user  | references | null: false, foreign_key: true |
|  book  | references | null: false, foreign_key: true |

### Association
- belongs_to :user
- belongs_to :book

## book_badsテーブル
| Column |    Type    |            Options             |
|--------|------------|--------------------------------|
|  user  | references | null: false, foreign_key: true |
|  book  | references | null: false, foreign_key: true |

### Association
- belongs_to :user
- belongs_to :book

## commentsテーブル
| Column |    Type    |            Options             |
|--------|------------|--------------------------------|
|  text  |    text    |          null: false           |
|  user  | references | null: false, foreign_key: true |
|  book  | references | null: false, foreign_key: true |

### Association
- belongs_to :user
- belongs_to :book
- has_many   :hidden_comments
- has_many   :reported_comments
- has_many   :comment_goods
- has_many   :comment_bads

## hidden_commentsテーブル
|  Column |    Type    |            Options             |
|---------|------------|--------------------------------|
|   user  | references | null: false, foreign_key: true |
| comment | references | null: false, foreign_key: true |

### Association
- belongs_to :user
- belongs_to :comment

## reported_commentsテーブル
|  Column |    Type    |            Options             |
|---------|------------|--------------------------------|
|   user  | references | null: false, foreign_key: true |
| comment | references | null: false, foreign_key: true |

### Association
- belongs_to :user
- belongs_to :comment

## comment_goodsテーブル
|  Column |    Type    |            Options             |
|---------|------------|--------------------------------|
|   user  | references | null: false, foreign_key: true |
| comment | references | null: false, foreign_key: true |

### Association
- belongs_to :user
- belongs_to :comment

## comment_badsテーブル
|  Column |    Type    |            Options             |
|---------|------------|--------------------------------|
|   user  | references | null: false, foreign_key: true |
| comment | references | null: false, foreign_key: true |

### Association
- belongs_to :user
- belongs_to :comment

## favoritesテーブル
| Column |    Type    |            Options             |
|--------|------------|--------------------------------|
|  user  | references | null: false, foreign_key: true |
|  book  | references | null: false, foreign_key: true |

### Association
- belongs_to :user
- belongs_to :book

## contactsテーブル
|  Column |  Type  |   Options   |
|---------|--------|-------------|
|   name  | string | null: false |
|  email  | string | null: false |
| subject | string |
| message |  text  | null: false |