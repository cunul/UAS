import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:project_app/constants/app_constants.dart';
import 'package:project_app/database/database_queries/address_query.dart';
import 'package:project_app/database/db_helper.dart';
import 'package:project_app/models/address.dart';
import 'package:project_app/preferences.dart';

class AddressFormScreen extends StatefulWidget {
  final Address? editAddress;
  const AddressFormScreen({Key? key, this.editAddress}) : super(key: key);

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final DbHelper _helper = DbHelper();

  final _recipientNameController = TextEditingController();
  final _recipientAddressController = TextEditingController();
  final _recipientPhoneController = TextEditingController();
  final _latlongController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  LatLng kInitialPosition = LatLng(-6.173110, 106.829361);

  _init() {
    if (widget.editAddress != null) {
      _recipientNameController.text = widget.editAddress!.recipientName;
      _recipientPhoneController.text = widget.editAddress!.recipientPhone;
      _recipientAddressController.text = widget.editAddress!.recipientAddress;
      _latlongController.text = widget.editAddress!.latlong;

      var latitude = double.parse(widget.editAddress!.latlong.split(',').first);
      var longitude = double.parse(widget.editAddress!.latlong.split(',').last);

      kInitialPosition = LatLng(latitude, longitude);
      print(kInitialPosition);
    }
  }

  _addAddress() async {
    Address newAddress = Address(
      userId: Preferences().user!.id,
      recipientName: _recipientNameController.value.text.trim(),
      recipientPhone: _recipientPhoneController.value.text.trim(),
      recipientAddress: _recipientAddressController.value.text.trim(),
      latlong: _latlongController.value.text.trim(),
    );

    await _helper.insert(AddressQuery.TABLE_NAME, newAddress.toJson());
    Fluttertoast.showToast(msg: 'Input berhasil');
    Navigator.pop(context);
  }

  _updateAddress(int id) async {
    Address updatedAddress = Address(
      id: id,
      userId: Preferences().user!.id,
      recipientName: _recipientNameController.value.text.trim(),
      recipientPhone: _recipientPhoneController.value.text.trim(),
      recipientAddress: _recipientAddressController.value.text.trim(),
      latlong: _latlongController.value.text.trim(),
    );

    await _helper.update(AddressQuery.TABLE_NAME, updatedAddress.toJson());
  }

  @override
  void initState() {
    super.initState();

    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.editAddress != null ? 'Ubah Alamat' : 'Tambah Alamat'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _recipientNameController,
                decoration: InputDecoration(labelText: 'Nama Penerima'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _recipientPhoneController,
                decoration: InputDecoration(labelText: 'No. Telepon'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _recipientAddressController,
                decoration: InputDecoration(labelText: 'Alamat'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _latlongController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Titik Koordinat'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlacePicker(
                        apiKey: Platform.isAndroid
                            ? AppConstants.MAP_API_KEY
                            : "YOUR IOS API KEY",
                        onPlacePicked: (result) {
                          print(result.formattedAddress);
                          _latlongController.text =
                              '${result.geometry!.location.lat}, ${result.geometry!.location.lng}';
                          Navigator.of(context).pop();
                        },
                        initialPosition: kInitialPosition,
                        useCurrentLocation:
                            widget.editAddress != null ? false : true,
                        resizeToAvoidBottomInset: false,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Batal')),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                      child: ElevatedButton(
                          onPressed: () async {
                            if (widget.editAddress != null) {
                              await _updateAddress(widget.editAddress!.id!);
                              Navigator.pop(context);
                            } else {
                              await _addAddress();
                            }
                          },
                          child: Text('Simpan')))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
