package db.sqlite;

using Types;
using StringTools;

import haxe.Json;

class SqliteDb extends Db {
  private final connection:SqliteConnection;

  public function new(connection:SqliteConnection, keySeparator:String):Void {
    super(keySeparator);
    this.connection = connection;

    connection.execute('
      CREATE TABLE IF NOT EXISTS data (
        key TEXT PRIMARY KEY UNIQUE,
        value TEXT);
    ');
  }

  public function get(key:Key):Value {
    var rows = connection.query('SELECT key,value FROM data WHERE key = "${key}";');
    return (rows.length == 0 ? null : Json.parse(rows[0][1]));
    //return Json.parse(connection.query('SELECT value FROM data WHERE key = "${key}";'));
  }

  public function getPrefixed(key:Key):Rows {
    var list:Rows = [];
    var rows = connection.query('SELECT key,value FROM data WHERE key LIKE "${key}${keySeparator}%";');
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
  }

  public function delPrefixed(key:Key):Void {
    connection.execute('DELETE FROM data WHERE key LIKE "${key}${keySeparator}%";');
  }

  override public function close():Void {
    connection.close();
  }
}