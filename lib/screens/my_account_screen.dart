import 'package:flutter/material.dart';
import 'package:project_app/models/user.dart';
import 'package:project_app/preferences.dart';
import 'package:project_app/screens/account_information_screen.dart';
import 'package:project_app/screens/address_screen.dart';
import 'package:project_app/screens/login_screen.dart';
import 'package:project_app/screens/order_screen.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({Key? key}) : super(key: key);

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  User? currentUser;
  // UserDetail? currentUser;

  @override
  void initState() {
    super.initState();

    currentUser = Preferences().user;
  }

  @override
  Widget build(BuildContext context) {
    currentUser = Preferences().user;

    return Scaffold(
      body: currentUser == null
          ? Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Kamu belum login :(',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text('Login dulu yuk untuk mulai belanja!'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()))
                              .then((value) {
                            currentUser = Preferences().user;
                            setState(() {});
                          });
                        },
                        child: Text('LOGIN'))
                  ]),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(currentUser!.image),
                          radius: 36.0,
                        ),
                        const SizedBox(width: 16.0),
                        Text(
                          '${currentUser!.firstName} ${currentUser!.lastName}',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(height: 0),
                  ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 18.0),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OrderScreen()));
                    },
                    title: Text('Pesanan Saya'),
                  ),
                  ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 18.0),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddressScreen()));
                    },
                    title: Text('Daftar Alamat'),
                  ),
                  ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 18.0),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AccountInformationScreen()));
                    },
                    title: Text('Informasi Akun'),
                  ),
                  Divider(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: Size.fromHeight(44)),
                      onPressed: () async {
                        await Preferences().clearPreferences();
                        setState(() {});
                      },
                      child: Text('Logout'),
                    ),
                  )
                ],
              )),
    );
  }
}
