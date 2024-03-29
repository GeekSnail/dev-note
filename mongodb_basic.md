## MongoDB Basic

### 基本使用

```js
show dbs
use <db>
db
// 删除当前数据库，默认test
db.dropDatabase()
// 查看集合
show tables
show collections
// 删除集合
db.<collection>.drop()
// 创建集合
db.createCollection(name, [options])
// 创建固定集合 mycol，整个集合空间大小 6142800 KB, 文档最大个数为 10000 个。
db.createCollection('mycol', {capped: true, size: 6142800, max: 10000})
// 插入文档
db.<collection>.insert(<document>)
db.test.insert({'name':'jack'})
// 查看已插入文档
db.<collection>.find()
// save()不指定_id类似insert(),若指定_id字段，则更新_id数据
db.<collection>.save(<document>)
```
### 更新文档

#### update()

```js
db.collection.update(
   <query>,
   <update>,
   {
     upsert: <boolean>,
     multi: <boolean>,
     writeConcern: <document>
   }
)
```
参数说明：
- query : update的查询条件，类似sql update查询内where后面的。
- update : update的对象和一些更新的操作符（如$,$inc...）等，也可以理解为sql update查询内set后面的
- upsert : 可选，这个参数的意思是，如果不存在update的记录，是否插入objNew,true为插入，默认是false，不插入。
- multi : 可选，mongodb 默认是false,只更新找到的第一条记录，如果这个参数为true,就把按条件查出来多条记录全部更新。
- writeConcern :可选，抛出异常的级别。

```js
> db.user.update({'name': 'jack'}, {$set: {'name': 'Lee'}})
WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })
> db.user.find()
{ "_id" : ObjectId("5c61189a56b2f401e8cec0fd"), "name" : "Lee", "title" : "Lee" }
> db.user.find().pretty()
{
        "_id" : ObjectId("5c61189a56b2f401e8cec0fd"),
        "name" : "Lee",
}
```
以上语句只会修改第一条发现的文档，如果要修改多条相同的文档，则需要设置 multi 参数为 true。
```sh
db.col.update({'title':'MongoDB 教程'},{$set:{'title':'MongoDB'}},{multi:true})
```
#### save()
`save()` 方法通过传入的文档来替换已有文档。语法格式：

```sh
db.collection.save(
   <document>,
   {
     writeConcern: <document>
   }
)
```
参数说明：

- document : 文档数据。

- writeConcern :可选，抛出异常的级别。

```js
// 只更新第一条记录：
db.col.update( { "count" : { $gt : 1 } } , { $set : { "test2" : "OK"} } );
// 全部更新：
db.col.update( { "count" : { $gt : 3 } } , { $set : { "test2" : "OK"} },false,true );
// 只添加第一条：
db.col.update( { "count" : { $gt : 4 } } , { $set : { "test5" : "OK"} },true,false );
// 全部添加进去:
db.col.update( { "count" : { $gt : 5 } } , { $set : { "test5" : "OK"} },true,true );
// 全部更新：
db.col.update( { "count" : { $gt : 15 } } , { $inc : { "count" : 1} },false,true );
// 只更新第一条记录：
db.col.update( { "count" : { $gt : 10 } } , { $inc : { "count" : 1} },false,false );
```
### 删除文档 remove()
```js
db.<collection>.remove(
  <query>,
  {
    justOne: <boolean>,
    writeConcern: <document>
  }
}
```
参数说明：
- query :（可选）删除的文档的条件{key: value}。
- justOne : （可选）如果设为 true 或 1，则只删除一个文档，如果不设置该参数，或使用默认值 false，则删除所有匹配条件的文档。
- writeConcern :（可选）抛出异常的级别。

删除集合所有文档
```js
db.<collection>.remove({})
```
### 查询文档 find()
```js
db.collection.find(query, projection)
```
- query ：可选，使用查询操作符指定查询条件
- projection ：可选，使用投影操作符指定返回的键。查询时返回文档中所有键值， 只需省略该参数即可（默认省略）。

