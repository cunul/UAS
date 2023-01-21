// To parse this JSON data, do
//
//     final orderProduct = orderProductFromJson(jsonString);

import 'dart:convert';

OrderProduct orderProductFromJson(String str) =>
    OrderProduct.fromJson(json.decode(str));

String orderProductToJson(OrderProduct data) => json.encode(data.toJson());

class OrderProduct {
  OrderProduct({
    this.id,
    required this.userId,
    required this.orderNumber,
    required this.title,
    required this.price,
    required this.quantity,
    required this.total,
    required this.discountPercentage,
    required this.discountedPrice,
  });

  int? id;
  int userId;
  String orderNumber;
  String title;
  int price;
  int quantity;
  int total;
  double discountPercentage;
  int discountedPrice;

  factory OrderProduct.fromJson(Map<String, dynamic> json) => OrderProduct(
        id: json["id"],
        userId: json["userId"],
        orderNumber: json["orderNumber"],
        title: json["title"],
        price: json["price"],
        quantity: json["quantity"],
        total: json["total"],
        discountPercentage: json["discountPercentage"].toDouble(),
        discountedPrice: json["discountedPrice"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "orderNumber": orderNumber,
        "title": title,
        "price": price,
        "quantity": quantity,
        "total": total,
        "discountPercentage": discountPercentage,
        "discountedPrice": discountedPrice,
      };
}
