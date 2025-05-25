package db;

using Types;
using StringTools;

import haxe.Json;
import sys.FileSystem;
import sys.io.File;

class FilesystemDb extends Db {
  private final path:String;

  public function new(path:String, keySeparator:String):Void {
    super(keySeparator);
    this.path = path;
    FileSystem.createDirectory(path);
  }

  public function get(store:StoreName, key:Key):Value {
    final path = getFilePath(store, key);
    return (FileSystem.exists(path)
      ? Json.parse(File.getContent(path))
      : null);
  }

  public function getPrefixed(store:StoreName, key:Key):Rows {
    throw new haxe.exceptions.NotImplementedException();
    // TODO: we must recursively enumerate files
  }

  public function set(store:StoreName, key:Key, value:Value):Void {
    FileSystem.createDirectory(getDirectoryPath(store, key));
    File.saveContent(getFilePath(store, key), Json.stringify(value));
  }

  public function del(store:StoreName, key:Key):Void {
    final path = getFilePath(store, key);
    if (FileSystem.exists(path)) {
      FileSystem.deleteFile(path);
    }
  }

  public function delPrefixed(store:StoreName, key:Key):Void {
    throw new haxe.exceptions.NotImplementedException();
    // TODO: first we must empty the directory in question (and subdirectories)
    FileSystem.deleteDirectory(getPath(store, key));
  }

  private function getPath(store:StoreName, key:Key):String {
    return '${path}/${store}/${key.replace(keySeparator, "/")}';
  }

  private function getFilePath(store:StoreName, key:Key):String {
    return getPath(store, key) + '.json';
  }

  private function getDirectoryPath(store:StoreName, key:Key):String {
    return getPath(store, key).split("/").slice(0, -1).join("/");
  }
}