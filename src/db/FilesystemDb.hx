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
    this.path = path = '${path}/data/';
    FileSystem.createDirectory(path);
  }

  public function get(key:Key):Value {
    final path = getFilePath(key);
    return (FileSystem.exists(path)
      ? Json.parse(File.getContent(path))
      : null);
  }

  public function getPrefixed(key:Key):Rows {
    throw new haxe.exceptions.NotImplementedException();
    // TODO: we must recursively enumerate files
  }

  public function set(key:Key, value:Value):Void {
    FileSystem.createDirectory(getDirectoryPath(key));
    File.saveContent(getFilePath(key), Json.stringify(value));
  }

  public function del(key:Key):Void {
    final path = getFilePath(key);
    if (FileSystem.exists(path)) {
      FileSystem.deleteFile(path);
    }
  }

  public function delPrefixed(key:Key):Void {
    throw new haxe.exceptions.NotImplementedException();
    // TODO: first we must empty the directory in question (and subdirectories)
    FileSystem.deleteDirectory(getPath(key));
  }

  private function getPath(key:Key):String {
    return path + key.replace(keySeparator, "/");
  }

  private function getFilePath(key:Key):String {
    return getPath(key) + '.json';
  }

  private function getDirectoryPath(key:Key):String {
    return getPath(key).split("/").slice(0, -1).join("/");
  }
}