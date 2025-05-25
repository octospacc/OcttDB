package db.sqlite;

using Types;
using StringTools;

import haxe.Json;

class SqliteDb extends Db {
  private final connection:SqliteConnection;

  public function new(connection:SqliteConnection, keySeparator:String):Void {
    super(keySeparator);
    this.connection = connection;
  }

  public function get(store:StoreName, key:Key):Value {
    ensureStore(store);
    var rows = connection.query('SELECT key,value FROM "${store}" WHERE key = "${key}";');
    return (rows.length == 0 ? null : Json.parse(rows[0][1]));
  }

  public function getPrefixed(store:StoreName, key:Key):Rows {
    ensureStore(store);
    var list:Rows = [];
    var rows = connection.query('SELECT key,value FROM "${store}" WHERE key LIKE "${key}${keySeparator}%";');
    for (item in rows) {
      list.push({ key: item[0], value: Json.parse(item[1]) });
    }
    return list;
  }

  public function set(store:StoreName, key:Key, value:Value):Void {
    ensureStore(store);
    value = Json.stringify(value).replace('"', '""');
    connection.execute('
      INSERT INTO "${store}" (key, value) VALUES ("${key}", "${value}")
      ON CONFLICT (key) DO UPDATE SET value = "${value}"
    ;');
  }

  public function del(store:StoreName, key:Key):Void {
    ensureStore(store);
    connection.execute('DELETE FROM "${store}" WHERE key = "${key}";');
  }

  public function delPrefixed(store:StoreName, key:Key):Void {
    ensureStore(store);
    connection.execute('DELETE FROM "${store}" WHERE key LIKE "${key}${keySeparator}%";');
  }

  override public function close():Void {
    connection.close();
  }

  private function ensureStore(store:StoreName):Void {
    connection.execute('
      CREATE TABLE IF NOT EXISTS "${store}" (
        key TEXT PRIMARY KEY UNIQUE,
        value TEXT);
    ');
  }
}