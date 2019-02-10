# First Chapter

```sh
apt-get install git build-essential ilbssh-dev
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

查看端口占用
```sh
netstat -tln | grep 3000
# 查看端口属于哪个程序    
lsof -i :3000
# 杀掉占用端口的进程：
kill -9 进程ID
# 
ps -ef | grep xxx
kill xxx
```




