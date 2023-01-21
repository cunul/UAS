class OrderQuery {
  static const String TABLE_NAME = "orders";
  static const String CREATE_TABLE =
      " CREATE TABLE IF NOT EXISTS $TABLE_NAME ( id INTEGER PRIMARY KEY , userId INTEGER , orderNumber TEXT , orderDate TEXT , recipientName TEXT, recipientAddress TEXT , recipientPhone TEXT , latlong TEXT , orderStatus INTEGER , receipt TEXT , totalPrice INTEGER , shippingFee INTEGER , totalAmount INTEGER ) ";
  static const String SELECT = "select * from $TABLE_NAME";
}
