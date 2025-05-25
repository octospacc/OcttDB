using Types;

class Test {
  static public function main():Void {
    var db = new OcttDbInternal("test.sqlite", DbDriver.Sqlite);
    var store = db.store("data");

    var alice = { name: null, age: 30, tags: ["'admin'", '"beta"'], props: [{ name: "funny", value: 11, extra: { verified: false, status: null } }] };

    trace("set alice", alice);
    store.set("alice", alice);

    alice.name = "Alice";
    trace("set .name", alice.name);
    store.set("alice.name", alice.name);

    trace("get alice", store.get("alice"));
    trace("get .name", store.get("alice.name"));
    trace("get .age", store.get("alice.age"));
    trace("get .tags", store.get("alice.tags"));
    trace("get ..0", store.get("alice.tags.0"));
    trace("get .props", store.get("alice.props"));
    trace("get ..0", store.get("alice.props.0"));
    trace("get ...name", store.get("alice.props.0.name"));
    trace("get ...extra", store.get("alice.props.0.extra"));
    trace("get ....verified", store.get("alice.props.0.extra.verified"));
    trace("get ....status", store.get("alice.props.0.extra.status"));

    trace("del .name");
    store.del("alice.name");
    trace("get .name", store.get("alice.name"));
    trace("get alice", store.get("alice"));

    trace("del alice");
    store.del("alice");
    trace("get alice", store.get("alice"));

    trace("get alice", store.get("alice"));
    trace("get .props", store.get("alice.props"));

    db.close();
  }
}

private class OcttDbInternal extends OcttDb {
  override public function store(name:StoreName) {
    return new StoreInternal(name, db, objectUtil, usePaths);
  }
}

private class StoreInternal extends Store {
  override public function get(key:Key):Value {
    return getInternal(key);
  }

  override public function set(key:Key, value:Value):Void {
    setInternal(key, value);
  }
}