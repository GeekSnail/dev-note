## mongoose 基础

###  Schemas

```js
var mongoose = require('mongoose')
var Schema = mongoose.Schema

// define some properties which will be cast to the xxx SchemaType
var blogSchema = new Schema({
  title: String,
  author: String,
  body: String,
  comments: [{ body: String, date: Date }],
  date: { type: Date, default: Date.now },
  hidden: Boolean,
  meta: {
    votes: Number,
    favs: Number
  }
})
```

The permitted [SchemaTypes](https://mongoosejs.com/docs/schematypes.html). are:

- [String](https://mongoosejs.com/docs/schematypes.html#strings)
- [Number](https://mongoosejs.com/docs/schematypes.html#numbers)
- [Date](https://mongoosejs.com/docs/schematypes.html#dates)
- [Buffer](https://mongoosejs.com/docs/schematypes.html#buffers)
- [Boolean](https://mongoosejs.com/docs/schematypes.html#booleans)
- [Mixed](https://mongoosejs.com/docs/schematypes.html#mixed)
- [ObjectId](https://mongoosejs.com/docs/schematypes.html#objectids)
- [Array](https://mongoosejs.com/docs/schematypes.html#arrays)
- Decimal128
- [Map](https://mongoosejs.com/docs/schematypes.html#maps)

Schemas not only define the structure of your document and casting of properties, they also define document [instance methods](https://mongoosejs.com/docs/guide.html#methods), [static Model methods](https://mongoosejs.com/docs/guide.html#statics), [compound indexes](https://mongoosejs.com/docs/guide.html#indexes), and document lifecycle hooks called [middleware](https://mongoosejs.com/docs/middleware.html).

#### Create a model

To use our schema definition, we need to convert our `blogSchema` into a [Model](https://mongoosejs.com/docs/models.html) we can work with. To do so, we pass it into `mongoose.model(modelName, schema)`:

```js
var Blog = mongoose.model('Blog', blogSchema)
```

#### 实例方法

[documents](http://mongoosejs.net/docs/documents.html) 是 `Models` 的实例。 Document 有很多自带的[实例方法](http://mongoosejs.net/docs/api.html#document-js)， 当然也可以自定义我们自己的方法。
```js
var animalSchema = new Schema({ name: String, type: String })
animalSchema.methods.findSimilarTypes = function(cb) {
    return this.model('Animal').find({ type: this.type }, cb)
}

var Animal = mongoose.model('Animal', animalSchema)
var dog = new Animal({ type: 'dog'})
dog.findSimilarTypes(function(err, dogs) {
    console.log(dogs)
})
```
#### 静态方法(static)
添加 `Model` 的静态方法也十分简单，继续用 `animalSchema` 举例：
```js
  // assign a function to the "statics" object of our animalSchema
  animalSchema.statics.findByName = function(name, cb) {
    return this.find({ name: new RegExp(name, 'i') }, cb);
  };

  var Animal = mongoose.model('Animal', animalSchema);
  Animal.findByName('fido', function(err, animals) {
    console.log(animals);
  });
```

同样**不要**在静态方法中使用 ES6 箭头函数

#### 查询助手(query helper)
查询助手作用于 query 实例，方便你自定义拓展你的 [链式查询](http://mongoosejs.net/docs/queries.html)
```js
  animalSchema.query.byName = function(name) {
    return this.find({ name: new RegExp(name, 'i') });
  };

  var Animal = mongoose.model('Animal', animalSchema);
  Animal.find().byName('fido').exec(function(err, animals) {
    console.log(animals);
  });
```

#### 索引(index)

MongoDB 支持 [secondary indexes](http://docs.mongodb.org/manual/indexes/). 在 mongoose 中，我们在 `Schema` 中定义索引。索引分字段级别和schema级别，[复合索引](https://docs.mongodb.com/manual/core/index-compound/) 需要在 schema 级别定义。
```js
  var animalSchema = new Schema({
    name: String,
    type: String,
    tags: { type: [String], index: true } // field level
  });

  animalSchema.index({ name: 1, type: -1 }); // schema level
```
应用启动时， Mongoose 会自动调用 [`createIndex`](https://docs.mongodb.com/manual/reference/method/db.collection.createIndex/#db.collection.createIndex) 初始化你定义的索引。 Mongoose 顺序处理每一个 `createIndex` ，然后在model触发 'index' 事件。 While nice for development, it is recommended this behavior be disabled in production since index creation can cause a [significant performance impact](http://docs.mongodb.org/manual/core/indexes/#index-creation-operations). Disable the behavior by setting the `autoIndex` option of your schema to `false`, or globally on the connection by setting the option `autoIndex` to `false`.
```js
mongoose.connect('mongodb://user:pass@localhost:port/database', { autoIndex: false });
// or
mongoose.createConnection('mongodb://user:pass@localhost:port/database', { autoIndex: false });
// or
animalSchema.set('autoIndex', false);
// or
new Schema({..}, { autoIndex: false });
```
索引构建完成或失败后，Mongoose 会触发 `index` 事件。
```js
  // Will cause an error because mongodb has an _id index by default that
  // is not sparse
  animalSchema.index({ _id: 1 }, { sparse: true });
  var Animal = mongoose.model('Animal', animalSchema);

  Animal.on('index', function(error) {
    // "_id index cannot be sparse"
    console.log(error.message);
  });
```

相关链接 [Model#ensureIndexes](http://mongoosejs.net/docs/api.html#model_Model.ensureIndexes)

#### 虚拟值（Virtual）
[Virtuals](http://mongoosejs.net/docs/api.html#schema_Schema-virtual) 是 document 的属性，但是不会被保存到 MongoDB。 getter 可以用于格式化和组合字段数据， setter 可以很方便地分解一个值到多个字段。
```js
  // define a schema
  var personSchema = new Schema({
    name: {
      first: String,
      last: String
    }
  });

  // compile our model
  var Person = mongoose.model('Person', personSchema);

  // create a document
  var axl = new Person({
    name: { first: 'Axl', last: 'Rose' }
  });
```
如果你要log出全名，可以这么做：
```js
console.log(axl.name.first + ' ' + axl.name.last); // Axl Rose
```
但是每次都这么拼接实在太麻烦了， 推荐你使用[virtual property getter](http://mongoosejs.net/docs/api.html#virtualtype_VirtualType-get)， 这个方法允许你定义一个 `fullName` 属性，但不必保存到数据库。
```js
personSchema.virtual('fullName').get(function () {
  return this.name.first + ' ' + this.name.last;
});
```
现在, mongoose 可以调用 getter 函数访问 `fullName` 属性：
```js
console.log(axl.fullName); // Axl Rose
```
如果对 document 使用 `toJSON()` 或 `toObject()`，默认不包括虚拟值， 你需要额外向 [toObject()](http://mongoosejs.net/docs/api.html#document_Document-toObject) 或者 `toJSON()` 传入参数 `{ virtuals: true }`。

你也可以设定虚拟值的 setter ，下例中，当你赋值到虚拟值时，它可以自动拆分到其他属性：
```js
personSchema.virtual('fullName').
  get(function() { return this.name.first + ' ' + this.name.last; }).
  set(function(v) {
    this.name.first = v.substr(0, v.indexOf(' '));
    this.name.last = v.substr(v.indexOf(' ') + 1);
  });

axl.fullName = 'William Rose'; // Now `axl.name.first` is "William"
```
再次强调，虚拟值不能用于查询和字段选择，因为虚拟值不储存于 MongoDB。

例子：
```js
var mongoose = require('mongoose')
var db = mongoose.connect('mongodb://localhost:27017/test', {useNewUrlParser: true})
var Schema = mongoose.Schema

var testSchema = new Schema({
  name: { type: String },
  age: { type: Number, default: 0 },
  time: { type: Date, default: Date.now },
  email: { type: String, default: '' }
})
// 1.document method
testSchema.method('findName', function (callback) {
  return this.model('test').find({ name: this.name }, callback)
})
// 2.model static method
testSchema.statics.findByName = function (name, callback) {
  return this.find({ name: new RegExp(name, 'i') }, callback)
}

var testModel = mongoose.model('test', testSchema)
// at the first call, mongoose will automatically create a collection named 'tests'

var t1 = new testModel({
  name: 'he',
  age: 18
})
t1.save(function(err, doc) {
  t1.findName(function(err, docs) {
    //console.log('t1.save(), docs:', docs)
  })
  doc.findName(function(err, docs) { 
    //console.log('argv:doc.save(), docs:', docs)
  })
}) 

testModel.findByName('he', function (err, docs) {
  // console.log('call model static method, \ndocs:', docs)
})

// 3.create, update, find and delete based on model
var doc = { name: 'Lee', age: 23 }
testModel.create(doc, function(err) {
  if (err) console.log(err)
  else console.log('create doc:', doc) // 最后执行
})

var condition = {name:'Lee'}
var update = {$set: {age: 29}}
var option = {upsert: false} // avoid modify:0, but insert
testModel.updateMany(condition, update, option, function(err, result) {
  if (err) console.log(err)
  else console.log('updateMany.', result) 
})

var criteria = {name: 'Lee'}
var field = {age:1}
var option = {}
testModel.find(criteria, field, option, function(err, result) {
  if (err) console.log(err)
  else console.log('find docs:',result)
})

var cond = {$or: [{name:'Lee'},{name:'he'}]}
testModel.deleteMany(cond, function(err, result) {
  if (err) console.log(err)
  else console.log('deleteMany.',result) //
})
// 参考了 https://blog.csdn.net/sinat_25127047/article/details/50560167
```

### Connections

#### 多个连接

之前我们了解如何使用 Mongoose 默认连接方法连接到 MongoDB。但有时候我们需要权限不同的多个连接， 或是连接到不同数据库。这个情况下我们可以使用 `mongoose.createConnection()`， 它接受之前提到的所有参数，给你返回一个新的连接。

```js
const conn = mongoose.createConnection('mongodb://[username:password@]host1[:port1][,host2[:port2],...[,hostN[:portN]]][/[database][?options]]', options);
```

[connection](http://mongoosejs.net/docs/api.html#connection_Connection) 对象后续用于创建和检索 [models](http://mongoosejs.net/docs/api.html#model_Model)。 models 的范围总是局限于单个连接。

调用 `mongoose.connect()` 时，Mongoose 会自动创建**默认连接**。 你可以使用 `mongoose.connection` 访问默认连接。

### Models

[Models](http://mongoosejs.net/docs/api.html#model-js) 是从 `Schema` 编译来的构造函数。 它们的实例就代表着可以从数据库保存和读取的 [documents](http://mongoosejs.net/docs/documents.html)。 从数据库创建和读取 document 的所有操作都是通过 model 进行的。

#### 编译你的第一个 model

```js
var schema = new mongoose.Schema({ name: 'string', size: 'string' });
var Tank = mongoose.model('Tank', schema);
```

第一个参数是跟 model 对应的集合（ collection ）名字的 *单数* 形式。 **Mongoose 会自动找到名称是 model 名字 复数形式的 collection** 。 对于上例，Tank 这个 model 就对应数据库中 **tanks** 这个 collection。`.model()` 这个函数是对 `schema` 做了拷贝（生成了 model）。 你要确保在调用 `.model()` 之前把所有需要的东西都加进 `schema` 里了！

#### 构造 documents

[Documents](http://mongoosejs.net/docs/documents.html) 是 model 的实例。 创建它们并保存到数据库非常简单：

```js
var Tank = mongoose.model('Tank', yourSchema);

var small = new Tank({ size: 'small' });
small.save(function (err) {
  if (err) return handleError(err);
  // saved!
})

// or

Tank.create({ size: 'small' }, function (err, small) {
  if (err) return handleError(err);
  // saved!
})
```

要注意，直到 model 使用的数据库连接（ connection ）被打开，tanks 才会被创建/删除。每个 model 都有一个绑定的连接。 如果 model 是通过调用 `mongoose.model()` 生成的，它将使用 mongoose 的默认连接。

```js
mongoose.connect('localhost', 'gettingstarted');
```

如果自行创建了连接，就需要使用 connection 的 `model()` 函数代替 mongoose 的 `model()` 函数。

```js
var connection = mongoose.createConnection('mongodb://localhost:27017/test');
var Tank = connection.model('Tank', yourSchema);
```
#### 查询

用 mongoose 查询文档相当容易啦，它支持 MongoDB 的高级（ [rich](http://www.mongodb.org/display/DOCS/Advanced+Queries) ）查询语法。 查询文档可以用 `model` 的 [find](http://mongoosejs.net/docs/api.html#model_Model.find), [findById](http://mongoosejs.net/docs/api.html#model_Model.findById), [findOne](http://mongoosejs.net/docs/api.html#model_Model.findOne), 和 [where](http://mongoosejs.net/docs/api.html#model_Model.where) 这些静态方法。

```
Tank.find({ size: 'small' }).where('createdDate').gt(oneYearAgo).exec(callback);
```

要了解 [Query](http://mongoosejs.net/docs/api.html#query-js) api 的更多细节，可以查阅 [querying](http://mongoosejs.net/docs/queries.html) 章节。

#### 删除

`model` 的 `remove` 方法可以删除所有匹配查询条件（ `conditions` ）的文档。

```
Tank.remove({ size: 'large' }, function (err) {
  if (err) return handleError(err);
  // removed!
});
```

#### 更新

`model` 的 `update` 方法可以修改数据库中的文档，不过不会把文档返回给应用层。查阅 [API](http://mongoosejs.net/docs/api.html#model_Model.update) 了解更多详情。

如果想更新单独一条文档并且返回给应用层，可以使用 [findOneAndUpdate](http://mongoosejs.net/docs/api.html#model_Model.findOneAndUpdate) 方法。

### Documents

Mongoose [document](http://mongoosejs.net/docs/api.html#document-js) 代表着 MongoDB 文档的一对一映射。 每个 document 都是他的 [Model](http://mongoosejs.net/docs/models.html) 的实例。

#### 检索

MongoDB 有很多检索数据的方法。我们在这章暂不提及，详情请看 [querying](http://mongoosejs.net/docs/queries.html)。

#### 更新

Document 更新的方法同样有很多，我们先看看一个传统的实现，使用 [findById](http://mongoosejs.net/docs/api.html#model_Model.findById)：

```js
Tank.findById(id, function (err, tank) {
  if (err) return handleError(err);

  tank.size = 'large';
  tank.save(function (err, updatedTank) {
    if (err) return handleError(err);
    res.send(updatedTank);
  });
});
```

你也可以用 [`.set()`](http://mongoosejs.net/docs/api.html#document_Document-set) 修改 document。在底层， `tank.size = 'large';` 用 `tank.set({ size: 'large' })`实现。

```js
Tank.findById(id, function (err, tank) {
  if (err) return handleError(err);

  tank.set({ size: 'large' });
  tank.save(function (err, updatedTank) {
    if (err) return handleError(err);
    res.send(updatedTank);
  });
});
```

这个方法先检索数据，接着更新（使用了 `save`）。 如果我们仅仅需要更新而不需要获取该数据， [Model#update](http://mongoosejs.net/docs/api.html#model_Model.update) 就很适合我们：

```js
Tank.update({ _id: id }, { $set: { size: 'large' }}, callback);
```

如果我们确实需要返回文档，[这个方法](http://mongoosejs.net/docs/api.html#model_Model.findByIdAndUpdate)更适合：

```js
Tank.findByIdAndUpdate(id, { $set: { size: 'large' }}, { new: true }, function (err, tank) {
  if (err) return handleError(err);
  res.send(tank);
});
```

`findAndUpdate/Remove` 系列静态方法查找并返回最多1个文档。 模式的方法有不少，请阅读 [API](http://mongoosejs.net/docs/api.html) 文档了解更多。

*注意：findAndUpdate/Remove 不会 修改数据库时执行任何钩子或验证。 你可以使用 runValidators 选项 获取一个验证的限制子集（待修改）。 但是你需要钩子和全文档验证，还是先 query 后 save 吧。*

#### 验证

Document 会在被保存之前验证。阅读 [api](http://mongoosejs.net/docs/api.html#document_Document-validate) 文档或 [validation](http://mongoosejs.net/docs/validation.html) 章节了解更多。

#### 覆盖

你可以用 `.set()` 覆盖整个文档。如果你要修改 在[中间件](http://mongoosejs.net/docs/middleware.html)中被保存的文档，这样就很方便。

```js
Tank.findById(id, function (err, tank) {
  if (err) return handleError(err);
  // Now `otherTank` is a copy of `tank`
  otherTank.set(tank);
});
```
### Queries 查询

[Model](http://mongoosejs.net/docs/models.html) 的多个静态辅助方法都可以查询文档。

[Model](http://mongoosejs.net/docs/api.html#model_Model) 的方法中包含查询条件参数的（ [find](http://mongoosejs.net/docs/api.html#model_Model.find) [findById](http://mongoosejs.net/docs/api.html#model_Model.findById) [count](http://mongoosejs.net/docs/api.html#model_Model.count) [update](http://mongoosejs.net/docs/api.html#model_Model.update) ）都可以按以下两种方式执行：

- 传入 `callback` 参数，操作会被立即执行，查询结果被传给回调函数（ callback ）。
- 不传 `callback` 参数，[Query](http://mongoosejs.net/docs/api.html#query-js) 的一个实例（一个 query 对象）被返回，这个 query 提供了构建查询器的特殊接口。

[Query](http://mongoosejs.net/docs/api.html#query-js) 实例有一个 `.then()` 函数，用法类似 promise。

如果执行查询时传入 `callback` 参数，就需要用 JSON 文档的格式指定查询条件。JSON 文档的语法跟 [MongoDB shell](http://docs.mongodb.org/manual/tutorial/query-documents/) 一致。

```js
var Person = mongoose.model('Person', yourSchema);

// 查询每个 last name 是 'Ghost' 的 person， select `name` 和 `occupation` 字段
Person.findOne({ 'name.last': 'Ghost' }, 'name occupation', function (err, person) {
  if (err) return handleError(err);
  // Prints "Space Ghost is a talk show host".
  console.log('%s %s is a %s.', person.name.first, person.name.last,
    person.occupation);
});
```

上例中查询被立即执行，查询结果被传给回调函数。Mongoose 中所有的回调函数都使用 `callback(error, result)` 这种模式。如果查询时发生错误，`error` 参数即是错误文档， `result` 参数会是 null。如果查询成功，`error` 参数是 null，`result` 即是查询的结果。

Mongoose 中每一处查询，被传入的回调函数都遵循 `callback(error, result)` 这种模式。查询结果的格式取决于做什么操作： [findOne()](http://mongoosejs.net/docs/api.html#model_Model.findOne) 是单个文档（有可能是 null ），[find()](http://mongoosejs.net/docs/api.html#model_Model.find) 是文档列表， [count()](http://mongoosejs.net/docs/api.html#model_Model.count) 是文档数量，[update()](http://mongoosejs.net/docs/api.html#model_Model.update) 是被修改的文档数量。 [Models API](http://mongoosejs.net/docs/api.html#model-js) 文档中有详细描述被传给回调函数的值。

下面来看不传入 `callback` 这个参数会怎样：

```js
// 查询每个 last name 是 'Ghost' 的 person
var query = Person.findOne({ 'name.last': 'Ghost' });

// select `name` 和 `occupation` 字段
query.select('name occupation');

// 然后执行查询
query.exec(function (err, person) {
  if (err) return handleError(err);
  // Prints "Space Ghost is a talk show host."
  console.log('%s %s is a %s.', person.name.first, person.name.last,
    person.occupation);
});
```

以上代码中，`query` 是个 [Query](http://mongoosejs.net/docs/api.html#query-js) 类型的变量。 `Query` 能够用链式语法构建查询器，无需指定 JSON 对象。 下面2个示例等效。

```js
// With a JSON doc
Person.
  find({
    occupation: /host/,
    'name.last': 'Ghost',
    age: { $gt: 17, $lt: 66 },
    likes: { $in: ['vaporizing', 'talking'] }
  }).
  limit(10).
  sort({ occupation: -1 }).
  select({ name: 1, occupation: 1 }).
  exec(callback);

// Using query builder
Person.
  find({ occupation: /host/ }).
  where('name.last').equals('Ghost').
  where('age').gt(17).lt(66).
  where('likes').in(['vaporizing', 'talking']).
  limit(10).
  sort('-occupation').
  select('name occupation').
  exec(callback);
```

[Query API](http://mongoosejs.net/docs/api.html#query-js) 文档中有查询函数的完整列表。

#### [引用其他文档](http://mongoosejs.net/docs/queries.html#refs)

MongoDB 中没有表连接，但引用其他集合的文档有时也会需要。[Population](http://mongoosejs.net/docs/populate.html) 即为此而生。 [这里](http://mongoosejs.net/docs/api.html#query_Query-populate) 有关于从其他集合引用文档的更多内容。