pretty() 方法以格式化的方式来显示所有文档。
```js
db.col.find().pretty()
```
例：
```js
> db.user.find({})
{ "_id" : ObjectId("5c61189a56b2f401e8cec0fd"), "name" : "Lee", "title" : "Lee" }
{ "_id" : ObjectId("5c612ea656b2f401e8cec0fe"), "name" : "jack" }
{ "_id" : ObjectId("5c612eef56b2f401e8cec0ff"), "name" : "Cats", "age" : 23 }
> db.user.find({},{'name':1,_id:0})
{ "name" : "Lee" }
{ "name" : "jack" }
{ "name" : "Cats" }
> db.user.find({},{'name':1})
{ "_id" : ObjectId("5c61189a56b2f401e8cec0fd"), "name" : "Lee" }
{ "_id" : ObjectId("5c612ea656b2f401e8cec0fe"), "name" : "jack" }
{ "_id" : ObjectId("5c612eef56b2f401e8cec0ff"), "name" : "Cats" }
> db.user.find({},{'name':0})
{ "_id" : ObjectId("5c61189a56b2f401e8cec0fd"), "title" : "Lee" }
{ "_id" : ObjectId("5c612ea656b2f401e8cec0fe") }
{ "_id" : ObjectId("5c612eef56b2f401e8cec0ff"), "age" : 23 }
```

`findOne()` 方法，只返回一个文档

### MongoDB 与 RDBMS Where 语句比较

|操作	|格式	|范例	|RDBMS中的类似语句|
|-|-|-|-|
|等于	|`{<key>:<value>}`	|`db.col.find({"by":"菜鸟教程"}).pretty()`	|`where by = '菜鸟教程'`|
|小于	|`{<key>:{$lt:<value>}}`	|`db.col.find({"likes":{$lt:50}}).pretty()`	|`where likes < 50`|
|小于或等于	|`{<key>:{$lte:<value>}}`|	`db.col.find({"likes":{$lte:50}}).pretty()`	|`where likes <= 50`|
|大于	|`{<key>:{$gt:<value>}}`	|`db.col.find({"likes":{$gt:50}}).pretty()`	|`where likes > 50`|
|大于或等于	|`{<key>:{$gte:<value>}}` 	|`db.col.find({"likes":{$gte:50}}).pretty()`	|`where likes >= 50`|
|不等于	|`{<key>:{$ne:<value>}}`	|`db.col.find({"likes":{$ne:50}}).pretty()`	|`where likes != 50` |

#### AND 条件

MongoDB 的 `find()` 方法可以传入多个键(key)，每个键(key)以逗号隔开，即常规 SQL 的 `AND` 条件。
```js
db.col.find({key1:value1, key2:value2}).pretty()
```
类似于 `WHERE` 语句：`WHERE key1='value1' AND title='value2'`
#### OR 条件 
关键字 `$or`
```js
db.col.find(
   {
      $or: [
         {key1: value1}, {key2:value2}
      ]
   }
).pretty()
```
#### AND 和 OR 联合使用
类似常规 SQL 语句为： `where likes>50 AND (by = '菜鸟教程' OR title = 'MongoDB 教程')`
```js
db.col.find({"likes": {$gt:50}, $or: [{"by": "菜鸟教程"},{"title": "MongoDB 教程"}]}).pretty()
```
### 条件操作符
条件操作符用于比较两个表达式并从mongoDB集合中查询获取数据。
```
(>) 大于 - $gt
(<) 小于 - $lt
(>=) 大于等于 - $gte
(<= ) 小于等于 - $lte
```
#### $type 条件操作符
`$type` 条件操作符是基于BSON类型来检索集合中匹配的数据类型，并返回结果。

|类型	|数字|
|-|-|
|Double	|1|
|String	|2|
|Object	|3|
|Array	|4|
|Binary data|	5|
|Object id|	7|
|Boolean |8  |
|Date	|9 |
|Null	|10  |
|Regular Expression|	11  |
|JavaScript	|13 |
|Symbol	| 14 |
|JavaScript (with scope)|	15	 |
|32-bit integer	|16	 |
|Timestamp	|17	 |
|64-bit integer	|18	 |

#### Limit()
读取指定数量的数据记录，`limit()` 方法接受一个数字参数，该参数指定从MongoDB中读取的记录条数。
```js
db.<collection>.find().limit(NUMBER)
```
例：
```js
> db.user.find({},{'name':1,_id:0}).limit(2)
```
#### Skip()
除了可以使用 `limit()` 方法来读取指定数量的数据外，还可以使用 `skip()` 方法来跳过指定数量的数据，skip 方法同样接受一个数字参数作为跳过的记录条数。
```js
db.<collection>.find().limit(NUMBER).skip(NUMBER)
```
例：显示第二条文档数据
```js
>db.col.find({},{"title":1,_id:0}).limit(1).skip(1)
```
注：`skip()` 方法默认参数为 0 
### 排序 sort()
`sort()` 方法可以通过参数指定排序的字段，并使用 1 和 -1 来指定排序的方式，其中 1 为升序排列，而 -1 是用于降序排列

```js
db.<collection>.find().sort({KEY:1})
```
注：`skip(), limilt(), sort()` 三个放在一起执行的时候，执行的顺序是先 `sort()`, 然后是 `skip()`，最后是显示的 `limit()`

