import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_app/constants/app_constants.dart';
import 'package:project_app/database/database_queries/address_query.dart';
import 'package:project_app/database/database_queries/cart_query.dart';
import 'package:project_app/database/database_queries/order_products_query.dart';
import 'package:project_app/database/database_queries/order_query.dart';
import 'package:project_app/database/db_helper.dart';
import 'package:project_app/models/address.dart';
import 'package:project_app/models/cart.dart';
import 'package:project_app/models/order.dart';
import 'package:project_app/models/order_product.dart';
import 'package:project_app/preferences.dart';
import 'package:project_app/screens/address_form_screen.dart';
import 'package:project_app/screens/order_detail_screen.dart';
import 'package:project_app/utils.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Cart> carts;
  final int subTotal;
  final bool isCart;
  const CheckoutScreen(
      {Key? key,
      required this.carts,
      required this.subTotal,
      this.isCart = false})
      : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoading = false;
  List<Address> addressList = [];
  final _helper = DbHelper();

  Address? selectedAddress;

  bool _checkoutLoad = false;
  String orderNumber = '';

  @override
  void initState() {
    super.initState();

    _getAddress();
  }

  _getAddress() async {
    setState(() {
      _isLoading = true;
    });

    addressList.clear();

    await _helper
        .getDataByUserId(AddressQuery.TABLE_NAME, Preferences().user!.id)
        .then((value) {
      for (var element in value) {
        Address item = Address.fromJson(element);

        if (item.userId == Preferences().user!.id) {
          addressList.add(item);
        }

        print(item.toJson());
      }
    });

    if (addressList.isNotEmpty) {
      selectedAddress = addressList.first;
    }

    setState(() {
      _isLoading = false;
    });
  }

  _addTransaction() async {
    setState(() {
      _checkoutLoad = true;
    });

    int timestamp = DateTime.now().millisecondsSinceEpoch;
    int userId = Preferences().user!.id;
    orderNumber = "SHP$timestamp$userId";

    Order newOrder = Order(
      userId: userId,
      orderNumber: orderNumber,
      orderDate: timestamp.toString(),
      recipientName: selectedAddress!.recipientName,
      recipientAddress: selectedAddress!.recipientAddress,
      recipientPhone: selectedAddress!.recipientPhone,
      latlong: selectedAddress!.latlong,
      orderStatus: defineOrderStatus(OrderStatus.PENDING),
      totalPrice: widget.subTotal,
      shippingFee: AppConstants.FLAT_COST,
      totalAmount: widget.subTotal + AppConstants.FLAT_COST,
    );

    await _helper.insert(OrderQuery.TABLE_NAME, newOrder.toJson());

    for (var product in widget.carts) {
      OrderProduct orderProduct = OrderProduct(
          userId: userId,
          orderNumber: orderNumber,
          title: product.title,
          price: product.price,
          quantity: product.quantity,
          total: product.total,
          discountPercentage: product.discountPercentage,
          discountedPrice: product.discountedPrice);

      await _helper.insert(
          OrderProductsQuery.TABLE_NAME, orderProduct.toJson());
    }

    if (widget.isCart) {
      for (var cartItem in widget.carts) {
        await _helper.delete(CartQuery.TABLE_NAME, cartItem.id);
      }
    }

    setState(() {
      _checkoutLoad = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shipping Method'.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                            'REG - ${NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0).format(AppConstants.FLAT_COST)}'),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Shipping Address'.toUpperCase(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (selectedAddress != null)
                              InkWell(
                                onTap: () {
                                  showDialog<void>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text(
                                          'Ubah Alamat',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        content: SingleChildScrollView(
                                          child: ListBody(
                                              children: addressList
                                                  .map(
                                                    (e) => InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          selectedAddress = e;
                                                        });

                                                        Navigator.pop(context);
                                                      },
                                                      child: Container(
                                                        margin: EdgeInsets.only(
                                                            bottom: 8.0),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    18.0,
                                                                vertical: 18.0),
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors
                                                                    .black45)),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    e.recipientName,
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                Icon(
                                                                  Icons
                                                                      .check_rounded,
                                                                  color: e.id ==
                                                                          selectedAddress!
                                                                              .id
                                                                      ? Colors.amber[
                                                                          800]
                                                                      : Colors
                                                                          .grey,
                                                                )
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                                height: 8),
                                                            Text(e
                                                                .recipientPhone),
                                                            const SizedBox(
                                                                height: 4),
                                                            Text(e
                                                                .recipientAddress),
                                                            const SizedBox(
                                                                height: 4),
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .location_on,
                                                                  size: 16,
                                                                  color: AppConstants
                                                                      .kPrimaryColor,
                                                                ),
                                                                const SizedBox(
                                                                    width: 4),
                                                                Expanded(
                                                                    child: Text(
                                                                        '(${e.latlong})')),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                  .toList()),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Text(
                                  'UBAH ALAMAT',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: AppConstants.kPrimaryColor,
                                      fontSize: 13),
                                ),
                              )
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (selectedAddress == null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Belum ada alamat'),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AddressFormScreen()))
                                      .then((value) {
                                    _getAddress();
                                  });
                                },
                                child: Text(
                                  'Atur alamat',
                                  style: TextStyle(color: Colors.amber[800]),
                                ),
                              ),
                            ],
                          ),
                        if (selectedAddress != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 18.0, vertical: 18.0),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black45)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedAddress!.recipientName,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(selectedAddress!.recipientPhone),
                                const SizedBox(height: 4),
                                Text(selectedAddress!.recipientAddress),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: AppConstants.kPrimaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                        child: Text(
                                            '(${selectedAddress!.latlong})')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 32),
                        Text(
                          'Payment'.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Transfer Bank'),
                        const SizedBox(height: 4),
                        Text('* Upload bukti transfer untuk pengecekan'),
                        const SizedBox(height: 32),
                        Text(
                          'Detail Order'.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      var item = widget.carts[index];

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
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        formatPrice(item.discountedPrice),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('x${item.quantity}')
                                  ],
                                ),
                              ],
                            )),
                          ],
                        ),
                      );
                    },
                    itemCount: widget.carts.length,
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
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('Subtotal'),
                        ),
                        const SizedBox(width: 8),
                        Text(NumberFormat.currency(
                                locale: 'id', symbol: 'Rp', decimalDigits: 0)
                            .format(widget.subTotal))
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('Shipping Fee'),
                        ),
                        const SizedBox(width: 8),
                        Text(NumberFormat.currency(
                                locale: 'id', symbol: 'Rp', decimalDigits: 0)
                            .format(AppConstants.FLAT_COST))
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'TOTAL',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          NumberFormat.currency(
                                  locale: 'id', symbol: 'Rp', decimalDigits: 0)
                              .format(AppConstants.FLAT_COST + widget.subTotal),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: ElevatedButton(
                      onPressed: !_checkoutLoad && selectedAddress != null
                          ? () async {
                              await _addTransaction();

                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OrderDetailScreen(
                                            orderNumber: orderNumber,
                                          )));
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                          minimumSize: Size.fromHeight(44)),
                      child: _checkoutLoad == true
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                // color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text('CHECKOUT'),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
