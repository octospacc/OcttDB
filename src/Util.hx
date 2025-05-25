using Types;

class Util {
  public static function isPrimeObject(obj:Dynamic) {
    return (obj == null || obj is Bool || obj is Int || obj is Float || obj is String);
  }

  public static function parseBool(value:Any):Bool {
    switch (Std.string(value).toLowerCase()) {
      case '1', 'true': return true;
      case '0', 'false': return false;
      default: return null;
    }
  }
}