###索引
索引通常能够极大的提高查询的效率，如果没有索引，MongoDB在读取数据时必须扫描集合中的每个文件并选取那些符合查询条件的记录。

索引是特殊的数据结构，索引存储在一个易于遍历读取的数据集合中，索引是对数据库表中一列或多列的值进行排序的一种结构

#### 创建索引 createIndex()
```js
db.<collection>.createIndex(keys, options)
```
语法中 Key 值为你要创建的索引字段，1 为指定按升序创建索引，如果你想按降序来创建索引指定为 -1 即可。

```js
>db.col.createIndex({"title":1})
```
`createIndex()` 方法中你也可以设置使用多个字段创建索引（关系型数据库中称作复合索引）。

```js
>db.col.createIndex({"title":1,"description":-1})
```

|Parameter	|Type	|Description|
|-|-|-|
|background	|Boolean	|建索引过程会阻塞其它数据库操作，background可指定以后台方式创建索引，可选，"background" 默认false。|
|unique	|Boolean	|建立的索引是否唯一。默认值为false.|
|name	|string	|索引的名称。如果未指定，MongoDB的通过连接索引的字段名和排序顺序生成一个索引名称。|
|sparse	|Boolean	|对文档中不存在的字段数据不启用索引；这个参数需要特别注意，如果设置为true的话，在索引字段中不会查询出不包含对应字段的文档.。默认值为 false.|
|expireAfterSeconds	|integer	|指定一个以秒为单位的数值，完成 TTL设定，设定集合的生存时间。|
|v	|index version	|索引的版本号。默认的索引版本取决于mongod创建索引时运行的版本。|
|weights	|document	|索引权重值，数值在 1 到 99,999 之间，表示该索引相对于其他索引字段的得分权重。|
|default_language	|string	|对于文本索引，该参数决定了停用词及词干和词器的规则的列表。 默认为英语|
|language_override	|string	|对于文本索引，该参数指定了包含在文档中的字段名，语言覆盖默认的language，默认值为 language.|

```js
db.values.createIndex({open: 1, close: 1}, {background: true})
```
- 查看集合索引 `db.col.getIndexes()`

- 查看集合索引大小 `db.col.totalIndexSize()`

- 删除集合所有索引 `db.col.dropIndexes()`

- 删除集合指定索引 `db.col.dropIndex("索引名称")`

