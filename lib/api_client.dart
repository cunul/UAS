import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:project_app/models/product.dart';
import 'package:project_app/models/user.dart';
import 'package:project_app/preferences.dart';

class ApiClient extends ChangeNotifier {
  getToken() async {
    try {
      http.Response response = await http.post(
          Uri.parse('https://dummyjson.com/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body:
              json.encode({'username': 'brickeardn', 'password': 'bMQnPttV'}));

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);

        Preferences().token = responseBody['token'];
      }
      print(Preferences().token);
    } catch (e) {
      print(e);
    }
  }

  List<Product> products = [];
  List<Product> tempProducts = [];

  int limit = 10;
  int skip = 0;

  fetchProduct() async {
    tempProducts.clear();

    if (products.isEmpty) {
      skip = 0;
    }

    try {
      http.Response response = await http.get(
        Uri.parse('https://dummyjson.com/products?limit=$limit&skip=$skip'),
      );

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);

        print({'log products': responseBody});

        if (responseBody['products'].isNotEmpty) {
          for (var product in responseBody['products']) {
            tempProducts.add(Product.fromJson(product));
          }

          products.addAll(tempProducts);

          skip += limit;

          fetchProduct();
        }
      }
    } catch (e) {
      print(e);
    }

    notifyListeners();
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    try {
      http.Response response = await http.post(
          Uri.parse('https://dummyjson.com/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'username': username, 'password': password}));

      var responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        Preferences().token = responseBody['token'];
        print({'token': Preferences().token});

        User loggedUser = User.fromJson(responseBody);
        String phone = await getUserDetail(loggedUser.id) ?? '';

        Preferences().user = User(
            id: loggedUser.id,
            username: loggedUser.username,
            email: loggedUser.email,
            firstName: loggedUser.firstName,
            lastName: loggedUser.lastName,
            gender: loggedUser.gender,
            image: loggedUser.image,
            token: loggedUser.token,
            phone: phone);

        return true;
      } else {
        print(responseBody);
        Fluttertoast.showToast(msg: responseBody['message']);
        return false;
      }
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: e.toString());
      return false;
    }
  }

  Future<String?> getUserDetail(int id) async {
    try {
      http.Response response =
          await http.get(Uri.parse('https://dummyjson.com/users/$id'));

      print(response.body);

      var responseBody = json.decode(response.body);
      print(responseBody);

      if (response.statusCode == 200) {
        return responseBody['phone'];
      } else {
        print(responseBody);
        Fluttertoast.showToast(msg: responseBody['message']);
        return null;
      }
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: e.toString());
      return null;
    }
  }
}
