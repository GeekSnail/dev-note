
```sh
$ yarn create nuxt-app hi
yarn create v1.13.0
[1/4] Resolving packages...
[2/4] Fetching packages...
[3/4] Linking dependencies...
[4/4] Building fresh packages...

success Installed "create-nuxt-app@2.4.0" with binaries:
      - create-nuxt-app
> Generating Nuxt.js project in D:\35398\JavaScript\vue\cli-nuxt-koa\hi
? Project name hi
? Project description My peachy Nuxt.js project
? Use a custom server framework koa
? Choose features to install (Press <space> to select, <a> to toggle all, <i> to invert selection
)
? Use a custom UI framework element-ui
? Use a custom test framework none
? Choose rendering mode Universal
? Author name geeksnail
? Choose a package manager yarn

  To get started:

        cd hi
        yarn run dev

  To build & start for production:

        cd hi
        yarn run build
        yarn start

Done in 728.74s.

$ cd hi && yarn run dev
yarn run v1.13.0
$ cross-env NODE_ENV=development nodemon server/index.js --watch server
[nodemon] 1.18.10
[nodemon] to restart at any time, enter `rs`
[nodemon] watching: D:\35398\JavaScript\vue\cli-nuxt-koa\hi\server/**/*
[nodemon] starting `node server/index.js`
i Preparing project for development                                                   18:03:28
i Initial build may take a while                                                      18:03:28
√ Builder initialized                                                                 18:03:29
√ Nuxt files generated                                                                18:03:29
...
 READY  Server listening on http://localhost:3000 
```
安装mongoose
```sh
$ yarn add mongoose
└─ mongoose@5.4.13
```
#### server导入并初始化中间件
```
server
  └─ config
       └─ index.js
  └─ middleware
       └─ router.js
  └─ index.js
```
```js
// server/index.js
const Koa = require('koa')
const consola = require('consola')
const { Nuxt, Builder } = require('nuxt')
const R = require('ramda')
const { resolve } = require('path')

// Import and Set Nuxt.js options
let config = require('../nuxt.config.js')
config.dev = !(process.env === 'production')

const r = path => resolve(__dirname, path) // 解析绝对路径
const MIDDLEWARE = ['router']

class Server {
  constructor () {
    this.app = new Koa()
    this.useMiddlewares(this.app)(MIDDLEWARE)
  }
  useMiddlewares (app) {
    return R.map(R.compose(
      R.map(i => i(app)), // 初始化每一个中间件
      require, // 加载各模块
      i => `${r('./middleware')}/${i}` // 中间件目录+中间件名，返回绝对路径
    ))
  }
  async start () {
    // Instantiate nuxt.js
    const nuxt = new Nuxt(config)

    const {
      host = process.env.HOST || '127.0.0.1',
      port = process.env.PORT || 3000
    } = nuxt.options.server

    // Build in development
    if (config.dev) {
      const builder = new Builder(nuxt)
      await builder.build()
    }

    this.app.use(ctx => {
      ctx.status = 200
      ctx.respond = false // Bypass Koa's built-in response handling
      ctx.req.ctx = ctx // This might be useful later on, e.g. in nuxtServerInit or with nuxt-stash
      nuxt.render(ctx.req, ctx.res)
    })

    this.app.listen(port, host)
    consola.ready({
      message: `Server listening on http://${host}:${port}`,
      badge: true
    })
  }
}
const app = new Server()
app.start()
```
#### 微信公众号接口测试
https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1421135319
https://mp.weixin.qq.com/debug/cgi-bin/sandboxinfo?action=showinfo&t=sandbox/index
```js
// server/config/index.js
module.exports = {
  db: 'mongodb://localhost/<proj>',
  wechat: {
    appID: "xxxx",
    appSecret: "xxxx",
    token: "xxx" //任取
  }
}
```
```js
// server/middleware/router.js
const Router = require('koa-router')
const sha1 = require('sha1')
const config = require('../config')

exports.router = app => {
  const router = new Router()
  
  router.get('/wechat-hear', (ctx, next) => {
    const token = config.wechat.token
    const {
      signature,
      nonce,
      timestamp,
      echostr
    } = ctx.query

    const str = [token, timestamp, nonce].sort().join('')

    const sha = sha1(str)
    if (sha === signature) {
      ctx.body = echostr
    } else {
      ctx.body = "Failed"
    }

  })
  app.use(router.routes())
     .use(router.allowedMethods())
}
```
1. ngrok.cc 申请隧道，即前置域名，实现内网穿透。即本地服务器可通过域名访问
下载sunny客户端，解压，进入文件夹
```sh
> ./sunny.exe clientid <隧道id>
```
2. natapp.cn 申请隧道，下载客户端 [natapp](https://natapp.cn/article/natapp_newbie)
```sh
> ./natapp.exe --authtoken=<隧道id>
```
```sh
$ yarn add sha1
└─ sha1@1.1.1
$ yarn add ramda
└─ ramda@0.26.1
$ yarn add koa-router
└─ koa-router@7.4.0
```
[注] 1、natapp 启动后域名会变化，建议用 ngrok。2、确保能通过域名访问
https://mp.weixin.qq.com/debug/cgi-bin/sandboxinfo?action=showinfo&t=sandbox/index
在【接口配置信息】栏填入<domain>/wechat-hear，Token值与 config/index.js 的 Token参数一致，提交测试。
#### 获取access_token并入库、更新时间
![微信截图_20190301010621](C:\Users\35398\Pictures\Camera Roll\微信截图_20190301010621.png)
```
server
  └─ config
  |     └─ index.js 
  └─ database
  |     └─ schema
  |           └─ token.js
  └─ middleware
  |     └─ db.js
  |     └─ router.js
  └─ wechat-lib
  |     └─ index.js
  └─ wechat
