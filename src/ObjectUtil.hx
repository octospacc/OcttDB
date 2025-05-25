using StringTools;

import Types;

class InvalidKeyException extends haxe.Exception {}

class ObjectUtil {
  private final keySeparator:String;
  private final keyRegex:EReg;

  public function new(keySeparator:String, keyRegex:String) {
    this.keySeparator = keySeparator;
    this.keyRegex = new EReg(keyRegex, "");
  }

  public function validateKey(key:Key):Void {
    if (!keyRegex.match(key)) {
      throw new InvalidKeyException(key);
    }
  }

  public function iterate(obj:Dynamic, store:StoreName, key:Key, valueCallback:(StoreName->Key->Value->Void), objectCallback:(StoreName->Key->Value->Void)=null):Void {
    switch(Type.typeof(obj)) {
      case TNull, TBool, TInt, TFloat, TClass(String):
        valueCallback(store, key, obj);
      case TClass(Array):
        if (objectCallback != null) {
          objectCallback(store, key, obj);
        }
        for (i in 0...obj.length) {
          iterate(obj[i], store, '${key}${keySeparator}${i}', valueCallback, objectCallback);
        }
      case TObject: // TUnknown:
        if (objectCallback != null) {
          objectCallback(store, key, obj);
        }
        for (field in Reflect.fields(obj)) {
          var value = Reflect.field(obj, field);
          iterate(value, store, '${key}${keySeparator}${field}', valueCallback, objectCallback);
        }
      default: // no-op
    }
  }

  public function unflatten(rows:Rows, rootKey:Key):Dynamic {
    return (new ObjectUnflattener(rows, keySeparator)).unflatten(rootKey);
  }
}

private class ObjectUnflattener {
  private final keySeparator:String;

  private final leafMap:Map<String, Any>;
  private final allKeys:Array<Key>;

  public function new(rows:Rows, keySeparator:String) {
    this.keySeparator = keySeparator;
    leafMap = new Map<String, Any>();
    allKeys = [];
    for (row in rows) {
      leafMap.set(row.key, row.value);
      allKeys.push(row.key);
    }
  }

  public function unflatten(path:String):Dynamic {
    var exact = leafMap.get(path);
    var hasChildren = false;
    for (key in allKeys) {
      if (key.startsWith(path + keySeparator)) {
        hasChildren = true;
        break;
      }
    }
    if (/* exact != null && */ !hasChildren) {
      return exact;
    }

    // 2) Collect the set of immediate child segments
    var prefix = path + keySeparator;
    var segSet:Map<String, Bool> = new Map<String, Bool>();
    for (k in allKeys) {
      if (k.startsWith(prefix)) {
        var suffix = k.substr(prefix.length);
        var parts = suffix.split(keySeparator);
        segSet.set(parts[0], true);
      }
    }
    // flatten into an Array for iteration
    var segments = new Array<String>();
    for (s in segSet.keys()) segments.push(s);

    // 3) Decide if this node is an Array (all segments are numeric) or Object
    var isArray = segments.length > 0;
    for (s in segments) {
      if (Std.parseInt(s) == null) {
        isArray = false;
        break;
      }
    }

    if (isArray) {
      // find max index to size the array
      var maxIdx = 0;
      for (s in segments) {
        var idx = Std.parseInt(s);
        if (idx > maxIdx) maxIdx = idx;
      }
      var arr = new Array<Dynamic>();
      // initialize with nulls
      for (i in 0...maxIdx + 1) arr.push(null);
      // recurse on each index
      for (s in segments) {
        var idx = Std.parseInt(s);
        arr[idx] = unflatten(path + keySeparator + s);
      }
      return arr;
    }
    else { // Build an anonymous object `{…}`
      var obj:Dynamic = {};
      for (s in segments) {
        var child = unflatten(path + keySeparator + s);
        Reflect.setField(obj, s, child);
      }
      return obj;
    }
  }
}