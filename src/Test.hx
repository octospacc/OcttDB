using Types;

class Test {
  static public function main():Void {
    var db = new OcttDbInternal("test.sqlite", DbDriver.Sqlite);

    var alice = { name: null, age: 30, tags: ["'admin'", '"beta"'], props: [{ name: "funny", value: 11, extra: { verified: false, status: null } }] };

    trace("set alice", alice);
    db.set("alice", alice);

    alice.name = "Alice";
    trace("set .name", alice.name);
    db.set("alice.name", alice.name);

    trace("get alice", db.get("alice"));
    trace("get .name", db.get("alice.name"));
    trace("get .age", db.get("alice.age"));
    trace("get .tags", db.get("alice.tags"));
    trace("get ..0", db.get("alice.tags.0"));
    trace("get .props", db.get("alice.props"));
    trace("get ..0", db.get("alice.props.0"));
    trace("get ...name", db.get("alice.props.0.name"));
    trace("get ...extra", db.get("alice.props.0.extra"));
    trace("get ....verified", db.get("alice.props.0.extra.verified"));
    trace("get ....status", db.get("alice.props.0.extra.status"));

    trace("del .name");
    db.del("alice.name");
    trace("get .name", db.get("alice.name"));
    trace("get alice", db.get("alice"));

    trace("del alice");
    db.del("alice");
    trace("get alice", db.get("alice"));

    trace("get alice", db.get("alice"));
    trace("get .props", db.get("alice.props"));

    db.close();
  }
}

private class OcttDbInternal extends OcttDb {
  override public function get(key:Key):Value {
    return getInternal(key);
  }

  override public function set(key:Key, value:Value):Void {
    setInternal(key, value);
  }
}