# zbx-templates-mstdn
Zabbix Templates for Mastodon

Mastodonインスタンスを監視するための、Zabbixテンプレート。
Redis/Sidekiqを監視します。

# インストールガイド

## Zabbixのインストール
このガイドではZabbixのインストールについては説明しません。
Zabbixについては他のガイドをご覧ください。

## Redisの監視
Redisを監視するために、情報ファイルの取得を行います。Redisの情報の取得にはredis-cliを利用します。

    root@redis:/etc/zabbix/redis# redis-cli info | head
    # Server
    redis_version:3.0.6
    redis_git_sha1:00000000
    redis_git_dirty:0
    :

これをcronで1分おきに起動し、結果をファイルに出力します。ファイルはZabbixが読めるようにする必要があります。
ここでは、/etc/zabbix/redisディレクトリを作成し、redis-infoという名前で保存するようにします。

    # mkdir -p /etc/zabbix/redis

cronは、/etc/cron.d/redis-cronというファイルに以下のように記述します。
```
    */1 * * * * root /usr/bin/redis-cli info >/etc/zabbix/redis/redis-info
```
このファイルは、userparameter_redis.confが読み込み、Zabbixサーバに監視データとして値を送出する元となります。

もうひとつ、redis-latencyというパラメータを取得します。redis-cliを利用して取得するバッチファイルredis-latency.shを用意しています。
これを/etc/zabbix/redisに置き、cronで1分おきに起動して、結果をファイルredis-latencyに保存します。
```
    */1 * * * * root /etc/zabbix/redis/redis-latency.sh
```
このファイルも、userparameter_redis.confが読み込み、Zabbixサーバに監視データとして値が送出されます。
