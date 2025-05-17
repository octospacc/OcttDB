package db;

using Types;

abstract class Db {
  private final keySeparator:String;

  public function new(keySeparator:String) {
    this.keySeparator = keySeparator;
  }

  abstract public function get(key:Key):Value;
  abstract public function getPrefixed(key:Key):Rows;

  abstract public function set(key:Key, value:Value):Void;

  abstract public function del(key:Key):Void;
  abstract public function delPrefixed(key:Key):Void;

  public function close():Void {};
}