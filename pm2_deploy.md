## pm2 部署 nodejs 应用

本地操作：
github.com 建立一个私有仓库，用来存放项目
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

本地项目配置pm2，并启动部署：
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
      "repo": "git@git.github.com:<username>/<repo>.git",
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

本地再部署：
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
本地再尝试部署发布：
```sh
pm2 deploy ecosystem.json production
```