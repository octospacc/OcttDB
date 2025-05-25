using Types;

import db.Db;
import haxe.Json;

class Store {
  private final store:StoreName;
  private var db:Db;
  private final objectUtil:ObjectUtil;
  private final usePaths:Bool;

  public function new(name:StoreName, db:Db, objectUtil:ObjectUtil, usePaths:Bool):Void {
    this.store = name;
    this.db = db;
    this.objectUtil = objectUtil;
    this.usePaths = usePaths;
  }

  public function get(key:Key):Value {
    final json = getJson(key);
    #if js
    return js.Syntax.code("JSON.parse({0})", json);
    #elseif php
    return php.Syntax.code("json_decode({0})", json);
    #elseif python
    return python.Syntax.code("__import__('json').loads({0})", json);
    #end
  }

  public function set(key:Key, value:Value):Void {
    #if js
    final json = js.Syntax.code("JSON.stringify({0})", value);
    #elseif php
    final json = php.Syntax.code("json_encode({0})", value);
    #elseif python
    final json = python.Syntax.code("__import__('json').dumps({0})", value);
    #end
    setJson(key, json);
  }

  public function del(key:Key):Void {
    objectUtil.validateKey(key);
    db.del(store, key);
    if (usePaths) {
      db.delPrefixed(store, key);
    }
  }

  public function getJson(key:Key):String {
    return Json.stringify(getInternal(key));
  }

  public function setJson(key:Key, json:String):Void {
    setInternal(key, Json.parse(json));
  }

  private function getInternal(key:Key):Value {
    objectUtil.validateKey(key);
    final obj = db.get(store, key);
    if (usePaths && !Util.isPrimeObject(obj)) {
      return objectUtil.unflatten(db.getPrefixed(store, key), key);
    } else {
      return obj;
    }
  }

  private function setInternal(key:Key, value:Value):Void {
    objectUtil.validateKey(key);
    if (usePaths) {
      objectUtil.iterate(value, store, key, db.set, (store:StoreName, key:Key, value:Value)->{
        del(key);
        db.set(store, key, (value is Array ? [] : {}));
      });
    } else {
      db.set(store, key, value);
    }
  }
}