package db.sqlite;

using Types;

#if python
@:pythonImport("sqlite3")
private extern class PySqlite {
  static function connect(path:String):PyConnection;
}

private extern class PyConnection {
  public function execute(sql:String):PyCursor;
  public function commit():Void;
  public function close():Void;
}

private extern class PyCursor {
  public function fetchall():Array<Dynamic>;
  public function fetchone():Dynamic;
}
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
    #if php
    connection.startTransaction();
    #end

    #if python
    connection.execute(sql);
    #else
    connection.request(sql);
    #end

    connection.commit();
  }

  public function query(sql:String):Array<Dynamic> {
    #if python
    return connection.execute(sql).fetchall();
    #elseif js
    return []; // TODO
    #else
    var list = [];
    var resultSet = connection.request(sql);
    for (item in (resultSet:Iterator<Row>)) {
      list.push([item.key, item.value]);
    }
    return list;
    #end
  }

  public function close() {
    connection.close();
  }
}