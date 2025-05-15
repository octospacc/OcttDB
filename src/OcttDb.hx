using Types;
using StringTools;

import haxe.Json;

private final KeySeparator = ".";
private final KeyRegex = new EReg("^(?!\\.)(?!.*\\.\\.)(?!.*\\.$)[A-Za-z0-9._]+$", "");

#if python
@:pythonImport("sqlite3")
extern class PySqlite {
  static function connect(path:String):PyConnection;
}

extern class PyConnection {
  public function execute(sql:String):PyCursor;
  public function commit():Void;
  public function close():Void;
}

extern class PyCursor {
  public function fetchall():Array<Dynamic>;
  public function fetchone():Dynamic;
}

// typedef ResultSet = Array<Dynamic>;
// #else
// typedef ResultSet = sys.db.ResultSet;
#end

class SqliteConnection {
  #if python
  var connection:PyConnection;
  #elseif js
  var connection:Dynamic; // TODO
  #else
  var connection:sys.db.Connection;
  #end

  public function new(path:String):Void {
    #if python
    connection = PySqlite.connect(path);
    #elseif js
    connection = null; // TODO
    #else
    connection = sys.db.Sqlite.open(path);
    #end
  }

  public function execute(sql:String):Void {
    #if python
    connection.execute(sql);
    #else
    connection.request(sql);
    #end
    connection.commit();
  }

  /* 
  public function query(sql:String):Dynamic {
    #if python
    var result = connection.execute(sql).fetchone();
    if (result != null) {
      return result[0];
    }
    #else
    var results = connection.request(sql);
    if (results.length != 0) {
      return results.getResult(0);
    }
    #end
    return null;
  }
  */

  public function query(sql:String):Array<Dynamic> {
    #if python
    return connection.execute(sql).fetchall();
    #elseif js
    return []; // TODO
    #else
    var list = [];
    var resultSet = connection.request(sql);
    for (item in resultSet) {
      list.push(item);
    }
    return list;
    #end
  }

  public function close() {
    connection.close();
  }
}

class SqliteJsonDb {
  private final connection:SqliteConnection;

  public function new(connection:SqliteConnection):Void {
    this.connection = connection;

    connection.execute('
      CREATE TABLE IF NOT EXISTS data (
        key TEXT PRIMARY KEY UNIQUE,
        value TEXT);
    ');
  }

  public function get(key:Key):Value {
    var rows = connection.query('SELECT value FROM data WHERE key = "${key}";');
    return (rows.length == 0 ? null : Json.parse(rows[0][0]));
    //return Json.parse(connection.query('SELECT value FROM data WHERE key = "${key}";'));
  }

  public function getPrefixed(key:Key):Rows {
    var list:Rows = [];
    var rows = connection.query('SELECT key,value FROM data WHERE key LIKE "${key}${KeySeparator}%";');
    for (item in rows) {
      //list.push([item[0], Json.parse(item[1])]);
      list.push({ key: item[0], value: Json.parse(item[1]) });
    }
    return list;
  }

  public function set(key:Key, value:Value):Void {
    value = Json.stringify(value).replace('"', '""');
    connection.execute('
      INSERT INTO data (key, value) VALUES ("${key}", "${value}")
      ON CONFLICT (key) DO UPDATE SET value = "${value}"
    ;');
  }

  public function del(key:Key):Void {
    connection.execute('DELETE FROM data WHERE key = "${key}";');
    connection.execute('DELETE FROM data WHERE key LIKE "${key}${KeySeparator}%";');
  }

  public function close():Void {
    connection.close();
  }
}

class InvalidKeyException extends haxe.Exception {}

class OcttDb {
  private final db:SqliteJsonDb;
  private final objectUtil:ObjectUtil;

  public function new(name:String, driver:DbDriver):Void {
    switch (driver) {
      case DbDriver.Sqlite:
        var connection = new SqliteConnection('${name}.sqlite');
        db = new SqliteJsonDb(connection);
      case DbDriver.SqliteMemory:
        var connection = new SqliteConnection(":memory:");
        db = new SqliteJsonDb(connection);
    }
    objectUtil = new ObjectUtil(KeySeparator);
  }

  public function get(key:Key):Value {
    validateKey(key);
    var obj = db.get(key);
    if (!Util.isPrimeObject(obj)) {
      return objectUtil.unflatten(db.getPrefixed(key), key);
    }
    return obj;
  }

  public function set(key:Key, value:Value):Void {
    validateKey(key);
    //db.set(key, value);
    objectUtil.iterate(value, key, db.set, (k:Key, v:Value)->db.set(k, (v is Array ? [] : {})));
  }

  public function del(key:Key):Void {
    validateKey(key);
    return db.del(key);
  }

  public function close():Void {
    return db.close();
  }

  private static function validateKey(key:Key):Void {
    if (!KeyRegex.match(key)) {
      throw new InvalidKeyException(key);
    }
  }

  /*
  private static function splitKey(key:Key):Array<Key> {
    return key.split(KeySeparator);
  }

  private static function keyLast(key:Key):Key {
    return splitKey(key).pop();
  }
  */
}