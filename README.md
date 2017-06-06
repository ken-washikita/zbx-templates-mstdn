# zbx-templates-mstdn
Zabbix Templates for Mastodon

Mastodonインスタンスを監視するための、Zabbixテンプレート。
Redis/Sidekiqを監視します。

# インストールガイド

## Zabbixのインストール
このガイドではZabbixのインストールについては説明しません。Zabbixについては他のガイドをご覧ください。

- Zabbixサーバは設定済みと仮定しています。Mastodonインスタンスと同一ホストである必要はありません
- Zabbixエージェントはインストール済みで、Zabbixサーバと連携済みと仮定しています。
  - /etc/zabbix に設定ファイルが集約されていると仮定しています。
- Mastodonはインストール済みで、redisが動作しているホストと仮定しています。redis-cliは動作しているものとします。
  - 複数サーバ構成になっている場合、redisが動作しているサーバを対象として作業してください。

## Redisの監視
このテンプレートでは、redis-cliの出力を分析します。そのためにまず、redis-cliを定期的に起動し、出力をファイルに保存します。
redis-cliは次のような情報を出力します。
```
# redis-cli info
# Server
redis_version:3.0.6
redis_git_sha1:00000000
redis_git_dirty:0
:
:
```
まず、/etc/zabbix/redisディレクトリを作成します。
```
# mkdir -p /etc/zabbix/redis
```
ここに、ファイル`redis-latency.sh`を置き、実行ビットを立てます。
```
# chmod +x redis-latency.sh
```
次にcronを設定します。`redis-cron`を/etc/cron.dに設置します。
cronが正しく動作し始めると、/etc/zabbix/redisに2つのファイル`redis-info`と`redis-latency`が作成され、更新されるようになります。
```
# ls -l
total 12
-rw-r--r-- 1 root root 2056 Jun  6 13:04 redis-info
-rw-r--r-- 1 root root    2 Jun  6 13:04 redis-latency
-rwxr-xr-x 1 root root  207 May  6 17:37 redis-latency.sh
```
次に/etc/zabbix/zabbix_agentd.dディレクトリに、`userparameter_redis.conf`を設置します。
このファイルはZabbixエージェントが上記のファイルを読み込んでパラメータをZabbixサーバに返すためのスクリプトを定義します。

最後に、Zabbixサーバで`Template_App_Redis.xml`をインポートし、さらに対象サーバに`Template App Redis`を適用します。
これでRedisの各種パラメータが監視できるようになります。

## Sidekiq Statusの監視
Sidekiqは2つのテンプレート、StatusとProcessを使って監視します。まずStatusから説明します。
StatusはSidekiqの処理状態と、キューの状態を表すパラメータを監視します。`Sidekiq::Stats`をコールして得られる値を整理しています。

まずディレクトリ/etc/cron.dに`sidekiq-cron`を設置します。
cronは1分おきに、/var/tmp/sidekiq-infoファイルを作成し、更新するようになります。

次に/etc/zabbix/zabbix_agentd.dディレクトリに`userparameter_sidekiq.conf`を設置します。
このファイルはZabbixエージェントが上記のファイルを読み込んでパラメータをZabbixサーバに返すためのスクリプトを定義します。

最後にZabbixサーバで`Template_App_Sidekiq_Status.xml`をインポートし、対象サーバに`Template App Sidekiq Status`を適用します。

もし大規模Mastodonを運用していて、Sidekiqサーバが複数に分かれている場合、Sidekiq Statusは1台のサーバだけを対象にインストールしてください。
`Sidekiq::Stats`はすべてのSidekiqの状態を一括して返すので、1台のサーバに問い合わせるだけで十分間に合います。

## Sidekiq Processの監視
Sidekiq Processはシンプルな監視テンプレートで、sidekiqプロセスが存在しているか否かをチェックします。
Zabbixサーバで`Template_AppSidekiq_Process.xml`をインポートし、対象サーバに`Template App Sidekiq Process`を適用します。
