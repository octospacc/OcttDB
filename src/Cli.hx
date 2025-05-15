
class Cli {
  static public function main():Void {
    var args:Array<String> = Sys.args();
    var dbName:String = null;

    while (args.length > 0) {
      switch (args[0]) {
        case "-d","--db":
          args.shift(); dbName = args.shift();
        default:
          break;
      }
    }

    if (args.length == 0 || dbName == null) {
      showHelp();
    } else {
      var db = new OcttDb(dbName, Types.DbDriver.Sqlite);
      var cmd = args.shift();
      switch (cmd) {
        case "get": runGet(db, args);
        case "set": runSet(db, args);
        case "del": runDel(db, args);
        default: showHelp();
      }
    }
  }

  static private function showHelp():Void {
    Sys.stdout().writeString('Usage: octtdb --db <name> <get/set/del> <...>');
  }

  static private function runGet(db, args):Void {
    if (args.length == 1) {
      printResult(db.get(args[0]));
    } else {
      showHelp();
    }
  }

  static private function runSet(db, args):Void {
    if (args.length == 2) {
      db.set(args[0], haxe.Json.parse(args[1]));
    } else {
      showHelp();
    }
  }

  static private function runDel(db, args):Void {
    if (args.length == 1) {
      db.del(args[0]);
    } else {
      showHelp();
    }
  }

  static private function printResult(result):Void {
    Sys.stdout().writeString(Std.string(result));
  }
}