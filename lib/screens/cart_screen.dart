import 'package:flutter/material.dart';
import 'package:project_app/constants/app_constants.dart';
import 'package:project_app/database/database_queries/cart_query.dart';
import 'package:project_app/database/db_helper.dart';
import 'package:project_app/models/cart.dart';
import 'package:project_app/preferences.dart';
import 'package:project_app/screens/checkout_screen.dart';
import 'dart:math' as math;

import 'package:project_app/screens/home_screen.dart';
import 'package:project_app/utils.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final DbHelper _helper = DbHelper();

  List<Cart> cartList = [];
  bool _isLoading = false;
  int total = 0;

  @override
  void initState() {
    super.initState();

    _getCart();
  }

  _getCart() async {
    setState(() {
      _isLoading = true;
    });

    if (Preferences().user != null) {
      cartList.clear();

      await _helper
          .getDataByUserId(CartQuery.TABLE_NAME, Preferences().user!.id)
          .then((value) {
        for (var element in value) {
          Cart cartItem = Cart.fromJson(element);
          cartList.add(cartItem);
          total += cartItem.discountedPrice;
          print(cartItem.toJson());
        }
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  _updateCart(Cart productCart) async {
    await _helper.update(CartQuery.TABLE_NAME, productCart.toJson());
    await _getCart();
  }

  _deleteCartItem(int id) async {
    setState(() {
      _isLoading = true;
    });

    await _helper.delete(CartQuery.TABLE_NAME, id);
    await _getCart();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : cartList.isNotEmpty
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        itemBuilder: (context, index) {
                          var item = cartList[index];

                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 18.0, vertical: 18.0),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.title),
                                    const SizedBox(height: 8),
                                    Text(
                                      formatPrice(item.discountedPrice),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        int discountedPrice = (item.price -
                                                (item.price *
                                                    item.discountPercentage /
                                                    100))
                                            .ceil();

                                        if (item.quantity == 1) {
                                          _deleteCartItem(item.id);
                                        } else {
                                          int quantity = item.quantity -= 1;

                                          _updateCart(Cart(
                                            userId: Preferences().user!.id,
                                            id: item.id,
                                            title: item.title,
                                            price: item.price,
                                            discountPercentage:
                                                item.discountPercentage,
                                            discountedPrice: discountedPrice,
                                            quantity: quantity,
                                            total: discountedPrice * quantity,
                                          ));
                                        }
                                      },
                                      child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 9, horizontal: 12),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black45)),
                                          child: Text('-')),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 9, horizontal: 12),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black45)),
                                      child: Text(item.quantity.toString()),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        int discountedPrice = (item.price -
                                                (item.price *
                                                    item.discountPercentage /
                                                    100))
                                            .ceil();

                                        int quantity = item.quantity += 1;

                                        _updateCart(Cart(
                                          userId: Preferences().user!.id,
                                          id: item.id,
                                          title: item.title,
                                          price: item.price,
                                          discountPercentage:
                                              item.discountPercentage,
                                          discountedPrice: discountedPrice,
                                          quantity: quantity,
                                          total: discountedPrice * quantity,
                                        ));
                                      },
                                      child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 9, horizontal: 12),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black45)),
                                          child: Text('+')),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                        onTap: () {
                                          _deleteCartItem(item.id);
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 9, horizontal: 12),
                                          child: Icon(
                                              Icons.delete_outline_rounded),
                                        ))
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                        itemCount: cartList.length,
                        separatorBuilder: (context, index) {
                          return Divider(
                            endIndent: 18.0,
                            indent: 18.0,
                          );
                        },
                      ),
                      Divider(
                        endIndent: 18.0,
                        indent: 18.0,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 18.0),
                        padding: EdgeInsets.symmetric(
                            horizontal: 18.0, vertical: 18.0),
                        decoration:
                            BoxDecoration(color: AppConstants.kAccentColor),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formatPrice(total),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Total',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ]),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CheckoutScreen(
                                          carts: cartList,
                                          subTotal: total * 15145,
                                          isCart: true,
                                        ))).then((value) {
                              _getCart();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                              minimumSize: Size.fromHeight(44)),
                          child: Text('LANJUT'),
                        ),
                      )
                    ],
                  ),
                )
              : Center(
                  child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi),
                          child: Image.asset('assets/empty-shopping-cart.png')),
                      const SizedBox(height: 16),
                      Text(
                        'Keranjang Belanjamu Kosong',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tambah produk dulu yuk!',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomeScreen()))
                                .then((value) {
                              _getCart();
                            });
                          },
                          child: Text('Belanja Sekarang'))
                    ],
                  ),
                )),
    );
  }
}
