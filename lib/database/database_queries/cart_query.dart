class CartQuery {
  static const String TABLE_NAME = "carts";
  static const String CREATE_TABLE =
      " CREATE TABLE IF NOT EXISTS $TABLE_NAME ( id INTEGER PRIMARY KEY , userId INTEGER , title TEXT , price INTEGER , quantity INTEGER, total INTEGER , discountPercentage REAL , discountedPrice INTEGER ) ";
  static const String SELECT = "select * from $TABLE_NAME";
}
