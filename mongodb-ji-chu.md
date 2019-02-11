#### 基本使用
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
#### 更新文档 update() 
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
#### save() 方法
save() 方法通过传入的文档来替换已有文档。语法格式如下：
```sh
db.collection.save(
   <document>,
   {
     writeConcern: <document>
   }
)
```
参数说明：
document : 文档数据。
writeConcern :可选，抛出异常的级别。
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
#### 删除文档
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
#### 查询文档 find()
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
findOne() 方法，只返回一个文档

### MongoDB 与 RDBMS Where 语句比较

|操作	|格式	|范例	|RDBMS中的类似语句|
|-|-|-|-|
|等于	|{<key>:<value>}	|db.col.find({"by":"菜鸟教程"}).pretty()	|where by = '菜鸟教程'|
|小于	|{<key>:{$lt:<value>}}	|db.col.find({"likes":{$lt:50}}).pretty()	|where likes < 50|
|小于或等于	|{<key>:{$lte:<value>}}|	db.col.find({"likes":{$lte:50}}).pretty()	|where likes <= 50|
|大于	|{<key>:{$gt:<value>}}	|db.col.find({"likes":{$gt:50}}).pretty()	|where likes > 50|
|大于或等于	|{<key>:{$gte:<value>}} 	|db.col.find({"likes":{$gte:50}}).pretty()	|where likes >= 50|
|不等于	|{<key>:{$ne:<value>}}	|db.col.find({"likes":{$ne:50}}).pretty()	|where likes != 50 |

#### AND 条件
MongoDB 的 find() 方法可以传入多个键(key)，每个键(key)以逗号隔开，即常规 SQL 的 AND 条件。
```js
db.col.find({key1:value1, key2:value2}).pretty()
```
类似于 WHERE 语句：WHERE key1='value1' AND title='value2'
#### OR 条件 
关键字 $or
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
类似常规 SQL 语句为： 'where likes>50 AND (by = '菜鸟教程' OR title = 'MongoDB 教程')'
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
$type条件操作符是基于BSON类型来检索集合中匹配的数据类型，并返回结果。

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

#### Limit() 方法
读取指定数量的数据记录，limit()方法接受一个数字参数，该参数指定从MongoDB中读取的记录条数。
```js
db.<collection>.find().limit(NUMBER)
```
例：
```js
> db.user.find({},{'name':1,_id:0}).limit(2)
```
#### Skip() 方法
除了可以使用limit()方法来读取指定数量的数据外，还可以使用skip()方法来跳过指定数量的数据，skip方法同样接受一个数字参数作为跳过的记录条数。
```js
db.<collection>.find().limit(NUMBER).skip(NUMBER)
```
例:显示第二条文档数据
```js
>db.col.find({},{"title":1,_id:0}).limit(1).skip(1)
```
【注】skip()方法默认参数为 0 
### 排序
#### sort() 方法
sort() 方法可以通过参数指定排序的字段，并使用 1 和 -1 来指定排序的方式，其中 1 为升序排列，而 -1 是用于降序排列。
```js
db.<collection>.find().sort({KEY:1})
```
【注】skip(), limilt(), sort()三个放在一起执行的时候，执行的顺序是先 sort(), 然后是 skip()，最后是显示的 limit()。

###索引
索引通常能够极大的提高查询的效率，如果没有索引，MongoDB在读取数据时必须扫描集合中的每个文件并选取那些符合查询条件的记录。

索引是特殊的数据结构，索引存储在一个易于遍历读取的数据集合中，索引是对数据库表中一列或多列的值进行排序的一种结构

#### 创建索引 createIndex() 方法
```js
db.<collection>.createIndex(keys, options)
```
语法中 Key 值为你要创建的索引字段，1 为指定按升序创建索引，如果你想按降序来创建索引指定为 -1 即可。
例
```js
>db.col.createIndex({"title":1})
```
createIndex() 方法中你也可以设置使用多个字段创建索引（关系型数据库中称作复合索引）。
```js
>db.col.createIndex({"title":1,"description":-1})
```

|Parameter	|Type	|Description|
|-|-|
|background	|Boolean	|建索引过程会阻塞其它数据库操作，background可指定以后台方式创建索引，可选，"background" 默认false。|
|unique	|Boolean	|建立的索引是否唯一。默认值为false.
|name	|string	|索引的名称。如果未指定，MongoDB的通过连接索引的字段名和排序顺序生成一个索引名称。|
|sparse	|Boolean	|对文档中不存在的字段数据不启用索引；这个参数需要特别注意，如果设置为true的话，在索引字段中不会查询出不包含对应字段的文档.。默认值为 false.
|expireAfterSeconds	|integer	|指定一个以秒为单位的数值，完成 TTL设定，设定集合的生存时间。|
|v	|index version	|索引的版本号。默认的索引版本取决于mongod创建索引时运行的版本。|
|weights	|document	|索引权重值，数值在 1 到 99,999 之间，表示该索引相对于其他索引字段的得分权重。|
|default_language	|string	|对于文本索引，该参数决定了停用词及词干和词器的规则的列表。 默认为英语|
|language_override	|string	|对于文本索引，该参数指定了包含在文档中的字段名，语言覆盖默认的language，默认值为 language.|
在后台创建索引：
```js
db.values.createIndex({open: 1, close: 1}, {background: true})
```   
1、查看集合索引
db.col.getIndexes()

2、查看集合索引大小
db.col.totalIndexSize()

3、删除集合所有索引
db.col.dropIndexes()

4、删除集合指定索引
db.col.dropIndex("索引名称")

例：
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
聚合 aggregate() 方法
```js
db.COLLECTION_NAME.aggregate(AGGREGATE_OPERATION)
```
```js
> db.user.find()
{ "_id" : ObjectId("5c61189a56b2f401e8cec0fd"), "name" : "Lee", "title" : "Lee", "age" : 18 }
{ "_id" : ObjectId("5c612ea656b2f401e8cec0fe"), "name" : "jack", "age" : 23 }
{ "_id" : ObjectId("5c612eef56b2f401e8cec0ff"), "name" : "Cats", "age" : 23 }
> db.user.aggregate([{$group: {_id: '$age', num: {$sum: 1}}}])
{ "_id" : 23, "num" : 2 }
{ "_id" : 18, "num" : 1 }
```