```
1. config/index.js 配置db：'mongodb://localhost/<proj>'
2. middleware/db.js 导入schema文件，连接、启动数据库
```js
const mongoose = require('mongoose')
const config = require('../config')
const fs = require('fs')
const { resolve } = require('path')
const models = resolve(__dirname, '../database/schema')

fs.readdirSync(models)
  .filter(file => ~file.search(/^[^\.].*js$/)) //匹配js后缀的文件
  .forEach(file => require(resolve(models, file)))

exports.db = app => {
  mongoose.set('debug', true)
  mongoose.connect(config.db, { useNewUrlParser: true })
  mongoose.connection.on('disconnected', ()=>{
    mongoose.connect(config.db)
  })
  mongoose.connection.on('error', err => {
    console.error(err)
  })
  mongoose.connection.on('open', async => {
    console.log('Connected to MongoDB', config.db)
  })
}
```
3. database/schema/token.js 建立tokenSchema:获取token、保存token
```js
const mongoose = require('mongoose')

const TokenSchema = new mongoose.Schema({
  name: String,
  token: String,
  expires_in: Number,
  meta: {
    createAt: {
      type: Date,
      default: Date.now()
    },
    updatedAt: {
      type: Date,
      default: Date.now()
    }
  }
})

TokenSchema.pre('save', function (next) {
  if (this.isNew) {
    this.meta.createAt = this.meta.updatedAt = Date.now()
  } else {
    this.meta.updatedAt = Date.now()
  }
  next()
})
TokenSchema.statics = {
  async getAccessToken() {
    const token = await this.findOne({
      name: 'access_token'
    }).exec()
    if (token && token.token) {
      token.access_token = token.token
    }
    return token
  },
  async saveAccessToken(data) {
    let token = await this.findOne({
      name: 'access_token'
    }).exec()
    if (token) {
      token.token = data.access_token
      token.expires_in = data.expires_in
    } else {
      token = new Token({
        name: 'access_token',
        token: data.access_token,
        expires_in: data.expires_in
      })
    }
    await token.save()
    return data
  }
}
const Token = mongoose.model('Token', TokenSchema)
```
4. wechat-lib/index.js 封装微信获取/更新token类
[获取access_token](https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1421140183)
```js
const rp = require('request-promise')
const base = 'https://api.weixin.qq.com/cgi-bin/'
const api = {
  accessToken: base + 'token?grant_type=client_credential'
}

module.exports = class Wechat {
  constructor(opts) {
    this.opts = Object.assign({}, opts)
    this.appID = opts.appID
    this.appSecret = opts.appSecret
    this.getAccessToken = opts.getAccessToken // token.js
    this.saveAccessToken = opts.saveAccessToken // token.js
    this.fetchAccessToken()
  }
  async request (options) {
    options = Object.assign({}, options, {json: true})
    try {
      const response = await rp(options)
      console.log('res',response)
      return response
    } catch (e) {
      console.error(e)
    }
  }
  async fetchAccessToken () {
    let data = await this.getAccessToken()
    console.log('getAccessToken',data)
    if (!this.isValidAccessToken(data)) {
      data = await this.updateAccessToken()
    }
    await this.saveAccessToken(data)
    return data
  }
  async updateAccessToken () {
    const url = api.accessToken + '&appid=' + this.appID + '&secret=' + this.appSecret
    const data = await this.request({url})
    console.log('updateAccessToken',data);
    const now = (new Date().getTime())
    data.expires_in = now + (data.expires_in - 20) * 1000
    return data
  }
  isValidAccessToken (data) {
    if (!data || !data.access_token || !data.expires_in) {
      return false
    }
    const expiresIn = data.expires_in
    const now = (new Date().getTime())
    return now < expiresIn
  }
}
```
5. wechat/index.js 实例化wechat类
```js
const mongoose = require('mongoose')
const config = require('../config')
const Wechat = require('../wechat-lib')

