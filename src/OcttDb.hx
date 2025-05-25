using Types;
using StringTools;

import db.Db;
import db.sqlite.SqliteConnection;
import db.sqlite.SqliteDb;

private final Defaults = {
  KeySeparator: ".",
  KeyRegex: "^(?!\\.)(?!.*\\.\\.)(?!.*\\.$)[A-Za-z0-9._]+$",
}

class InvalidStoreException extends haxe.Exception {}

class OcttDb {
  private var db:Db;
  private final objectUtil:ObjectUtil;
  private final usePaths:Bool;

  public function new(name:String, driver:DbDriver, ?options:{ ?keySeparator:String, ?keyRegex:String, ?usePaths:Bool }):Void {
    final keySeparator = options?.keySeparator != null ? options.keySeparator : Defaults.KeySeparator;

    objectUtil = new ObjectUtil(keySeparator, (options?.keyRegex != null ? options.keyRegex : Defaults.KeyRegex));
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

  public function store(name:StoreName) {
    if (!(new EReg("^[A-Za-z0-9-_]+$", "")).match(name)) {
      throw new InvalidStoreException(name);
    }
    return new Store(name, db, objectUtil, usePaths);
  }

  public function close():Void {
    db.close();
    db = null;
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