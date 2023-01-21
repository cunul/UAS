class AddressQuery {
  static const String TABLE_NAME = "addresses";
  static const String CREATE_TABLE =
      " CREATE TABLE IF NOT EXISTS $TABLE_NAME ( id INTEGER PRIMARY KEY AUTOINCREMENT , userId INTEGER , recipientName TEXT , recipientAddress TEXT, recipientPhone TEXT , latlong TEXT ) ";
  static const String SELECT = "select * from $TABLE_NAME";
}