const Token = mongoose.model('Token')
const wechatConfig = {
  wechat: {
    appID: config.wechat.appID,
    appSecret: config.wechat.appSecret,
    token: config.wechat.token,
    getAccessToken: async () => await Token.getAccessToken(),
    saveAccessToken: async (data) => await Token.saveAccessToken(data)
  }
}
module.exports = getWechat = () => {
  console.log('wechat');
  const wechatClient = new Wechat(wechatConfig.wechat)
  return wechatClient
}
getWechat()
```
6. middleware/router.js 导入wechat.js
```js
require('../wechat')
```
7. server/index.js 加入db中间件
```js
const MIDDLEWARE = ['db', 'router']
```
8. 安装依赖并启动
```sh
yarn add request-promise
yarn add request
yarn run dev 
...
Connected to MongoDB mongodb://localhost/hi
Mongoose: tokens.findOne({ name: 'access_token' }, { projection: {} })
res { access_token:
   '19_S5iu30EdLu2P23fM-g5fxa-aY_6JrtZYR-LbAzYEiSujXa1F2qV-h3YcFoH2Y9sb5BEMePwSvuMwQlGoKODypheD6H
jRvVeHsHJpHVz8wshlaWNyQ55zgd5p_yIJF3S3qRYpkIX23r__QuuJQVMcADAYDU',
  expires_in: 7200 }
```
浏览器访问localhost:3000/wechat-hear，显示 failed
```sh
Mongoose: tokens.findOne({ name: 'access_token' }, { projection: {} })
Mongoose: tokens.insertOne({ meta: { createAt: new Date("Thu, 28 Feb 2019 10:06:49 GMT"), updated
At: new Date("Thu, 28 Feb 2019 10:06:49 GMT") }, _id: ObjectId("5c77b2b906a1c22b6449331a"), name:
 'access_token', token: '19_ZcU1gml0npT4IjI-DNbif2qMhd-RP64xIcAPTjlVgFIFEAgb8Ndu3WgLtYF-OwiI_fQFa
AbK9ki-opRJT2DxXvLkwVn6IMUMYYXQt--I4UsCLhcx4CgGUU8TfB5WKI9SA4myY-J0xIxNZpNsHRAiACAZJS', expires_i
n: 1551355589828, __v: 0 })
```
#### 抽象微信消息中间件统一处理消息流——被动回复用户消息
https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1421140543
当用户发送消息给公众号时（或某些特定的用户操作引发的事件推送时），会产生一个POST请求，开发者可以在响应包（Get）中返回特定XML结构，来对该消息进行响应（现支持回复文本、图片、图文、语音、视频、音乐）。严格来说，发送被动响应消息其实并不是一种接口，而是对微信服务器发过来消息的一次回复。

![微信截图_20190301010621](C:\Users\35398\Pictures\Camera Roll\微信截图_20190301010621.png)
```
server
  └─ middleware
  |     └─ router.js
  └─ wechat
  |     └─ reply.js
  └─ wechat-lib
     └─ middleware.js
     └─ template.js
  	 └─ util.js
```
改写 /wechat-hear 路由处理
```js
// server/middleware/router.js
const Router = require('koa-router')
// const sha1 = require('sha1')
const config = require('../config')
const reply = require('../wechat/reply') // 消息回复策略
const wechatMiddle = require('../wechat-lib/middleware') // 微信消息中间件

exports.router = app => {
  const router = new Router()
  router.all('/wechat-hear', wechatMiddle(config.wechat, reply))
  
  app.use(router.routes())
     .use(router.allowedMethods())
}
```
回复文本消息测试
```js
// server/wechat/reply.js
const tip = 'hi~\n' + '点击<a href="http://coding.imooc.com">coding</a>'

module.exports = async (ctx, next) => {
  const message = ctx.weixin
  console.log(message)
  ctx.body = tip
}
```
```js
// server/wechat-lib/middleware.js
const sha1 = require('sha1')
const getRawBody = require('raw-body')
const util = require('./util')

module.exports = (opts, reply) => {
  return async function wechatMiddle(ctx, next) {
    const token = opts.token //config.wechat
    const {
      signature,
      nonce,
      timestamp,
      echostr
    } = ctx.query

    const str = [token, timestamp, nonce].sort().join('')
    const sha = sha1(str)
    if (ctx.method === 'GET') {
      if (sha === signature) {
        ctx.body = echostr
      } else {
        ctx.body = "Failed"
      }
    } else if (ctx.method === 'POST') {
      if (sha !== signature) {
        ctx.body = 'Failed'
        return false
      }

      const data = await getRawBody(ctx.req, {
        length: ctx.length,
        limit: '1mb',
        encoding: ctx.charset
      })
      const content = await util.parseXML(data)
      console.log(content)
      //const message = util.formatMessage(content.xml) // 解析成json對象
      ctx.weixin = {}
      //ctx.weixin = message
      await reply.apply(ctx, [ctx, next]) // 让上下文去调用回复策略，处理.weixin
      const replyBody = ctx.body // 获取reply.js中设置的消息
      //const msg = ctx.weixin 
      //const xml = util.tpl(replyBody, msg) //通过模板构建xml
      const xml = `<xml>
                    <ToUserName><![CDATA[${content.xml.FromUserName[0]}]]></ToUserName>
                    <FromUserName><![CDATA[${content.xml.toUserName[0]}]]></FromUserName>
                    <CreateTime>12345678</CreateTime>
                    <MsgType><![CDATA[text]]></MsgType>
                    <Content><![CDATA[replyBody]]></Content>
                  </xml>`

      ctx.status = 200
      ctx.type = 'application/xml'
      ctx.body = xml
    }
  }
}
```
xml2js 解析消息
```js
// server/wechat-lib/util.js
const xml2js = require('xml2js')

