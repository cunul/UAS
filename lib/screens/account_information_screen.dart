import 'package:flutter/material.dart';
import 'package:project_app/models/user.dart';
import 'package:project_app/preferences.dart';

class AccountInformationScreen extends StatefulWidget {
  const AccountInformationScreen({Key? key}) : super(key: key);

  @override
  State<AccountInformationScreen> createState() =>
      _AccountInformationScreenState();
}

class _AccountInformationScreenState extends State<AccountInformationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();

    User user = Preferences().user!;

    _nameController.text = user.firstName + user.lastName;
    _emailController.text = user.email;
    _phoneController.text = user.phone!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Informasi Akun')),
      body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 20.0),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Nama'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'No. Telp'),
              ),
              // const SizedBox(height: 24),
              // ElevatedButton(
              //   style:
              //       ElevatedButton.styleFrom(minimumSize: Size.fromHeight(44)),
              //   onPressed: () {},
              //   child: Text('Update'),
              // )
            ],
          )),
    );
  }
}
