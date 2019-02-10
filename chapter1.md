# First Chapter
准备
```sh
apt-get install git build-essential libssh-dev
```

安裝 node.js
```sh
wget https://nodejs.org/dist/v10.15.1/node-v10.15.1-linux-x64.tar.xz
tar -xvf node-v10.15.1-linux-x64.tar.xz
mv node-v10.15.1-linux-x64.tar.xz nodejs
ln -s /home/downloads/nodejs/bin/npm /usr/local/bin/
ln -s /home/downloads/nodejs/bin/node /usr/local/bin/
node -v
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

```sh
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

```sh
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

```sh
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

修改防火墙规则
```sh
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

# mongodb connect
-A INPUT -s 127.0.0.1 -p tcp --destination-port 19999 -m state --state NEW,ESTABLISHED -j ACCEPT
-A OUTPUT -d 127.0.0.1 -p tcp --source-port 19999 -m state --state ESTABLISHED -j ACCEPT

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

destemail = <username>@domain
...
action = %(action_mw)s
<Esc>:wq
sudo service fail2ban stop
sudo service fail2ban start
sudo service fail2ban status
```


