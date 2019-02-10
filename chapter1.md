# First Chapter

```sh
apt-get install git build-essential libssh-dev
```

/home/downloads 安裝 node.js

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
用户名@服务器名 ~
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


