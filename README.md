# isucon13

### git clone
```
git config --global url.https://megutamago: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@github.com/.insteadOf https://github.com/
git clone https://github.com/megutamago/isucon13.git
```

## はじめにやること

- マニュアルと起動手順把握。アプリの中身把握
- VM複製
- SSH設定
- OS情報収集
- webappのダウンロード、gitへアップ
- netdata, alp, pprof, pt-query-digest インストール
- ポートフォワーディング
- CI設定(GithubへIPアドレス登録、シェル修正)
- ボトルネック測定
- 開発環境整備(デバッグツールなど)

<br>

# ISUCON Commands

### shell
```
# archive
tar zcvfp /tmp/webapp.tar.gz /home/isucon/private_isu/webapp

# mysqldump
mysqldump -u isuconp isuconp | gzip > /tmp/isuconp.dump.sql.gz 

# scp
scp ubuntu@x.x.x.x:/tmp/webapp.tar.gz ./
scp ubuntu@x.x.x.x:/tmp/isuconp.dump.sql.gz ./
scp ubuntu@x.x.x.x:/etc/nginx/nginx.conf ./

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
ssh -fN -L 0.0.0.0:1080:localhost:1080 isu1
http://192.168.11.21:1080/
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
ssh -fN -L 0.0.0.0:19999:localhost:19999 isu1  # netdata
ssh -fN -L 0.0.0.0:1080:localhost:1080 isu1  # pprof
ssh -fN -L 0.0.0.0:8080:localhost:8080 isu1  # grafana
ssh -fN -L 0.0.0.0:9100:localhost:9100 isu1  # node_exporter
ssh -fN -L 0.0.0.0:3100:localhost:3100 isu1  # fluent-bit
ps aux | grep ssh

# pprof
curl http://127.0.0.1:1080/
webAccess: http://192.168.11.21:1080/

# wipe ps
kill $(ps aux | grep 'ssh -fN -L 0.0.0.0:19999:localhost:19999 isu1' | grep -v grep | awk '{print $2}')
kill $(ps aux | grep 'ssh -fN -L 0.0.0.0:1080:localhost:1080 isu1' | grep -v grep | awk '{print $2}')
ps aux | grep ssh
```