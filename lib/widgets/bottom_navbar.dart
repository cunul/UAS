import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_color_generator/material_color_generator.dart';
import 'package:project_app/constants/app_constants.dart';
import 'package:project_app/screens/cart_screen.dart';
import 'package:project_app/screens/home_screen.dart';
import 'package:project_app/screens/my_account_screen.dart';
import 'package:project_app/screens/profile_screen.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({Key? key}) : super(key: key);

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    CartScreen(),
    MyAccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle:
            SystemUiOverlayStyle(statusBarColor: AppConstants.kPrimaryColor),
        title: const Text('ShopIT'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()));
              },
              icon: Icon(
                Icons.account_circle_rounded,
                size: 32,
              ))
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: <BottomNavigationBarItem>[
          _buildBottomNavbarItem(Icons.home_rounded, 'Home'),
          _buildBottomNavbarItem(Icons.shopping_cart_rounded, 'Cart'),
          _buildBottomNavbarItem(Icons.person_rounded, 'User'),
        ],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        selectedItemColor: AppConstants.kPrimaryColor,
        onTap: _onItemTapped,
      ),
    );
  }

  _buildBottomNavbarItem(IconData icon, String label) {
    return BottomNavigationBarItem(
        icon: UnselectedIcon(icon: icon),
        activeIcon: SelectedIcon(icon: icon),
        label: label);
  }
}

class UnselectedIcon extends StatelessWidget {
  final IconData icon;
  const UnselectedIcon({Key? key, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color:
              generateMaterialColor(color: AppConstants.kPrimaryColor).shade200,
        ),
        SizedBox(height: 8),
      ],
    );
  }
}

class SelectedIcon extends StatelessWidget {
  final IconData icon;
  const SelectedIcon({Key? key, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon),
      SizedBox(
        height: 3,
      ),
      Container(
        height: 5,
        width: 5,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppConstants.kPrimaryColor,
        ),
        child: SizedBox(),
      )
    ]);
  }
}
