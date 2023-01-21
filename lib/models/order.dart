// To parse this JSON data, do
//
//     final order = orderFromJson(jsonString);

import 'dart:convert';

Order orderFromJson(String str) => Order.fromJson(json.decode(str));

String orderToJson(Order data) => json.encode(data.toJson());

class Order {
  Order({
    this.id,
    required this.userId,
    required this.orderNumber,
    required this.orderDate,
    required this.recipientName,
    required this.recipientAddress,
    required this.recipientPhone,
    required this.latlong,
    required this.orderStatus,
    this.receipt,
    required this.totalPrice,
    required this.shippingFee,
    required this.totalAmount,
  });

  int? id;
  int userId;
  String orderNumber;
  String orderDate;
  String recipientName;
  String recipientAddress;
  String recipientPhone;
  String latlong;
  int orderStatus;
  String? receipt;
  int totalPrice;
  int shippingFee;
  int totalAmount;

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json["id"],
        userId: json["userId"],
        orderNumber: json["orderNumber"],
        orderDate: json["orderDate"],
        recipientName: json["recipientName"],
        recipientAddress: json["recipientAddress"],
        recipientPhone: json["recipientPhone"],
        latlong: json["latlong"],
        orderStatus: json["orderStatus"],
        receipt: json["receipt"],
        totalPrice: json["totalPrice"],
        shippingFee: json["shippingFee"],
        totalAmount: json["totalAmount"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "orderNumber": orderNumber,
        "orderDate": orderDate,
        "recipientName": recipientName,
        "recipientAddress": recipientAddress,
        "recipientPhone": recipientPhone,
        "latlong": latlong,
        "orderStatus": orderStatus,
        "receipt": receipt,
        "totalPrice": totalPrice,
        "shippingFee": shippingFee,
        "totalAmount": totalAmount,
      };
}
