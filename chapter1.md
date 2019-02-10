# First Chapter

准备

安裝 node.js

```sh
wget https://nodejs.org/dist/v10.15.1/node-v10.15.1-linux-x64.tar.xz
tar -xvf node-v10.15.1-linux-x64.tar.xz
mv node-v10.15.1-linux-x64.tar.xz nodejs
ln -s /home/downloads/nodejs/bin/npm /usr/local/bin/
ln -s /home/downloads/nodejs/bin/node /usr/local/bin/
node -v
# 删除
sudo rm /usr/local/bin/node
sudo rm /usr/local/bin/npm
```

```sh
# 查看端口占用
netstat -tln | grep 3000
tcp        0      0 127.0.0.1:3000          0.0.0.0:*               LISTEN
# 查看端口属于哪个程序    
lsof -i :3000
COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
node    18245 root   20u  IPv4 219551      0t0  TCP localhost:3000 (LISTEN)
# 杀掉占用端口的进程：
kill -9 进程ID
```

```bash
adduser me
gpasswd -a me sudo
Adding user me to group sudo
sudo visudo
# User privilege specification
root    ALL=(ALL:ALL) ALL
me      ALL=(ALL:ALL) ALL
# 按 CTRL+X SHIFT+Y ENTER
service ssh restart
```

ssh公钥实现本地无秘登录

```bash
me@服务器名 ~
$ ssh-keygen -t rsa -b 4096 -C "username@domain.com"
$ eval "$(ssh-agent -s)"
Agent pid 16780
$ cd .ssh
$ ls
id_rsa  id_rsa.pub
$ ssh-add ~/.ssh/id_rsa
Identity added: /home/me/.ssh/id_rsa (/home/me/.ssh/id_rsa)
$ vi authorized_keys
# 复制本地的~/.ssh下的id_rsa内容
# 再粘贴到服务器vi打开的公钥文件
$ chmod 600 authorized_keys
$ sudo service ssh restart
```

修改ssh 端口

```bash
sudo vi /etc/ssh/sshd_config
# port 22 改为自定义端口(>1024 && <65535)
# 最后一行后面加上
AllowUsers <username>
sudo service ssh restart
# 再次尝试登录
$ ssh <username>@<host-ip>
ssh: connect to host <ip> port 22: Connection refused
# 去阿里云添加一条安全组规则，自定义TCP 刚才设置的ssh端口
$ ssh -p <port> <username>@<host-ip>
```

