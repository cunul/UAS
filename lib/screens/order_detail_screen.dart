import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:project_app/constants/app_constants.dart';
import 'package:project_app/database/database_queries/order_query.dart';
import 'package:project_app/database/db_helper.dart';
import 'package:project_app/models/order.dart';
import 'package:project_app/models/order_product.dart';
import 'package:project_app/utils.dart';
import 'package:image_picker/image_picker.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderNumber;
  const OrderDetailScreen({Key? key, required this.orderNumber})
      : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final DbHelper _helper = DbHelper();
  late Order order;
  bool _isLoading = false;
  List<OrderProduct> products = [];
  bool _isSendingReceipt = false;
  bool _isSent = false;
  int start = 0;

  @override
  void initState() {
    super.initState();
    _getOrderDetail();
  }

  _getOrderDetail() async {
    setState(() {
      _isLoading = true;
    });

    await _helper.getOrder(widget.orderNumber).then((value) {
      order = value;
    });

    await _helper.getOrderProducts(widget.orderNumber).then((value) {
      products.clear();

      for (var product in value) {
        products.add(OrderProduct.fromJson(product));
      }
    });

    setState(() {
      _isLoading = false;
    });
  }

  _sendReceipt() async {
    setState(() {
      _isSendingReceipt = true;
    });

    Order updatedOrder = Order(
        id: order.id,
        userId: order.userId,
        orderNumber: order.orderNumber,
        orderDate: order.orderDate,
        recipientName: order.recipientName,
        recipientAddress: order.recipientAddress,
        recipientPhone: order.recipientPhone,
        latlong: order.latlong,
        orderStatus: defineOrderStatus(OrderStatus.ON_PROCESS),
        receipt: image!.path,
        totalPrice: order.totalPrice,
        shippingFee: order.shippingFee,
        totalAmount: order.totalAmount);

    await _helper.update(OrderQuery.TABLE_NAME, updatedOrder.toJson());
    image = null;
    _isSent = true;

    setState(() {
      _isSendingReceipt = false;
    });

    var timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        start += 1;
      });
    });

    Future.delayed(Duration(seconds: 5), () async {
      await _getOrderDetail();
      timer.cancel();
    });
  }

  File? image;
  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      Fluttertoast.showToast(msg: 'Failed to pick image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Pesanan')),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                SingleChildScrollView(
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
                              'Order ${order.orderNumber}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                                'Tanggal Order: ${DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(int.parse(order.orderDate)))}'),
                            const SizedBox(height: 8),
                            Text(
                                'Status Order: ${defineOrderStatusName(order.orderStatus)}'),
                            const SizedBox(height: 32),
                            Text(
                              'Payment'.toUpperCase(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                                'Transfer Bank ${AppConstants.bankAccountName}'),
                            const SizedBox(height: 4),
                            SelectableText(
                                'No. Rekening: ${AppConstants.bankAccountNumber}'),
                            const SizedBox(height: 16),
                            if (_isSent && order.orderStatus == 0)
                              Text(
                                  'Bukti dalam pemeriksaan (${start.toString()} detik)'),
                            if (image != null)
                              SizedBox(
                                  height: 100,
                                  width: MediaQuery.of(context).size.width,
                                  child: Image.file(
                                    File(image!.path),
                                    fit: BoxFit.cover,
                                  )),
                            if (order.orderStatus == 0)
                              if (image != null)
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                          onPressed: () {
                                            image = null;

                                            setState(() {});
                                          },
                                          child: Text('Ubah')),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                        onPressed: () {
                                          _sendReceipt();
                                        },
                                        child: Text('Kirim Bukti Pembayaran'))
                                  ],
                                )
                              else if (!_isSent)
                                ElevatedButton(
                                  onPressed: () {
                                    showModalBottomSheet<void>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            ListTile(
                                              leading: Icon(
                                                  Icons.camera_alt_rounded),
                                              title: Text('Camera'),
                                              onTap: () async {
                                                Navigator.pop(context);
                                                await pickImage(
                                                    ImageSource.camera);
                                              },
                                            ),
                                            Divider(height: 0),
                                            ListTile(
                                              leading: Icon(Icons.image),
                                              title: Text('Galeri'),
                                              onTap: () async {
                                                Navigator.pop(context);
                                                await pickImage(
                                                    ImageSource.gallery);
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Text('Upload Bukti Pembayaran'),
                                ),
                            const SizedBox(height: 32),
                            Text(
                              '${'Shipping'.toUpperCase()} - REG',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.recipientName,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(order.recipientAddress),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: AppConstants.kPrimaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(child: Text('(${order.latlong})')),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Phone: ${order.recipientPhone}',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
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
                          var item = products[index];

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
                        itemCount: products.length,
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
                                    locale: 'id',
                                    symbol: 'Rp',
                                    decimalDigits: 0)
                                .format(order.totalPrice))
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
                                    locale: 'id',
                                    symbol: 'Rp',
                                    decimalDigits: 0)
                                .format(order.shippingFee))
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
                                      locale: 'id',
                                      symbol: 'Rp',
                                      decimalDigits: 0)
                                  .format(order.totalAmount),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isSendingReceipt)
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.grey.withOpacity(.6),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
    );
  }
}
