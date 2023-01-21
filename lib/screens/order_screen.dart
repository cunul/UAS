import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_app/database/database_queries/order_query.dart';
import 'package:project_app/database/db_helper.dart';
import 'package:project_app/models/order.dart';
import 'package:project_app/preferences.dart';
import 'package:project_app/screens/order_detail_screen.dart';
import 'package:project_app/utils.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  List<Order> orders = [];
  bool _isLoading = false;
  final DbHelper _helper = DbHelper();

  @override
  void initState() {
    super.initState();

    _getOrders();
  }

  _getOrders() async {
    setState(() {
      _isLoading = true;
    });

    await _helper
        .getDataByUserId(OrderQuery.TABLE_NAME, Preferences().user!.id)
        .then((value) {
      for (var order in value) {
        Order item = Order.fromJson(order);

        orders.add(item);

        print(item.toJson());
      }
    });

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pesanan Saya')),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : orders.isEmpty
              ? Center(
                  child: Text('Belum ada pesanan'),
                )
              : ListView.separated(
                  padding: EdgeInsets.symmetric(vertical: 18.0),
                  itemBuilder: (context, index) {
                    var order = orders[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 18.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 18.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              defineOrderStatusName(order.orderStatus),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              NumberFormat.currency(
                                      locale: 'id',
                                      symbol: 'Rp',
                                      decimalDigits: 0)
                                  .format(order.totalAmount),
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Order ${order.orderNumber}',
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 13),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              DateFormat('dd/MM/yyyy').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(order.orderDate))),
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 13),
                            ),
                            const SizedBox(height: 12.0),
                            OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                    minimumSize: Size.fromHeight(44)),
                                onPressed: () {
                                  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  OrderDetailScreen(
                                                      orderNumber:
                                                          order.orderNumber)))
                                      .then((value) {
                                    _getOrders();
                                  });
                                },
                                child: Text('Lihat Detail')),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemCount: orders.length,
                ),
    );
  }
}
