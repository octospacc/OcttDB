using Types;

class Cli {
  static public function main():Void {
    #if js
    js.Syntax.code("if(require.main===module)Cli.appMain();");
    #elseif python
    python.Syntax.code("if __name__=='__main__':Cli.appMain()");
    #end
    // No CLI usage for PHP for now, detecting it properly is tricky
  }

  #if !php
  static public function appMain():Void {
    final args:Array<String> = Sys.args();
    var dbName:String = null;
    var usePaths:Bool = null;

    while (args.length > 0) {
      switch (args[0]) {
        case "-db":
          args.shift();
          dbName = args.shift();
        case "-usePaths":
          args.shift();
          usePaths = Util.parseBool(args.shift());
        default:
          break;
      }
    }

    if (args.length == 0 || dbName == null) {
      showHelp();
    } else {
      var driver:DbDriver = null;
      switch (dbName.split(".").pop().toLowerCase()) {
        case "sqlite", "sqlite3": driver = DbDriver.Sqlite;
        case "d": driver = DbDriver.Filesystem;
        default: showHelp();
      }

      final db = new OcttDb(dbName, driver, { usePaths: usePaths });
      switch (args.shift().toLowerCase()) {
        case "get": runGet(db, args);
        case "set": runSet(db, args);
        case "del": runDel(db, args);
        default: showHelp();
      }
    }
  }

  static private function showHelp():Void {
    printResult('Usage: octtdb <-db name.type> [-usePaths true/false] <get/set/del> <...>');
    Sys.exit(1);
  }

  static private function runGet(db, args):Void {
    if (args.length == 1) {
      printResult(db.getJson(args[0]));
    } else {
      showHelp();
    }
  }

  static private function runSet(db, args):Void {
    if (args.length == 2) {
      db.setJson(args[0], args[1]);
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
  #end
}