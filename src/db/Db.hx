package db;

using Types;

abstract class Db {
  private final keySeparator:String;

  public function new(keySeparator:String) {
    this.keySeparator = keySeparator;
  }

  abstract public function get(store:StoreName, key:Key):Value;
  abstract public function getPrefixed(store:StoreName, key:Key):Rows;

  abstract public function set(store:StoreName, key:Key, value:Value):Void;

  abstract public function del(store:StoreName, key:Key):Void;
  abstract public function delPrefixed(store:StoreName, key:Key):Void;

  public function close():Void {};
}