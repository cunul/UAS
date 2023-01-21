// To parse this JSON data, do
//
//     final address = addressFromJson(jsonString);

import 'dart:convert';

Address addressFromJson(String str) => Address.fromJson(json.decode(str));

String addressToJson(Address data) => json.encode(data.toJson());

class Address {
  Address({
    this.id,
    required this.userId,
    required this.recipientName,
    required this.recipientAddress,
    required this.recipientPhone,
    required this.latlong,
  });

  int? id;
  int userId;
  String recipientName;
  String recipientAddress;
  String recipientPhone;
  String latlong;

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json["id"],
        userId: json["userId"],
        recipientName: json["recipientName"],
        recipientAddress: json["recipientAddress"],
        recipientPhone: json["recipientPhone"],
        latlong: json["latlong"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "recipientName": recipientName,
        "recipientAddress": recipientAddress,
        "recipientPhone": recipientPhone,
        "latlong": latlong,
      };
}
