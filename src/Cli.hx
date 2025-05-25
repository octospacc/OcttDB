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
    var storeName:StoreName = null;
    var usePaths:Bool = null;

    while (args.length > 0) {
      switch (args[0]) {
        case "-db":
          args.shift();
          dbName = args.shift();
        case "-store":
          args.shift();
          storeName = args.shift();
        case "-usePaths":
          args.shift();
          usePaths = Util.parseBool(args.shift());
        default:
          break;
      }
    }

    if (args.length == 0 || dbName == null || storeName == null) {
      showHelp();
    } else {
      var driver:DbDriver = null;
      switch (dbName.split(".").pop().toLowerCase()) {
        case "sqlite", "sqlite3":
          driver = DbDriver.Sqlite;
        case "d":
          driver = DbDriver.Filesystem;
        default: showHelp();
      }

      final db = new OcttDb(dbName, driver, { usePaths: usePaths });
      final store = db.store(storeName);
      switch (args.shift().toLowerCase()) {
        case "get": runGet(store, args);
        case "set": runSet(store, args);
        case "del": runDel(store, args);
        default: showHelp(false);
      }
      db.close();
    }
  }

  static private function showHelp(?exit:Bool):Void {
    printResult('Usage: octtdb <-db name.type> <-store name> [-usePaths true/false] <get/set/del> <...>');
    if (exit != false) {
      Sys.exit(1);
    }
  }

  static private function runGet(store, args):Void {
    if (args.length == 1) {
      printResult(store.getJson(args[0]));
    } else {
      showHelp();
    }
  }

  static private function runSet(store, args):Void {
    if (args.length == 2) {
      store.setJson(args[0], args[1]);
    } else {
      showHelp();
    }
  }

  static private function runDel(store, args):Void {
    if (args.length == 1) {
      store.del(args[0]);
    } else {
      showHelp();
    }
  }

  static private function printResult(result):Void {
    Sys.stdout().writeString(Std.string(result));
  }
  #end
}