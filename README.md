# isucon13

# 目標： isuconの基本的なフローを実践したい。最初から最後まで！初期スコアを超える！

### 参考
- Gdrive: https://drive.google.com/drive/u/0/folders/1mSxXyqf8PX5YR-F2Y5jBvrA5ELSLqVbT
- ref: https://github.com/kazeburo/private-isu-challenge

### git clone
```
git config --global url.https://megutamago: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@github.com/.insteadOf https://github.com/
git clone https://github.com/megutamago/isucon13.git
```

### 作業サーバ
- CloudFormationでいつでも再構築できるので、一人一台で作業できる


## 競技開始直後のムーブ
- マニュアルと起動手順、アプリの確認
- VM複製(念のため)
- SSH設定
- アプリの言語をgoに設定する
- Webブラウザでアプリの起動を確認する
- 開発環境整備(デバッグツールなど)
- webappのダウンロード、gitへアップ
- CI設定(GithubへIPアドレス登録、シェル修正)
    - OS情報をスマートに取得(シェル実行)
    - netdata, alp, pprof, pt-query-digest インストール
    - mysql, nginx ログ設定
    - env.ymlの"git_repo" 適宜修正
- ポートフォワーディング
- ボトルネック測定
- 修正方針、コード修正

## isucon PDCA
1. アクセスログとデータベースのログを取得
    - nginx
    - alp
    - mysql
    - app (pprof)
2. サーバのメトリクスを取得する
    - ベンチマーク実行中のtopコマンドでサーバのリソース使用状況を見る
    - netdata導入してメトリクス見るもよし
3. ボトルネックのAPIを特定する
4. 遅い原因を特定する
    - クエリが遅いのか
        - クエリの実行回数
        - クエリの実行時間
    - アプリが遅いのか
        - cpu
        - memory
5. コード修正を反映する（Githubからデプロイまでを自動化したい）
6. ベンチマークを回す

<br>


# ISUCON Commands

### shell
```
# archive
tar zcvfp /tmp/webapp.tar.gz /home/isucon/private_isu/webapp

# mysqldump
mysqldump -u isuconp isuconp | gzip > /tmp/isuconp.dump.sql.gz 

# scp
scp isu1:/tmp/webapp.tar.gz ./
scp isu1:/tmp/isuconp.dump.sql.gz ./
scp isu1:/etc/nginx/nginx.conf ./

# remove
rm -f /tmp/webapp.tar.gz
rm -f /tmp/isuconp.dump.sql.gz
```

---

### pprof
```
# profile
sudo curl -o cpu.pprof http://localhost:6060/debug/pprof/profile?seconds=60
sudo go tool pprof -http localhost:1080 cpu.pprof
ssh -N -L 0.0.0.0:1080:localhost:1080 isu1
http://localhost:1080/
#http://192.168.11.21:1080/
```

---

### alp
```
sudo cat /var/log/nginx/access.log \
| alp ltsv -m '/image/[0-9]+,/posts/[0-9]+,/@\w' \
--sort avg -r -o count,1xx,2xx,3xx,4xx,5xx,min,max,avg,sum,p99,method,uri
```

---

### pt-query-digest
```
#sudo sed -i '/^INSERT INTO `posts`/d' /var/log/mysql/mysql-slow.sql
sudo pt-query-digest /var/log/mysql/mysql-slow.sql
```

---

### unarchive
``` 
rm -rf ../test-private_isu/webapp/ && \
tar zxvfp ./files/fetch/webapp.tar.gz -C ../test-private_isu/ && \
mv ../test-private_isu/home/isucon/private_isu/webapp ../test-private_isu/ && \
rm -rf ../test-private_isu/home/
```

---

### ssh port foward
```
ssh -N -L 0.0.0.0:19999:localhost:19999 isu1  # netdata
ssh -N -L 0.0.0.0:1080:localhost:1080 isu1  # pprof
ssh -N -L 0.0.0.0:8080:localhost:8080 isu1  # grafana
ssh -N -L 0.0.0.0:9100:localhost:9100 isu1  # node_exporter
ssh -N -L 0.0.0.0:3100:localhost:3100 isu1  # fluent-bit

# Case of background
ssh -fN -L 0.0.0.0:19999:localhost:19999 isu1  # netdata

# access
http://localhost:1080/
#http://192.168.11.21:1080/

# wipe ps
kill $(ps aux | grep 'ssh -fN -L 0.0.0.0:19999:localhost:19999 isu1' | grep -v grep | awk '{print $2}')
kill $(ps aux | grep 'ssh -fN -L 0.0.0.0:1080:localhost:1080 isu1' | grep -v grep | awk '{print $2}')
ps aux | grep ssh
```