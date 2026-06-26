# アプリ名
BooKPuT(bookとoutputを組み合わせた造語)

# 概要

# 制作背景

# ペルソナ

# 要件定義

# 機能一覧&使用方法

## 新規登録
## ログイン
## ログアウト
## マイページ
## アカウント解約
## 新規投稿
## 投稿詳細
## 投稿編集
## 投稿削除
## 投稿通報
## 投稿高評価・投稿低評価
## 投稿お気に入り追加
## 投稿検索
## コメント投稿
## コメント編集
## コメント削除
## コメント非表示
## コメント通報
## コメント高評価・低評価

# 本番環境

## テスト用アカウント
ID →
パスワード

# 工夫した、苦労したポイント

# 使用技術（開発環境）

## バックエンド
Ruby, Ruby on Rails

## フロントエンド
JavaScript, jQuery

## データベース
MySQL

## インフラ
AWS

## Webサーバ（本番環境）
Heroku

## ソース管理
Github, GitHubDesktop

## エディタ
Visual Studio Code

## テスト
Rspec

# ローカルでの動作方法
Rubyのバージョン → 4.0.0
rbenvのバージョン → 1.1.2

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
- has_many :comments
- has_many :favorites
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
- has_many   :comments
- has_many   :favorites
- has_many   :book_contents
- has_many   :reported_books
- has_many   :book_goods
- has_many   :book_bads

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