```js
> db.user.find({})
{ "_id" : ObjectId("5c61189a56b2f401e8cec0fd"), "name" : "Lee", "title" : "Lee", "age" : 18 }
{ "_id" : ObjectId("5c612ea656b2f401e8cec0fe"), "name" : "jack", "age" : 27 }
{ "_id" : ObjectId("5c612eef56b2f401e8cec0ff"), "name" : "Cats", "age" : 23 }
> db.user.createIndex({'name':1})
{
        "createdCollectionAutomatically" : false,
        "numIndexesBefore" : 1,
        "numIndexesAfter" : 2,
        "ok" : 1
}
> db.user.createIndex({'age':1})
{
        "createdCollectionAutomatically" : false,
        "numIndexesBefore" : 2,
        "numIndexesAfter" : 3,
        "ok" : 1
}
> db.user.getIndexes()
[
        {
                "v" : 2,
                "key" : {
                        "_id" : 1
                },
                "name" : "_id_",
                "ns" : "test.user"
        },
        {
                "v" : 2,
                "key" : {
                        "name" : 1
                },
                "name" : "name_1",
                "ns" : "test.user"
        },
        {
                "v" : 2,
                "key" : {
                        "age" : 1
                },
                "name" : "age_1",
                "ns" : "test.user"
        }
]
> db.user.totalIndexSize()
69632
> db.user.dropIndex('name_1')
{ "nIndexesWas" : 3, "ok" : 1 }
> db.user.dropIndex('age_1')
{ "nIndexesWas" : 2, "ok" : 1 }
> db.user.createIndex({'name':1, 'age':1})
{
        "createdCollectionAutomatically" : false,
        "numIndexesBefore" : 1,
        "numIndexesAfter" : 2,
        "ok" : 1
}
> db.user.getIndexes()
[
        {
                "v" : 2,
                "key" : {
                        "_id" : 1
                },
                "name" : "_id_",
                "ns" : "test.user"
        },
        {
                "v" : 2,
                "key" : {
                        "name" : 1,
                        "age" : 1
                },
                "name" : "name_1_age_1",
                "ns" : "test.user"
        }
]
```
### 聚合 aggregate()
MongoDB中聚合(aggregate)主要用于处理数据(诸如统计平均值,求和等)，并返回计算后的数据结果。有点类似 sql 语句中的 `count(*)`。
```js
db.COLLECTION_NAME.aggregate(AGGREGATE_OPERATION)
```
例：以age域分组，计算各age组的人数（文档数）
```js
> db.user.find()
{ "_id" : ObjectId("5c61189a56b2f401e8cec0fd"), "name" : "Lee", "title" : "Lee", "age" : 18 }
{ "_id" : ObjectId("5c612ea656b2f401e8cec0fe"), "name" : "jack", "age" : 23 }
{ "_id" : ObjectId("5c612eef56b2f401e8cec0ff"), "name" : "Cats", "age" : 23 }
> db.user.aggregate([{$group: {_id: '$age', num: {$sum: 1}}}])
{ "_id" : 23, "num" : 2 }
{ "_id" : 18, "num" : 1 }
```
类似sql语句：
```
select age, count(*) from user group by age
```
|表达式	|描述	|实例|
|-|-|-|
|$sum | 计算总和 |`db.mycol.aggregate([{$group : {_id : "$by_user", num : {$sum : "$likes"}}}])`|
|$avg | 计算平均值 |`db.mycol.aggregate([{$group : {_id : "$by_user", num: {$avg : "$likes"}}}])`|
|$min | 获取集合中所有文档对应值得最小值 | `db.mycol.aggregate([{$group : {_id : "$by_user", num : {$min : "$likes"}}}])` |
|$max | 获取集合中所有文档对应值得最大值 | `db.mycol.aggregate([{$group : {_id : "$by_user", num : {$max : "$likes"}}}])` |
|$push | 在结果文档中插入值到一个数组中 | `db.mycol.aggregate([{$group : {_id : "$by_user", url : {$push: "$url"}}}])` |
|$addToSet | 在结果文档中插入值到一个数组中，但不创建副本	| `db.mycol.aggregate([{$group : {_id : "$by_user", url : {$addToSet : "$url"}}}])` |
|$first	| 根据资源文档的排序获取第一个文档数据 | `db.mycol.aggregate([{$group : {_id : "$by_user", first_url : {$first : "$url"}}}])` |
|$last | 根据资源文档的排序获取最后一个文档数据 | `db.mycol.aggregate([{$group : {_id : "$by_user", last_url : {$last : "$url"}}}])` |

```js
> db.user.find()
{ "_id" : ObjectId("5c61189a56b2f401e8cec0fd"), "weight" : 60, "age" : 24, "name" : "Cats" }
{ "_id" : ObjectId("5c612ea656b2f401e8cec0fe"), "weight" : 70, "age" : 24, "name" : "Lee" }
{ "_id" : ObjectId("5c612eef56b2f401e8cec0ff"), "weight" : 80, "age" : 18, "name" : "Jack" }
> db.user.aggregate([{$group: {_id: "$age", num: {$avg: "$weight"}}}])
{ "_id" : 18, "num" : 80 }
{ "_id" : 24, "num" : 65 }
> db.user.aggregate([{$group: {_id: "$age", num: {$min: "$weight"}}}])
{ "_id" : 18, "num" : 80 }
{ "_id" : 24, "num" : 60 }
> db.user.aggregate([{$group: {_id: "$age", num: {$max: "$weight"}}}])
{ "_id" : 18, "num" : 80 }
{ "_id" : 24, "num" : 70 }
> db.user.aggregate([{$group: {_id: "$age", name: {$push: "$name"}}}])
{ "_id" : 18, "name" : [ "Jack" ] }
{ "_id" : 24, "name" : [ "Cats", "Lee" ] }
> db.user.aggregate([{$group: {_id: "$age", name: {$addToSet: "$name"}}}])
{ "_id" : 18, "name" : [ "Jack" ] }
{ "_id" : 24, "name" : [ "Lee", "Cats" ] }
> db.user.aggregate([{$group: {_id: "$age", first: {$first: "$name"}}}])
{ "_id" : 18, "first" : "Jack" }
{ "_id" : 24, "first" : "Cats" }
> db.user.aggregate([{$group: {_id: "$age", first: {$last: "$name"}}}])
{ "_id" : 18, "first" : "Jack" }
{ "_id" : 24, "first" : "Lee" }
```

### 管道的概念

MongoDB的聚合管道将MongoDB文档在一个管道处理完毕后将结果传递给下一个管道处理。管道操作是可以重复的。

表达式：处理输入文档并输出。表达式是无状态的，只能用于计算当前聚合管道的文档，不能处理其它的文档。

聚合框架中常用的几个操作：

