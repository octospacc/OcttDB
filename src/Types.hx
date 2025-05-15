typedef Key = String;
typedef Value = Any;

typedef Row = { key: Key, value: Value };
typedef Rows = Array<Row>;

enum DbDriver {
  Sqlite;
  SqliteMemory;
}