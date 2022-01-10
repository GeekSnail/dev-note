## pm2 部署 node 应用

    pm2 list
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
    pm2 start app.js --watch
    pm2 show <id|name>
    pm2 logs            

本地操作：github.com 建立一个私有仓库，用来存放项目

```sh
# 本地的ssh公钥复制到github上，
ssh -T git@github.com
cd /path/to/project
git init
git add .
git commit -m 'init'
git remote add git@github.com:<username>/<repo>.git
git push -u origin master
```

服务器操作：
```sh
# 服务器的ssh公钥复制到github上，
ssh -T git@github.com
cd /path/to/space/
git clone git@github.com:<username>/<repo>.git
cd <repo>
git add .
git commit -m 'server:init'
git remote add git@github.com:<username>/<repo>.git
git push -u origin master
# 建立存放 pm2 生成文件的文件夹
sudo mkdir /var/www/website
sudo chmod 777 /var/www/website
```

本地项目配置pm2，并对部署进行启动（在服务器建立三个文件）
```sh
cd /path/to/project
vi ecosystem.json
{
  "apps": [
    {
      "name": "MyApp",
      "script": "app.js",
      "env": {
        "COMMON_VARIABLE": "true",
      },
      "env_production": {
        "NOED_ENV": "production"
      }
    }
  ],
  "deploy": {
    "production": {
      // SSH key path, default to $HOME/.ssh
      "key": "/path/to/some.pem",
      // SSH user
      "user": "ubuntu",
      // SSH host
      "host": ["192.168.0.13"],
      "port": "<ssh-port>",
      "ref": "origin/master",
      "repo": "git@github.com:<username>/<repo>.git",
      "path": "/var/www/website",
      "ssh_options": "StrictHostKeyChecking=no",
      "env": {
        "NODE_ENV": "production"
      }
    }
  }
}
pm2 deploy ecosystem.json production setup
```

服务器查看验证：
```sh
ls /var/www/website
current shared source
# current服务器运行的文件，shared如日志文件，source是clone过来的源文件
```

本地提交并部署：
```sh
git add .
git commit -m 'add ecosystem.json'
git push origin master
pm2 deploy ecosystem.json production
```
若本地部署失败，则切换到服务器：
```sh
$ cd
$ vi .bashrc
# If not running interactively, don't do anything
#case $ in
#    *i*) ;;
#     *) return;; 
#esac
$ source .bashrc
```
本地再尝试部署：
```sh
pm2 deploy ecosystem.json production
```
Nginx 子域名转发配置文件
```sh
vi /etc/nginx/conf.d/xxx.conf
# server_name
# proxy_pass
```
防火墙端口配置
```sh
vi /etc/iptables.up.rules
input ...
output ...
```

本地传文件scp
```sh
scp -P <ssh-port> /local/file/path/ <user>@<ip>:/home/<user>/ssl/
```

删除nvm

```sh
rm -rf $NVM_DIR ~/.npm ~/.bower
```

删除nvm 在$PATH中的变量

```sh
vi ~/.bashrc
#将文件末尾的export $NVM_DIR xxx 都注释
source ~/.bashrc #生效
```

若ecosystem.config.js中加了watch:true
则若在服务器修改了配置路径中的日志，则默认启动失败，需删掉
为了使用pm2 ssh远程部署更新，且在node程序中能写入程序，最好使node、npm、pm2全局安装，且当前用户有权限直接使用（非sudo）
**准备工作：**
1. root启动pm2：在packege.json start 中，pm2-runtime 前加入sudo（为了写入文件流）
2. npm授权当前用户：由于pm2 ssh远程部署更新启动（包含npm i）不能使用sudo，故确保当前用户有权限直接使用npm（非sudo）
若全局安装后，npm i 失败：
```sh
Unhandled rejection Error: EACCES: permission denied, mkdir '/home/me/.npm/_cacache/index-v5/63/6f'
```
```sh
sudo chown -R $(whoami) ~/.npm #授权当前用户 -R files and directories recursively
sudo chown -R $(whoami):$(whoami) ~/.npm #或授权当前用户及组
```
3. pm2授权当前用户：
```sh
me@iZuf6dwb7yea1206rdub0wZ:~$ pm2 list
[PM2][ERROR] Permission denied, to give access to current user:
#$ sudo chown me:me /home/me/.pm2/rpc.sock /home/me/.pm2/pub.sock
export PM2_HOME="~/.pm2"
```
**开始**
```sh
git add . && git commit -m 'update xxx'
git push origin <branch>
pm2 deploy ecosystem.config.js production setup
pm2 deploy production update
# 执行 pm2 deploy production exec 'sudo npm start' 会失败(sudo失败)
# 到服务器项目文件夹下执行：
sudo npm start #或直接执行start语句：
sudo pm2-runtime start ecosystem.config.js --env production

scp -r -P 39999 ./dist/* me@101.132.144.238:/var/www/pixels
# 传图片
C:\Users\35398\Documents\GitHub\vue-graphql\uploads\photos>scp -r -P 39999 . me@101.132.144.238:/var/www/static/photos
```
