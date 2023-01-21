class OrderProductsQuery {
  static const String TABLE_NAME = "orderProducts";
  static const String CREATE_TABLE =
      " CREATE TABLE IF NOT EXISTS $TABLE_NAME ( id INTEGER PRIMARY KEY , userId INTEGER , orderNumber TEXT , title TEXT , price INTEGER, quantity INTEGER , total INTEGER , discountPercentage REAL , discountedPrice INTEGER ) ";
  static const String SELECT = "select * from $TABLE_NAME";
}
