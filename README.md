# メモアプリ

このアプリケーションは、Sinatra と PostgreSQL を使用したシンプルなメモアプリです。

## セットアップ手順

### 必要なもの

- Ruby 3.1.7 以上
- Sinatra 4.1.0 以上
- PostgreSQL 14.17 以上

### 手順

1. リポジトリをクローンします。

   ```zsh
   git clone https://github.com/yourusername/sinatra-memo-app.git
   cd sinatra-memo-app
   ```

   ※ yourusername を、自分の GitHub ユーザー名に変更してください。

2. 必要な Ruby のライブラリをインストールします。

   ```zsh
   bundle install
   ```

3. PostgreSQL にデータベースとテーブルを作成します。以下の SQL を実行してください。

   ```sql
   CREATE DATABASE memo_app_db;

   \c memo_app_db;

   CREATE TABLE memos (
   id SERIAL PRIMARY KEY,
   title TEXT NOT NULL,
   content TEXT NOT NULL
   );
   ```

4. アプリケーションを起動します。以下のコマンドでpumaを起動します。

    ```zsh
    bundle exec puma config.ru
    ```

### URI一覧

- `GET /memos` : すべてのメモの一覧を取得
- `POST /memos` : 新しいメモを作成
- `GET /memos/:id` : ID指定でメモを取得
- `PATCH /memos/:id` : ID指定でメモを更新
- `DELETE /memos/:id` : ID指定でメモを削除
