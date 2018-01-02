# docker環境構築

## dockerイメージ作成
docker-compose build

## railsビルド
docker-compose run web rails new . --force --database=mysql --skip-bundle

## database.ymlを修正
```
default: &default
  adapter: mysql2
  encoding: utf8
  pool: 5
  username: root
  password: root
  host: db
```

## .envを作成(Google Drive API実行の為)
```
CLIENT_ID="xxxx"
CLIENT_SECRET="xxxx"
REFRESH_TOKEN="xxxx"
```
## bundle installの実行
docker-compose exec web bundle install

## ビルド&起動
docker-compose up -d
docker-compose ps

## DB作成
docker-compose exec web bin/rake db:create db:migrate db:seed

## Google Driveからデータ取得するバッチ実行(ファイル数によっては時間かかります)
docker-compose exec web bash
rails runner Tasks::Batch.execute

## ブラウザで確認
http://localhost:3000/

---

# その他基本操作

## dockerコンテナに接続
docker-compose exec web bash

## dockerコンテナ停止
docker-compose down

## dockerイメージを削除する時
docker images
docker rmi xxx

---

# scaffold手順

## scaffold
docker-compose exec web rails g scaffold users name:string
## マイグレーション
docker-compose exec web rails db:migrate

## ブラウザで確認
http://localhost:3000/users
