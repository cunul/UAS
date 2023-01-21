import 'dart:io';

import 'package:flutter/material.dart';
import 'package:material_color_generator/material_color_generator.dart';
import 'package:project_app/api_client.dart';
import 'package:project_app/constants/app_constants.dart';
import 'package:project_app/preferences.dart';
import 'package:project_app/widgets/bottom_navbar.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preferences().init();
  if (Platform.isAndroid) {
    final GoogleMapsFlutterPlatform mapsImplementation =
        GoogleMapsFlutterPlatform.instance;
    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      mapsImplementation.useAndroidViewSurface = true;
    }
  }
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ApiClient>(
      create: (_) => ApiClient(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch:
              generateMaterialColor(color: AppConstants.kPrimaryColor),
          // scaffoldBackgroundColor: AppConstants.kPrimaryLightColor,
        ),
        home: const BottomNavbar(),
      ),
    );
  }
}