[刘月林 \| 解决阿里云 ssh 端口修改后连接失败的问题](https://www.jianshu.com/p/51fdf8139e9a)

配置防火墙规则
```bash
sudo vi /etc/iptables.up.rules
*filter

# allow all connections
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# allow out traffic
-A OUTPUT -j ACCEPT

# allow http https
-A INPUT -p tcp --dport 443 -j ACCEPT
-A INPUT -p tcp --dport 80 -j ACCEPT
-A INPUT -p tcp --dport 3000 -j ACCEPT

# allow ssh port login
-A INPUT -p tcp -m state --state NEW --dport 39999 -j ACCEPT

# ping 
-A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT

# log denied calls
-A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables denied:" --log-level 7

# drop incoming sensitive connections
-A INPUT -p tcp --dport 80 -i eth0 -m state --state NEW -m recent --set
-A INPUT -p tcp --dport 80 -i eth0 -m state --state NEW -m recent --update --seconds 60 --hitc
ount 180 -j DROP

# reject all other inbound
-A INPUT -j REJECT
-A FORWARD -j REJECT

# website
-A INPUT -s 127.0.0.1 -p tcp --destination-port 3000 -m state --state NEW,ESTABLISHED -j ACCEPT
-A OUTPUT -s 127.0.0.1 -p tcp --source-port 3000 -m state --state ESTABLISHED -j ACCEPT

#movie
COMMIT
<Esc>:wq
sudo iptables-restore < /etc/iptables.up.rules
sudo ufw status
Status: inactive
sudo ufw enable
Command may disrupt existing ssh connections. Proceed with operation (y|n)? y
Firewall is active and enabled on system startup
sudo ufw status
Status: active

To                         Action      From
--                         ------      ----
3000                       ALLOW       Anywhere                  
3000 (v6)                  ALLOW       Anywhere (v6)
sudo vi /etc/network/if-up.d/iptables
#!/bin/sh
iptables-restore /etc/iptables.up.rules
<Esc>:wq
sudo chmod +x /etc/network/if-up.d/iptables
```

配置fail2ban

```sh
sudo apt-get install fail2ban
sudo vi /etc/fail2ban/jail.conf
...
destemail = <username>@domain
...
action = %(action_mw)s
<Esc>:wq
sudo service fail2ban stop
sudo service fail2ban start
sudo service fail2ban status
```

安装环境依赖

```sh
apt-get install git build-essential libssh-dev
```

```sh
# https://github.com/creationix/nvm
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
nvm install v10.15.1
nvm use v10.15.1
nvm alias default v10.15.1
nvm ls
node -v
npm --registry=https://registry.npm.taobao.org install -g npm
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -pfs.inotify.max_user_watches=524288
vm.swappiness = 0
net.ipv4.neigh.default.gc_stale_time = 120
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.all.arp_announce = 2
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 1024
net.ipv4.tcp_synack_retries = 2
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
kernel.sysrq = 1
fs.inotify.max_user_watches = 524288
npm install pm2 webpack
```
pm2 实现对node程序运维
```sh
pm2 list
                        -------------

__/\\\\\\\\\\\\\____/\\\\____________/\\\\____/\\\\\\\\\_____
 _\/\\\/////////\\\_\/\\\\\\________/\\\\\\__/\\\///////\\\___
  _\/\\\_______\/\\\_\/\\\//\\\____/\\\//\\\_\///______\//\\\__
   _\/\\\\\\\\\\\\\/__\/\\\\///\\\/\\\/_\/\\\___________/\\\/___
    _\/\\\/////////____\/\\\__\///\\\/___\/\\\________/\\\//_____
     _\/\\\_____________\/\\\____\///_____\/\\\_____/\\\//________
      _\/\\\_____________\/\\\_____________\/\\\___/\\\/___________
       _\/\\\_____________\/\\\_____________\/\\\__/\\\\\\\\\\\\\\\_
        _\///______________\///______________\///__\///////////////__


                          Runtime Edition

        PM2 is a Production Process Manager for Node.js applications
                     with a built-in Load Balancer.

                Start and Daemonize any application:
                $ pm2 start app.js

                Load Balance 4 instances of api.js:
                $ pm2 start api.js -i 4

                Monitor in production:
                $ pm2 monitor

                Make pm2 auto-boot at server restart:
                $ pm2 startup

                To go further checkout:
                http://pm2.io/

pm2 start app.js
pm2 show <id|name>
pm2 logs
```

Nginx 实现反向代理
```sh
# 终止apache服务
sudo service apache2 stop
update-rc.d -f apache2 remove
sudo apt-get remove apache2
```

```sh
sudo apt-get install nginx
nginx -v
nginx version: nginx/1.10.3 (Ubuntu)

sudo vi /etc/nginx/conf.d/
hi-com-3000.conf
```
虚拟主机配置
让
```js
upstream hi {
  server 127.0.0.1:3000;
}

server {
  listen 80;
  server_name <host-ip>;

  location / {
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forward-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_set_header X-Nginx-Proxy true;

    proxy_pass http://hi;
    proxy_redirect off;
  }
}
```
查看nginx主配置文件，确认包含
```sh
sudo vi /etc/nginx/nginx.conf 
http {
    ...
    ##
    # Virtual Host Configs
    ##

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;

}
```
检查nginx配置是否正确
```sh
sudo nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
sudo nginx -s reload
```
然后可以通过公网ip直接访问之前pm2开启的3000端口web服务

去掉响应头服务器详细信息
默认：
Server: nginx/1.10.3 (Ubuntu)
```sh
sudo vi /etc/nginx/nginx.conf
server_tokens off; # 去掉注释
sudo service nginx restart reload
```
修改后：
Server: nginx

mongodb 云数据库连接
```sh
mongo "mongodb://cluster0-shard-00-00-dk9yb.mongodb.net:27017,cluster0-shard-00-01-dk9yb.mongodb.net:27017,cluster0-shard-00-02-dk9yb.mongodb.net:27017/test?replicaSet=Cluster0-shard-0" --ssl --authenticationDatabase admin --username <username> --password <password>
mongo "mongodb+srv://cluster0-dk9yb.mongodb.net/test" --username <username>
```  
安装mongodb
[Install MongoDB Community Edition on Ubuntu](https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/)

去掉apt-get 阿里云安装源（可选）
```sh
vi /etc/apt/apt.conf
# 将require注释
```
若安装很慢，可结束并更改源
```sh
vi /etc/apt/sources.list.d/mongodb-org-4.0.list
deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.0 multiverse
# https://mirrors.aliyun.com/mongodb/ubuntu
```

启动mongod服务
```sh
sudo service mongod start
sudo cat /var/log/mongodb/mongod.logmongo
MongoDB shell version v4.0.6
connecting to: mongodb://127.0.0.1:27017/?gssapiServiceName=mongodb
sudo service mongod stop
sudo service mongod restart
```

修改mongod默认端口
```sh
sudo vi /etc/mongod.conf
# network interfaces
net:
  port: 19999 #
  bindIp: 127.0.0.1
sudo service mongod restart
sudo vi /etc/iptales.up.rules
# 添加规则
# mongodb connect
-A INPUT -s 127.0.0.1 -p tcp --destination-port 19999 -m state --state NEW,ESTABLISHED -j ACCEPT
-A OUTPUT -d 127.0.0.1 -p tcp --source-port 19999 -m state --state ESTABLISHED -j ACCEPT
mongo --port 19999
```