$project：修改输入文档的结构。可以用来重命名、增加或删除域，也可以用于创建计算结果以及嵌套文档。

$match：用于过滤数据，只输出符合条件的文档。`$match` 使用MongoDB的标准查询操作。

$limit：用来限制MongoDB聚合管道返回的文档数。

$skip：在聚合管道中跳过指定数量的文档，并返回余下的文档。

$unwind：将文档中的某一个数组类型字段拆分成多条，每条包含数组中的一个值。

$group：将集合中的文档分组，可用于统计结果。

$sort：将输入文档排序后输出。

$geoNear：输出接近某一地理位置的有序文档。

$project实例

```js
db.article.aggregate(
    { $project : {
        title : 1 ,
        author : 1 ,
    }}
 );
```

这样的话结果中就只还有 `_id,tilte,author` 三个字段了，默认情况下 `_id` 字段是被包含的，如果要想不包含 `_id` 话可以这样：

```js
db.article.aggregate(
    { $project : {
        _id : 0 ,
        title : 1 ,
        author : 1
    }});
```
```js
> db.article.insert({
... 'title':'你好世界',
... 'time': new Date(),
... 'author':'Jack',
... 'content':'hello world!',
... 'category':'日记',
... })
> db.article.find()
{ "_id" : ObjectId("5c61881156b2f401e8cec100"), "title" : "你好世界", "time" : ISODate("2019-02-11T14:34:57.127Z"), "author" : "Jack", "content" : "hello world!", "category" : "日记" }
> db.article.aggregate({ $project: {_id: 0, title: 1, author: 1, content: 1}})
{ "title" : "你好世界", "author" : "Jack", "content" : "hello world!" }
```

$match实例

```js
db.articles.aggregate( [
                        { $match : { score : { $gt : 70, $lte : 90 } } },
                        { $group: { _id: null, count: { $sum: 1 } } }
                       ] );
```
`$match` 用于获取分数大于70小于或等于90记录，然后将符合条件的记录送到下一阶段 `$group` 管道操作符进行处理。

$skip实例

```js
db.article.aggregate(
    { $skip : 5 });
```

经过 `$skip` 管道操作符处理后，前五个文档被"过滤"掉。

### 复制（副本集）

MongoDB复制是将数据同步在多个服务器的过程。

复制提供了数据的冗余备份，并在多个服务器上存储数据副本，提高了数据的可用性， 并可以保证数据的安全性。

复制还允许您从硬件故障和服务中断中恢复数据。

什么是复制?
- 保障数据的安全性
- 数据高可用性 (24*7)
- 灾难恢复
- 无需停机维护（如备份，重建索引，压缩）
- 分布式读取数据
- MongoDB复制原理

mongodb的复制至少需要两个节点。其中一个是主节点，负责处理客户端请求，其余的都是从节点，负责复制主节点上的数据。

mongodb各个节点常见的搭配方式为：一主一从、一主多从。

主节点记录在其上的所有操作oplog，从节点定期轮询主节点获取这些操作，然后对自己的数据副本执行这些操作，从而保证从节点的数据与主节点一致。

