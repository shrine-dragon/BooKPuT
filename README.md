# アプリ名

BooKPuT(bookとoutputを組み合わせた造語)

# 概要

# 使用方法

## 新規登録

## 新規投稿

## 投稿閲覧

# 制作背景

## ペルソナ

# 本番環境

## テスト用アカウント
ID →
パスワード

# DEMO

## トップページ

## 新規登録

## ログイン

## ログアウト

## アカウント解約

## 新規投稿

## 投稿詳細

## 投稿編集

## 投稿削除

## コメント投稿

## 投稿検索

## 高評価

## お気に入り追加

アカウント解約

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

# 要件定義

# ローカルでの動作方法

Rubyのバージョン → 4.0.0
rbenvのバージョン → 1.1.2

# ER図

https://gyazo.com/9c0dd7ccf15340a627e80d2172d4055b

# テーブル設計

## users テーブル

|         Column         |   Type  |          Options          |
|------------------------|---------|---------------------------|
|        nickname        |  string |       null: false         |
|        birth_day       |   date  |       null: false         |
|        gender_id       | integer |       null: false         |
|          email         |  string | null: false, unique: true |
|   encrypted_password   |  string |       null: false         |

### Association

- has_many :books
- has_many :comments
- has_many :highRatings
- has_many :favorites

## booksテーブル

|       Column       |    Type    |            Options             |
|--------------------|------------|--------------------------------|
|        title       |   string   |          null: false           |
|     category_id    |   integer  |          null: false           |
|       content      |    text    |          null: false           |
|        user        | references | null: false, foreign_key: true |

### Association

- belongs_to :user
- has_many   :comments
- has_many :highRatings
- has_many :favorites

## commentsテーブル

| Column |    Type    |            Options             |
|--------|------------|--------------------------------|
|  text  |    text    |          null: false           |
|  user  | references | null: false, foreign_key: true |
|  book  | references | null: false, foreign_key: true |

### Association

- belongs_to :user
- belongs_to :book

## highRatingsテーブル

| Column |    Type    |            Options             |
|--------|------------|--------------------------------|
|  user  | references | null: false, foreign_key: true |
|  book  | references | null: false, foreign_key: true |

### Association

- belongs_to :user
- belongs_to :book

## favoritesテーブル

| Column |    Type    |            Options             |
|--------|------------|--------------------------------|
|  user  | references | null: false, foreign_key: true |
|  book  | references | null: false, foreign_key: true |

### Association

- belongs_to :user
- belongs_to :book