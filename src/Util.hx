class Util {
  public static function isPrimeObject(obj:Dynamic) {
    return (obj == null || obj is Bool || obj is Int || obj is Float || obj is String);
  }
}