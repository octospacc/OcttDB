using Types;
using StringTools;

import db.Db;
import db.sqlite.SqliteConnection;
import db.sqlite.SqliteDb;
import haxe.Json;

private final Defaults = {
  KeySeparator: ".",
  KeyRegex: "^(?!\\.)(?!.*\\.\\.)(?!.*\\.$)[A-Za-z0-9._]+$",
}

class InvalidKeyException extends haxe.Exception {}

class OcttDb {
  private var db:Db;
  private final objectUtil:ObjectUtil;
  private final keyRegex:EReg;
  private final usePaths:Bool;

  public function new(name:String, driver:DbDriver, ?options:{ ?keySeparator:String, ?keyRegex:String, ?usePaths:Bool }):Void {
    final keySeparator = options?.keySeparator != null ? options.keySeparator : Defaults.KeySeparator;

    objectUtil = new ObjectUtil(keySeparator);
    keyRegex = new EReg(options?.keyRegex != null ? options.keyRegex : Defaults.KeyRegex, "");
    usePaths = options?.usePaths == false ? false : true;

    switch (driver) {
      case DbDriver.Sqlite:
        var connection = new SqliteConnection(name);
        db = new SqliteDb(connection, keySeparator);
      case DbDriver.SqliteMemory:
        var connection = new SqliteConnection(":memory:");
        db = new SqliteDb(connection, keySeparator);
      case Filesystem:
        db = new db.FilesystemDb(name, keySeparator);
    }
  }

  public function get(key:Key):Value {
    final json = getJson(key);
    #if js
    return js.Syntax.code("JSON.parse({0})", json);
    #elseif php
    return php.Syntax.code("json_decode({0})", json);
    #elseif python
    python.Syntax.code("from json import loads as json_loads");
    return python.Syntax.code("json_loads({0})", json);
    #end
  }

  public function set(key:Key, value:Value):Void {
    #if js
    final json = js.Syntax.code("JSON.stringify({0})", value);
    #elseif php
    final json = php.Syntax.code("json_encode({0})", value);
    #elseif python
    python.Syntax.code("from json import dumps as json_dumps");
    final json = python.Syntax.code("json_dumps({0})", value);
    #end
    setJson(key, json);
  }

  public function del(key:Key):Void {
    validateKey(key);
    db.del(key);
    if (usePaths) {
      db.delPrefixed(key);
    }
  }

  public function getJson(key:Key):String {
    return Json.stringify(getInternal(key));
  }

  public function setJson(key:Key, json:String):Void {
    setInternal(key, Json.parse(json));
  }

  private function getInternal(key:Key):Value {
    validateKey(key);
    final obj = db.get(key);
    if (usePaths && !Util.isPrimeObject(obj)) {
      return objectUtil.unflatten(db.getPrefixed(key), key);
    } else {
      return obj;
    }
  }

  private function setInternal(key:Key, value:Value):Void {
    validateKey(key);
    if (usePaths) {
      //value = Util.normalizeValue(value);
      objectUtil.iterate(value, key, db.set, (key:Key, value:Value)->{
        del(key);
        db.set(key, (value is Array ? [] : {}));
      });
    } else {
      db.set(key, value);
    }
  }

  public function close():Void {
    db.close();
    db = null;
  }

  private function validateKey(key:Key):Void {
    if (!keyRegex.match(key)) {
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