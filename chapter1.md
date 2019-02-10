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

```sh
用户名@主机名 ~
ssh-keygen -t rsa -b 4096 -C "username@domain.com"
# 回车
cd .ssh
eval "$(ssh-agent -s)"
Agent pid 16780
ssh-add ~/.ssh/id_rsa
Identity added: /c/Users/35398/.ssh/id_rsa (/c/Users/35398/.ssh/id_rsa)
```