复制结构图：客户端从主节点读取数据，在客户端写入数据到主节点时， 主节点与从节点进行数据交互保障数据的一致性。
![](http://www.runoob.com/wp-content/uploads/2013/12/replication.png)

**副本集特征：**

- N 个节点的集群
- 任何节点可作为主节点
- 所有写入操作都在主节点上
- 自动故障转移
- 自动恢复
- MongoDB副本集设置

我们使用同一个MongoDB来做MongoDB主从的实验：

1. 关闭正在运行的MongoDB服务器
2. 通过指定 `--replSet` 选项来启动mongoDB。`--replSet` 基本语法格式：

```js
mongod --port "PORT" --dbpath "YOUR_DB_DATA_PATH" --replSet "REPLICA_SET_INSTANCE_NAME"
```
```sh
mongod --port 27017 --dbpath "D:\set up\mongodb\data" --replSet rs0
```
以上实例会启动一个名为 `rs0` 的MongoDB实例，其端口号为27017。启动后打开命令提示框并连接上mongoDB服务。

`rs.initiate()` 来启动一个新的副本集。

`rs.conf()` 来查看副本集的配置

`rs.status()` 查看副本集状态

**副本集添加成员**

添加副本集的成员，我们需要使用多台服务器来启动mongo服务。进入Mongo客户端，并使用 `rs.add()` 来添加副本集的成员。

```js
>rs.add(HOST_NAME:PORT)
```
例：假设你已经启动了一个名为 "mongod1.net"，端口号为27017的Mongo服务。 在客户端命令窗口使用 `rs.add()` 命令将其添加到副本集中，命令如下所示：
```js
>rs.add("mongod1.net:27017")
```
MongoDB中你只能通过主节点将Mongo服务添加到副本集中， 判断当前运行的Mongo服务是否为主节点可以使用命令`db.isMaster()` 。

MongoDB的副本集与我们常见的主从有所不同，主从在主机宕机后所有服务将停止，而副本集在主机宕机后，副本会接管主节点成为主节点，不会出现宕机的情况。

### 分片

在Mongodb里面存在另一种集群，就是分片技术,可以满足MongoDB数据量大量增长的需求。

当MongoDB存储海量的数据时，一台机器可能不足以存储数据，也可能不足以提供可接受的读写吞吐量。这时，我们就可以通过在多台机器上分割数据，使得数据库系统能存储和处理更多的数据。

为什么使用分片
- 复制所有的写入操作到主节点
- 延迟的敏感数据会在主节点查询
- 单个副本集限制在12个节点
- 当请求量巨大时会出现内存不足。
- 本地磁盘不足
- 垂直扩展价格昂贵

在MongoDB中使用分片集群结构分布：
![](http://www.runoob.com/wp-content/uploads/2013/12/sharding.png)
上图中主要有如下所述三个主要组件：

- Shard：用于存储实际的数据块，实际生产环境中一个shard server角色可由几台机器组个一个replica set承担，防止主机单点故障
- Config Server：mongod实例，存储了整个 ClusterMetadata，其中包括 chunk信息。
- Query Routers：前端路由，客户端由此接入，且让整个集群看上去像单一数据库，前端应用可以透明使用。

**分片实例**
分片结构端口分布如下：

Shard Server 1：27020

Shard Server 2：27021

Shard Server 3：27022

Shard Server 4：27023

Config Server ：27100

Route Process：40000

1. 启动 Shard Server

```sh
[root@100 /]# mkdir -p /www/mongoDB/shard/s0
[root@100 /]# mkdir -p /www/mongoDB/shard/s1
[root@100 /]# mkdir -p /www/mongoDB/shard/s2
[root@100 /]# mkdir -p /www/mongoDB/shard/s3
[root@100 /]# mkdir -p /www/mongoDB/shard/log
[root@100 /]# /usr/local/mongoDB/bin/mongod --port 27020 --dbpath=/www/mongoDB/shard/s0 --logpath=/www/mongoDB/shard/log/s0.log --logappend --fork
....
[root@100 /]# /usr/local/mongoDB/bin/mongod --port 27023 --dbpath=/www/mongoDB/shard/s3 --logpath=/www/mongoDB/shard/log/s3.log --logappend --fork
```
2. 启动 Config Server
```sh
[root@100 /]# mkdir -p /www/mongoDB/shard/config
[root@100 /]# /usr/local/mongoDB/bin/mongod --port 27100 --dbpath=/www/mongoDB/shard/config --logpath=/www/mongoDB/shard/log/config.log --logappend --fork
```
注：这里可以像启动普通mongodb服务一样启动，不需要添加— `shardsvr` 和 `configsvr` 参数。因为这两个参数的作用就是改变启动端口的，所以我们自行指定了端口就可以

3. 启动 Route Process

```sh
/usr/local/mongoDB/bin/mongos --port 40000 --configdb localhost:27100 --fork --logpath=/www/mongoDB/shard/log/route.log --chunkSize 500
```
mongos启动参数中，`chunkSize` 这一项是用来指定chunk的大小的，单位是MB，默认大小为200MB.

4. 配置 Sharding，使用MongoDB Shell登录到mongos，添加Shard节点

```sh
[root@100 shard]# /usr/local/mongoDB/bin/mongo admin --port 40000
MongoDB shell version: 2.0.7
connecting to: 127.0.0.1:40000/admin
mongos> db.runCommand({ addshard:"localhost:27020" })
{ "shardAdded" : "shard0000", "ok" : 1 }
......
mongos> db.runCommand({ addshard:"localhost:27029" })
{ "shardAdded" : "shard0009", "ok" : 1 }
mongos> db.runCommand({ enablesharding:"test" }) #设置分片存储的数据库
{ "ok" : 1 }
mongos> db.runCommand({ shardcollection: "test.log", key: { id:1,time:1}})
{ "collectionsharded" : "test.log", "ok" : 1 }
```
5. 程序代码内无需太大更改，直接按照连接普通的mongo数据库那样，将数据库连接接入接口40000

实例：

1. 创建Sharding复制集 rs0

```sh
# mkdir /data/log
# mkdir /data/db1
# nohup mongod --port 27020 --dbpath=/data/db1 --logpath=/data/log/rs0-1.log --logappend --fork --shardsvr --replSet=rs0 &

# mkdir /data/db2
# nohup mongod --port 27021 --dbpath=/data/db2 --logpath=/data/log/rs0-2.log --logappend --fork --shardsvr --replSet=rs0 &
```
​	复制集rs0配置

```sh
# mongo localhost:27020 > rs.initiate({_id: 'rs0', members: [{_id: 0, host: 'localhost:27020'}, {_id: 1, host: 'localhost:27021'}]}) > rs.isMaster() #查看主从关系
```
2. 创建Sharding复制集 rs1

```sh
# mkdir /data/db3
# nohup mongod --port 27030 --dbpath=/data/db3 --logpath=/data/log/rs1-1.log --logappend --fork --shardsvr --replSet=rs1 &
# mkdir /data/db4
# nohup mongod --port 27031 --dbpath=/data/db4 --logpath=/data/log/rs1-2.log --logappend --fork --shardsvr --replSet=rs1 &
```
​	复制集rs1配置
```sh
# mongo localhost:27030
> rs.initiate({_id: 'rs1', members: [{_id: 0, host: 'localhost:27030'}, {_id: 1, host: 'localhost:27031'}]})
> rs.isMaster() #查看主从关系
```
3. 创建Config复制集 conf

```
# mkdir /data/conf1
# nohup mongod --port 27100 --dbpath=/data/conf1 --logpath=/data/log/conf-1.log --logappend --fork --configsvr --replSet=conf &
# mkdir /data/conf2
# nohup mongod --port 27101 --dbpath=/data/conf2 --logpath=/data/log/conf-2.log --logappend --fork --configsvr --replSet=conf &
```
​	复制集conf配置

```sh
# mongo localhost:27100
> rs.initiate({_id: 'conf', members: [{_id: 0, host: 'localhost:27100'}, {_id: 1, host: 'localhost:27101'}]})
> rs.isMaster() #查看主从关系
```
4. 创建Route

```sh
# nohup mongos --port 40000 --configdb conf/localhost:27100,localhost:27101 --fork --logpath=/data/log/route.log --logappend & 
```
​	设置分片
```sh
# mongo localhost:40000
> use admin
> db.runCommand({ addshard: 'rs0/localhost:27020,localhost:27021'})
> db.runCommand({ addshard: 'rs1/localhost:27030,localhost:27031'})
> db.runCommand({ enablesharding: 'test'})
> db.runCommand({ shardcollection: 'test.user', key: {name: 1}})
```

### 备份(mongodump)与恢复(mongorestore)
#### MongoDB数据备份
`mongodump` 命令来备份MongoDB数据，该命令可以导出所有数据到指定目录中。
`mongodump` 命令可以通过参数指定导出的数据量级转存的服务器。

语法

```js
>mongodump -h dbhost -d dbname -o dbdirectory
```
-h：MongDB所在服务器地址，例如：127.0.0.1，当然也可以指定端口号：127.0.0.1:27017
-d：需要备份的数据库实例，例如：test
-o：备份的数据存放位置，目录需要提前建立，在备份完成后，系统自动在指定目录下建立一个test目录，这个目录里面存放该数据库实例的备份数据。

实例：在本地使用 27017 启动你的mongod服务。

```sh
C:\WINDOWS\system32>mongodump -h localhost:27017 -d test -o "C:\Program Files\MongoDB\Server\4.0"
2019-02-12T00:28:16.031+0800    writing admin.system.version to
2019-02-12T00:28:16.200+0800    done dumping admin.system.version (1 document)
2019-02-12T00:28:16.201+0800    writing test.user to
2019-02-12T00:28:16.202+0800    writing test.test to
2019-02-12T00:28:16.203+0800    writing test.article to
2019-02-12T00:28:16.206+0800    done dumping test.user (3 documents)
2019-02-12T00:28:16.208+0800    done dumping test.test (1 document)
2019-02-12T00:28:17.213+0800    done dumping test.article (1 document)
```
#### 数据恢复
mongodb使用 `mongorestore` 命令来恢复备份的数据。
```sh
mongorestore -h <hostname><:port> -d dbname <path>
```
- --host <:port>, -h <:port>：MongoDB所在服务器地址，默认为： localhost:27017
- --db , -d ：需要恢复的数据库实例，例如：test，当然这个名称也可以和备份时候的不一样，比如test2
- --drop：恢复的时候，先删除当前数据，然后恢复备份的数据。就是说，恢复后，备份后添加修改的数据都会被删除，慎用哦！
- <path>：mongorestore 最后的一个参数，设置备份数据所在位置，例如：c:\data\dump\test。
  你不能同时指定 <path> 和 --dir 选项，--dir也可以设置备份目录。
- --dir：指定备份的目录，你不能同时指定 <path> 和 --dir 选项。

###  监控
在你已经安装部署并允许MongoDB服务后，你必须要了解MongoDB的运行情况，并查看MongoDB的性能。这样在大流量得情况下可以很好的应对并保证MongoDB正常运作。
MongoDB中提供了`mongostat` 和` mongotop` 两个命令来监控MongoDB的运行情况。

####  mongostat 命令
`mongostat` 是mongodb自带的状态检测工具，在命令行下使用。它会间隔固定时间获取mongodb的当前运行状态，并输出。如果你发现数据库突然变慢或者有其他问题的话，你第一手的操作就考虑采用 `mongostat` 来查看mongo的状态。

启动你的Mongod服务，进入到你安装的MongoDB目录下的bin目录， 然后输入 `mongostat` 命令，如下所示：

```sh
C:\Users\35398>mongostat
insert query update delete getmore command dirty used flushes vsize   res qrw arw net_in net_out conn                time
    *0    *0     *0     *0       0   334|0  0.0% 0.0%       0 4.96G 26.0M 0|0 1|0  26.4k   10.5m    1 Feb 13 17:29:18.412
    *0    *0     *0     *0       0     2|0  0.0% 0.0%       0 4.96G 26.0M 0|0 1|0   164b   65.6k    1 Feb 13 17:29:19.371
    *0    *0     *0     *0       0     2|0  0.0% 0.0%       0 4.96G 26.0M 0|0 1|0   158b   63.1k    1 Feb 13 17:29:20.368
    *0    *0     *0     *0       0     1|0  0.0% 0.0%       0 4.96G 26.0M 0|0 1|0   156b   62.5k    1 Feb 13 17:29:21.376
    *0    *0     *0     *0       0     2|0  0.0% 0.0%       0 4.96G 26.0M 0|0 1|0   158b   63.2k    1 Feb 13 17:29:22.371
    *0    *0     *0     *0       0     1|0  0.0% 0.0%       0 4.96G 26.0M 0|0 1|0   157b   62.8k    1 Feb 13 17:29:23.372
    *0    *0     *0     *0       0     1|0  0.0% 0.0%       0 4.96G 26.0M 0|0 1|0   157b   62.7k    1 Feb 13 17:29:24.376
    *0    *0     *0     *0       0     2|0  0.0% 0.0%       0 4.96G 26.0M 0|0 1|0   159b   63.3k    1 Feb 13 17:29:25.369
    *0    *0     *0     *0       0     1|0  0.0% 0.0%       0 4.96G 26.0M 0|0 1|0   156b   62.4k    1 Feb 13 17:29:26.377
    *0    *0     *0     *0       0     2|0  0.0% 0.0%       0 4.96G 26.0M 0|0 1|0   159b   63.4k    1 Feb 13 17:29:27.369
....
```
####  mongotop 命令
`mongotop` 也是mongodb下的一个内置工具，`mongotop` 提供了一个方法，用来跟踪一个MongoDB的实例，查看哪些大量的时间花费在读取和写入数据。 `mongotop` 提供每个集合的水平的统计数据。默认情况下，`mongotop` 返回值的每一秒。

```sh
C:\Users\35398>mongotop
2019-02-13T17:30:12.434+0800    connected to: 127.0.0.1

                    ns    total    read    write    2019-02-13T17:30:13+08:00
    admin.system.roles      0ms     0ms      0ms
  admin.system.version      0ms     0ms      0ms
config.system.sessions      0ms     0ms      0ms
     local.startup_log      0ms     0ms      0ms
  local.system.replset      0ms     0ms      0ms
          test.article      0ms     0ms      0ms
             test.test      0ms     0ms      0ms
             test.user      0ms     0ms      0ms
...
```
输出结果字段说明：

- ns：包含数据库命名空间，后者结合了数据库名称和集合。

- db：包含数据库的名称。名为 . 的数据库针对全局锁定，而非特定数据库。

- total：mongod花费的时间工作在这个命名空间提供总额。

- read：提供了大量的时间，这mongod花费在执行读操作，在此命名空间。

- write：提供这个命名空间进行写操作，这mongod花了大量的时间。



------

### Reference
http://www.runoob.com/mongodb/

http://www.runoob.com/nodejs/nodejs-mongodb.html

https://www.npmjs.com/package/mongodb

https://www.cnblogs.com/phpandmysql/p/7763394.html