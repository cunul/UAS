import 'package:flutter/material.dart';
import 'package:project_app/constants/app_constants.dart';
import 'package:project_app/database/database_queries/address_query.dart';
import 'package:project_app/database/db_helper.dart';
import 'package:project_app/models/address.dart';
import 'package:project_app/preferences.dart';
import 'package:project_app/screens/address_form_screen.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({Key? key}) : super(key: key);

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final DbHelper _helper = DbHelper();

  List<Address> addressList = [];
  bool _isLoading = false;

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

    setState(() {
      _isLoading = false;
    });
  }

  _deleteAddress(int id) async {
    setState(() {
      _isLoading = true;
    });

    await _helper.delete(AddressQuery.TABLE_NAME, id);
    await _getAddress();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Alamat')),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : addressList.isEmpty
              ? Center(
                  child: Text('Belum ada alamat'),
                )
              : ListView.separated(
                  padding: EdgeInsets.symmetric(vertical: 18.0),
                  itemBuilder: (context, index) {
                    var item = addressList[index];

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
                              item.recipientName,
                              style: TextStyle(
                                  fontSize: 15.0, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8.0),
                            Text(item.recipientPhone),
                            const SizedBox(height: 4.0),
                            Text(item.recipientAddress),
                            const SizedBox(height: 4.0),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: AppConstants.kPrimaryColor,
                                ),
                                const SizedBox(width: 4),
                                Expanded(child: Text('(${item.latlong})')),
                              ],
                            ),
                            const SizedBox(height: 12.0),
                            Row(
                              children: [
                                Expanded(
                                    child: OutlinedButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddressFormScreen(
                                                        editAddress: item,
                                                      )))
                                              .then((value) => _getAddress());
                                        },
                                        child: Text('Ubah'))),
                                const SizedBox(width: 8.0),
                                Expanded(
                                    child: OutlinedButton(
                                        onPressed: () {
                                          _deleteAddress(item.id!);
                                        },
                                        child: Text('Hapus'))),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemCount: addressList.length,
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddressFormScreen()))
              .then((value) {
            _getAddress();
          });
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