function parseXML(xml) {
  return new Promise((resolve, reject) => {
    xml2js.parseString(xml, {trim: true}, (err, content) => {
      if (err) reject(err)
      else resolve(content)
    })
  })
}
module.exports = {
  parseXML
}
```
```sh
$ yarn add raw-body xml2js
$ yarn run dev
```
https://mp.weixin.qq.com/debug/cgi-bin/sandboxinfo?action=showinfo&t=sandbox/index
关注测试号，并回复文本、图片、视频消息

```sh
{ xml:
   { ToUserName: [ 'gh_f8a6ed368293' ],
     FromUserName: [ 'oMvSd5kt0vUtNS__dbqZvqi6dBBk' ],
     CreateTime: [ '1551377172' ],
     MsgType: [ 'event' ],
     Event: [ 'subscribe' ],
     EventKey: [ '' ] } }
{}
{ xml:
   { ToUserName: [ 'gh_f8a6ed368293' ],
     FromUserName: [ 'oMvSd5kt0vUtNS__dbqZvqi6dBBk' ],
     CreateTime: [ '1551377290' ],
     MsgType: [ 'text' ],
     Content: [ '1' ],
     MsgId: [ '22210381888945194' ] } }
{}
{ xml:
   { ToUserName: [ 'gh_f8a6ed368293' ],
     FromUserName: [ 'oMvSd5kt0vUtNS__dbqZvqi6dBBk' ],
     CreateTime: [ '1551384468' ],
     MsgType: [ 'image' ],
     PicUrl:
      [ 'http://mmbiz.qpic.cn/mmbiz_jpg/RIic6Hm5wW7Jhiclctr8HEsjhRbxb3ia1rlBPxxntB7HsIe44Wxmg7fOi
cZAVaYqNF5VRdUfvhrePx1RlBhzYdwSgw/0' ],
     MsgId: [ '22210484578361772' ],
     MediaId:
      [ 'BkSHQqsetqYfM5ShElX3R356s1def5tqR8_JTtJYsSce9nKVutr1NIstt-17esIK' ] } }
{}
{ xml:
   { ToUserName: [ 'gh_f8a6ed368293' ],
     FromUserName: [ 'oMvSd5kt0vUtNS__dbqZvqi6dBBk' ],
     CreateTime: [ '1551385628' ],
     MsgType: [ 'video' ],
     MediaId:
      [ 'zJ13cIu8eAcTNoP9rm8PP78Dc-Yzo-BkyXis5PRwkdBYq9Ar250SBKVO6PgDLKfa' ],
     ThumbMediaId:
      [ 'Hl8l10iq6FdsmwuQyj1OJ9vt989BIugqz-TdgE4Sk87_ltK_NNnsb9Q4uqjvACkm' ],
     MsgId: [ '22210504245182870' ] } }
{}
```
#### 微信消息解析与回复模块封装
1. 修改 server/wechat-lib/middleware.js
```js
const content = await util.parseXML(data)
console.log('parseXML',content)
const message = util.formatMessage(content.xml) // 格式化为json對象

ctx.weixin = message
await reply.apply(ctx, [ctx, next]) // 让上下文去调用回复策略
const replyBody = ctx.body
const msg = ctx.weixin
const xml = util.tpl(replyBody, msg) //构建xml

ctx.status = 200
ctx.type = 'application/xml'
ctx.body = xml
```
2. 将parseXML处理后的数据格式化为类似json对象
```js
// server/wechat-lib/util.js
const xml2js = require('xml2js')
const template = require('./template')

function parseXML(xml) {
  ......
}
function formatMessage (result) {
  let messasge = {}
  if (typeof result === 'object') {
    const keys = Object.keys(result)
    for (let i = 0; i < keys.length; i++) {
      let item = result[keys[i]] // 值是数组
      let key = keys[i]

      if (!(item instanceof Array) || item.length === 0) {
        continue //不是数组或长度为0时跳过
      }
      if (item.length === 1) {
        let val = item[0]
        if (typeof val === 'object') {
          message[key] = formatMessage(val) //值为object类型，则循环调用
        } else {
          messasge[key] = (val || '').trim()
        }
      } else {
        messasge[key] = []
        for (let i = 0; j < item.length; i++) {
          messasge[key].push(formatMessage(item[i]))
        }
      }
    }
  }
  return messasge
}
function tpl (content, message) {
  let type = 'text' //设置默认消息type
  if (Array.isArray(content)) {
    type = 'news'
  }
  if (!content) {
    content = 'Empty News'
  }
  if (content && content.type) {
    type = content.type
  }
  let info = Object.assign({}, {
    content,
    createTime: new Date().getTime(),
    msgType: type,
    toUserName: message.FromUserName,
    fromUserName: message.ToUserName
  })
  return template(info)
}
module.exports = {
  parseXML,
  formatMessage,
  tpl
}
```
3. 封装消息回复模板
https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1421140543

```js
const ejs = require('ejs')

const template = `
  <xml>
    <ToUserName><![CDATA[<%= toUserName %>]]></ToUserName>
    <FromUserName><![CDATA[<%= fromUserName %>]]></FromUserName>
    <CreateTime><%= createTime %></CreateTime>
    <MsgType><![CDATA[<%= msgType %>]]></MsgType>
    <% if (msgType === 'text') { %>
      <Content><![CDATA[<%- content %>]]></Content>
    <% } else if (msgType === 'image') { %>  
      <Image>
        <MediaId><![CDATA[<%= content.mediaId %>]]></MediaId>
      </Image>
    <% } else if (msgType === 'voice') { %>  
      <Voice>
        <MediaId><![CDATA[<%= content.mediaId %>]]></MediaId>
      </Voice>      
    <% } else if (msgType === 'video') { %>  
      <Video>
        <MediaId><![CDATA[<%= content.mediaId %>]]></MediaId>
        <Title><![CDATA[<%= content.title %>]]></Title>
        <Description><![CDATA[<%= content.description %>]]></Description>
      </Video>      
    <% } else if (msgType === 'music') { %>    
      <Music>
        <Title><![CDATA[<%= content.title %>]]></Title>
        <Description><![CDATA[<%= content.description %>]]></Description>
        <MusicUrl><![CDATA[<%= content.musicUrl %>]]></MusicUrl>
        <HQMusicUrl><![CDATA[<%= content.hqMusicUrl %>]]></HQMusicUrl>
        <ThumbMediaId><![CDATA[<%= content.thumbMediaId %>]]></ThumbMediaId>
      </Music>      
    <% } else if (msgType === 'news') { %>
      <ArticleCount><%= content.length %></ArticleCount>
      <Articles>
        <% content.forEach(function(item) { %>
          <item>
            <Title><![CDATA[<%= item.title %>]]></Title>
            <Description><![CDATA[<%= item.description %>]]></Description>
            <PicUrl><![CDATA[<%= item.picUrl %>]]></PicUrl>
            <Url><![CDATA[<%= item.url %>]]></Url>
          </item>
        <% }) %>
      </Articles>    
    <% } %>  
  </xml>`

const compiled = ejs.compile(template)
module.exports = compiled
```
https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1421140453
```sh
$ yarn add ejs
```
4. 消息回复策略测试，包括普通消息回复、事件推送
https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1421140453
```js
// server/wechat/reply.js
const tip = 'hi~\n' + '点击<a href="http://coding.imooc.com">coding</a>'
 
module.exports = async (ctx, next) => {
  const message = ctx.weixin
  console.log(message)

  if (message.MsgType === 'event') {
    if (message.Event === 'subscribe') {
      ctx.body = tip
    } else if (message.Event === 'unsubscribe') {
      console.log(message.FromUserName,'取关了')
    } else if (message.Event === 'Location') {
      ctx.body = message.Latitude + ' : ' + message.Longtitude
    }
  } else if (message.MsgType === 'text') {
    ctx.body = message.Content
  } else if (message.MsgType === 'image') {
    ctx.body = {
      type: 'image',
      mediaId: message.MediaId
    }
  } else if (message.MsgType === 'voice') {
    ctx.body = {
      type: 'voice',
      mediaId: message.MediaId
    }
  } else if (message.MsgType === 'video') {
    ctx.body = {
      title: message.ThumbMediaId,
      type: 'video',
      mediaId: message.MediaId
    }
  } else if (message.MsgType === 'location') {
    ctx.body = message.Location_X + ' : ' + message.Location_Y + ' : ' + message.Label
  } else if (message.MsgType === 'link') {
    ctx.body = [{
      title: message.Title,
      description: message.Description,
      picUrl: 'http://mmbiz.qpic.cn/mmbiz_jpg/RIic6Hm5wW7IQiaFRuUkehGYjtHe5skvynKmhjxmU7kVGXaSiboqojEQCon7gc\n' +
        'IZtpClCKLYGE4p2NBZAbNial1Wgw/0',
      url: message.Url
    }]
  }
}
```
【注】link类型消息接收时无PicUrl字段
5. 测试文本、图片、视频、位置、链接回复、关注/取关事件
```xml
{ ToUserName: 'gh_f8a6ed368293',
  FromUserName: 'oMvSd5kt0vUtNS__dbqZvqi6dBBk',
  CreateTime: '1551452396',
  MsgType: 'text',
  Content: '哈哈',
  MsgId: '22211457578749518' }

  <xml>
    <ToUserName><![CDATA[oMvSd5kt0vUtNS__dbqZvqi6dBBk]]></ToUserName>
    <FromUserName><![CDATA[gh_f8a6ed368293]]></FromUserName>
    <CreateTime>1551452400122</CreateTime>
    <MsgType><![CDATA[text]]></MsgType>
      <Content><![CDATA[哈哈]]></Content>
  </xml>
{ ToUserName: 'gh_f8a6ed368293',
  FromUserName: 'oMvSd5kt0vUtNS__dbqZvqi6dBBk',
  CreateTime: '1551452426',
  MsgType: 'image',
  PicUrl:   'http://mmbiz.qpic.cn/mmbiz_jpg/RIic6Hm5wW7IQiaFRuUkehGYjtHe5skvynKmhjxmU7kVGXaSiboqojEQCon7gc
IZtpClCKLYGE4p2NBZAbNial1Wgw/0',
  MsgId: '22211459765800517',
  MediaId:
   'BJMIQCrC3pfLqQI2clnYNw4I28jTY-l7iAdz8xLqM6LopAJx63FoKUFLPZuM0tdW' }

  <xml>
    <ToUserName><![CDATA[oMvSd5kt0vUtNS__dbqZvqi6dBBk]]></ToUserName>
    <FromUserName><![CDATA[gh_f8a6ed368293]]></FromUserName>
    <CreateTime>1551452429126</CreateTime>
    <MsgType><![CDATA[image]]></MsgType>

      <Image>
        <MediaId><![CDATA[BJMIQCrC3pfLqQI2clnYNw4I28jTY-l7iAdz8xLqM6LopAJx63FoKUFLPZuM0tdW]]></Me
diaId>
      </Image>
  </xml>
{ ToUserName: 'gh_f8a6ed368293',
  FromUserName: 'oMvSd5kt0vUtNS__dbqZvqi6dBBk',
  CreateTime: '1551452452',
  MsgType: 'video',
  MediaId:
   'L0u79XZL3WlJ02saTcfTdb1EeEropBi0q3Ln3JZux3iOKdL-U3486IWgnYTuiGUg',
  ThumbMediaId:
   'wJdxY-U3FoCaKir-shWBJidEh33Jf8qvZoaegUKA-diCSFKZByFgWb9RyLMFXJQZ',
  MsgId: '22211460000436810' }

  <xml>
    <ToUserName><![CDATA[oMvSd5kt0vUtNS__dbqZvqi6dBBk]]></ToUserName>
    <FromUserName><![CDATA[gh_f8a6ed368293]]></FromUserName>
    <CreateTime>1551452455364</CreateTime>
    <MsgType><![CDATA[video]]></MsgType>
      <Video>
        <MediaId><![CDATA[L0u79XZL3WlJ02saTcfTdb1EeEropBi0q3Ln3JZux3iOKdL-U3486IWgnYTuiGUg]]></Me
diaId>
        <Title><![CDATA[wJdxY-U3FoCaKir-shWBJidEh33Jf8qvZoaegUKA-diCSFKZByFgWb9RyLMFXJQZ]]></Titl
e>
        <Description><![CDATA[]]></Description>
      </Video>
  </xml>
{ ToUserName: 'gh_f8a6ed368293',
  FromUserName: 'oMvSd5kt0vUtNS__dbqZvqi6dBBk',
  CreateTime: '1551453034',
  MsgType: 'voice',
  MediaId:
   'rk0rILlAiQfBzdZVjORYGaLT3pmIixTaQTVB5-OzNK6pxPcLi5gBWppsJscEVpKK',
  Format: 'amr',
  MsgId: '22211470075366286',
  Recognition: '' }

  <xml>
    <ToUserName><![CDATA[oMvSd5kt0vUtNS__dbqZvqi6dBBk]]></ToUserName>
    <FromUserName><![CDATA[gh_f8a6ed368293]]></FromUserName>
    <CreateTime>1551453036136</CreateTime>
    <MsgType><![CDATA[voice]]></MsgType>

      <Voice>
        <MediaId><![CDATA[rk0rILlAiQfBzdZVjORYGaLT3pmIixTaQTVB5-OzNK6pxPcLi5gBWppsJscEVpKK]]></Me
diaId>
      </Voice>

  </xml>
{ ToUserName: 'gh_f8a6ed368293',
  FromUserName: 'oMvSd5kt0vUtNS__dbqZvqi6dBBk',
  CreateTime: '1551453070',
  MsgType: 'location',
  Location_X: '27.829149',
  Location_Y: '121.145042',
  Scale: '16',
  Label: '浙江省温州市洞头区',
  MsgId: '22211469893781070' }

  <xml>
    <ToUserName><![CDATA[oMvSd5kt0vUtNS__dbqZvqi6dBBk]]></ToUserName>
    <FromUserName><![CDATA[gh_f8a6ed368293]]></FromUserName>
    <CreateTime>1551453072841</CreateTime>
    <MsgType><![CDATA[text]]></MsgType>
      <Content><![CDATA[27.829149 : 121.145042 : 浙江省温州市洞头区]]></Content>
  </xml>
{ ToUserName: 'gh_f8a6ed368293',
  FromUserName: 'oMvSd5kt0vUtNS__dbqZvqi6dBBk',
  CreateTime: '1551453126',
  MsgType: 'link',
  Title: '漫画：什么是动态规划？（整合版）',
  Description: '漫画：什么是动态规划？（整合版）',
  Url:
   'http://mp.weixin.qq.com/s?__biz=MzI1MTIzMzI2MA==&mid=2650561168&idx=1&sn=9d1c6f7ba6d651c75399
c4aa5254a7d8&chksm=f1feec13c6896505f7886d9455278ad39749d377a63908c59c1fdceb11241e577ff6d66931e4&m
pshare=1&scene=24&srcid=1006MIKJHAWLbruE1h1UGRLY#rd',
  MsgId: '22211468626513515' }

  <xml>
    <ToUserName><![CDATA[oMvSd5kt0vUtNS__dbqZvqi6dBBk]]></ToUserName>
    <FromUserName><![CDATA[gh_f8a6ed368293]]></FromUserName>
    <CreateTime>1551453131385</CreateTime>
    <MsgType><![CDATA[news]]></MsgType>

      <ArticleCount>1</ArticleCount>
      <Articles>
          <item>
            <Title><![CDATA[漫画：什么是动态规划？（整合版）]]></Title>
            <Description><![CDATA[漫画：什么是动态规划？（整合版）]]></Description>
            <PicUrl><![CDATA[http://mmbiz.qpic.cn/mmbiz_jpg/RIic6Hm5wW7IQiaFRuUkehGYjtHe5skvynKmh
jxmU7kVGXaSiboqojEQCon7gc
IZtpClCKLYGE4p2NBZAbNial1Wgw/0]]></PicUrl>
            <Url><![CDATA[http://mp.weixin.qq.com/s?__biz=MzI1MTIzMzI2MA==&amp;mid=2650561168&amp
;idx=1&amp;sn=9d1c6f7ba6d651c75399c4aa5254a7d8&amp;chksm=f1feec13c6896505f7886d9455278ad39749d377
a63908c59c1fdceb11241e577ff6d66931e4&amp;mpshare=1&amp;scene=24&amp;srcid=1006MIKJHAWLbruE1h1UGRL
Y#rd]]></Url>
          </item>
      </Articles>
  </xml>

{ ToUserName: 'gh_f8a6ed368293',
  FromUserName: 'oMvSd5kt0vUtNS__dbqZvqi6dBBk',
  CreateTime: '1551456173',
  MsgType: 'event',
  Event: 'unsubscribe',
  EventKey: '' }
oMvSd5kt0vUtNS__dbqZvqi6dBBk 取关了

  <xml>
    <ToUserName><![CDATA[oMvSd5kt0vUtNS__dbqZvqi6dBBk]]></ToUserName>
    <FromUserName><![CDATA[gh_f8a6ed368293]]></FromUserName>
    <CreateTime>1551456181597</CreateTime>
    <MsgType><![CDATA[text]]></MsgType>

      <Content><![CDATA[Empty News]]></Content>

  </xml>
{ ToUserName: 'gh_f8a6ed368293',
  FromUserName: 'oMvSd5kt0vUtNS__dbqZvqi6dBBk',
  CreateTime: '1551456189',
  MsgType: 'event',
  Event: 'subscribe',
  EventKey: '' }

  <xml>
    <ToUserName><![CDATA[oMvSd5kt0vUtNS__dbqZvqi6dBBk]]></ToUserName>
    <FromUserName><![CDATA[gh_f8a6ed368293]]></FromUserName>
    <CreateTime>1551456196412</CreateTime>
    <MsgType><![CDATA[text]]></MsgType>

      <Content><![CDATA[hi~
点击<a href="http://coding.imooc.com">coding</a>]]></Content>
  </xml>
```
【注】测试发现视频无法回复

```sh
Mongoose: tokens.findOne({ name: 'access_token' }, { projection: {} })
Mongoose: tokens.findOne({ name: 'access_token' }, { projection: {} })
getAccessToken { meta:
   { createAt: 2019-02-28T16:41:01.210Z,
     updatedAt: 2019-03-01T19:57:25.011Z },
  _id: 5c780f1d03785379f0d16889,
  name: 'access_token',
  token:
   '19_DPxkDiQOukF1yyWCo04fwyIXWiczIwwLr6UOQ8t1pCvhWcHGMXU71hfKanzHYJUgjNDHMS2ELc05qX_5I3BMIcuB0L
qq73rZQZTq0AvuD1eq1nT-UUH0NXdb4oth9OpIktQVMRi2Ih5WxdM6ILZbAIAVYM',
  expires_in: 1551476879869,
  __v: 0 }
Mongoose: tokens.findOne({ name: 'access_token' }, { projection: {} })
Mongoose: tokens.updateOne({ _id: ObjectId("5c780f1d03785379f0d16889") }, { '$set': { 'meta.updatedAt': new Date("Fri, 01 Mar 2019 19:58:40 GMT") } })
Mongoose: tokens.updateOne({ _id: ObjectId("5c780f1d03785379f0d16889") }, { '$set': { 'meta.updat
edAt': new Date("Fri, 01 Mar 2019 19:58:40 GMT") } })
{ type: 'video',
  media_id:
   '1nQCOB7mqgwyccg7mPXXZHaAp5dvwUCUc0H0t6SI6Fe64GRe7kY506QrNdV6Pinv',
  created_at: 1551470322 }

```
#### 用户基本信息
获取用户列表GET 
https://api.weixin.qq.com/cgi-bin/user/get?access_token=ACCESS_TOKEN&next_openid=NEXT_OPENID

```js
// server/wechat/reply.js
module.exports = async (ctx, next) => {
  const message = ctx.weixin
  console.log(message)

  let mp = require('../wechat')
  let client = mp.getWechat()

  if (message.MsgType === 'event') {
    ......
  }  else if (message.MsgType === 'text') {
    if (message.Content === '1') {
      // test fetchUserList
      const data = await client.handle('fetchUserList')
      console.log('reply', data)
    }
    ctx.body = message.Content
  }
......  
```
```sh
{ total: 2,
  count: 2,
  data:
   { openid:
      [ 'oMvSd5kt0vUtNS__dbqZvqi6dBBk',
        'oMvSd5v8n80Gimx0nKQqcBtqAV14' ] },
  next_openid: 'oMvSd5v8n80Gimx0nKQqcBtqAV14' }
```
批量获取用户信息POST
https://api.weixin.qq.com/cgi-bin/user/get?access_token=ACCESS_TOKEN&next_openid=NEXT_OPENID
```js
// server/wechat/reply.js
  else if (message.MsgType === 'text') {
    if (message.Content === '1') {
      // test batchUserInfo
      let userList = [
        {
          openid: 'oMvSd5kt0vUtNS__dbqZvqi6dBBk',
          lang: 'zh_CN'
        },{
          openid: 'oMvSd5v8n80Gimx0nKQqcBtqAV14',
          lang: 'zh_CN'
        }]
      const data = await client.handle('batchUserInfo', userList)
      console.log('reply', data)
    }
    ctx.body = message.Content
  }
```
```sh
{ user_info_list:
   [ { subscribe: 1,
       openid: 'oMvSd5kt0vUtNS__dbqZvqi6dBBk',
       nickname: '蛋糕店的夏天',
       sex: 1,
       language: 'zh_CN',
       city: '温州',
       province: '浙江',
       country: '中国',
       headimgurl:
        'http://thirdwx.qlogo.cn/mmopen/StgoZwMzBf5RgLuavgp0kMzef3OjqdQOGu5jcG6flpMsc3uh4mMdHo
4xaTb8vyoFnY6vaOdp1OrOkTKIiagkYsxq079eG0LFib/132',
       subscribe_time: 1551523316,
       remark: '',
       groupid: 0,
       tagid_list: [],
       subscribe_scene: 'ADD_SCENE_SEARCH',
       qr_scene: 0,
       qr_scene_str: '' },
     ... ] }
```
#### 用户标签管理
创建标签POST
https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1421140837
```js
// server/wechat/reply.js
if (message.Content === '1') {
  // test createTag
  const data = await client.handle('createTag', 'family')
  console.log('reply', data)
}
```
```sh
{ tag: { id: 100, name: 'family' } }
```
获取公众号已创建的标签GET
```js
// server/wechat/reply.js
if (message.Content === '1') {
  // test fetchTags
  const data = await client.handle('fetchTags')
  console.log('reply', data)
}
```
```sh
{ tags:
   [ { id: 2, name: '星标组', count: 0 },
     { id: 100, name: 'family', count: 0 } ] }
```
批量为用户打标签POST
```js
// test batchTag
const data = await client.handle('batchTag', ['oMvSd5kt0vUtNS__dbqZvqi6dBBk'], 100)
```
```sh
{ errcode: 0, errmsg: 'ok' }
```
获取用户身上的标签列表POST
```js
// test getTagList
const data = await client.handle('getTagList', 'oMvSd5kt0vUtNS__dbqZvqi6dBBk') 
```
```sh
{ tagid_list: [ 100 ] }
```