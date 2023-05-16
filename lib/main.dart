import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' hide MapType;
import 'package:map_launcher/map_launcher.dart';
import 'package:provider/provider.dart';
import 'package:vp/app_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/langs', // <-- change the path of the translation files
        fallbackLocale: const Locale('en'),
        child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider<AppProvider>(
      create: (context) => AppProvider(),
      child: MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: MapScreen(),
      ),
    );
  }
}

class TranslationScreenTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Consumer<AppProvider>(
      builder: (context, provider, x) => Scaffold(
          appBar: AppBar(
            actions: [
              Switch(
                  inactiveThumbColor: Colors.grey,
                  activeColor: Colors.black,
                  value: provider.selectedLocale == const Locale("en"),
                  onChanged: (v) {
                    provider.changeLocale(context);
                  })
            ],
            title: Text("app_name".tr()),
          ),
          body: Form(
            key: provider.formKey,
            child: Container(
              margin: EdgeInsets.all(20),
              child: Column(
                children: [
                  TextFormField(
                    validator: provider.checkEmail,
                    decoration: InputDecoration(
                        labelText: "email".tr(),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    validator: provider.checkPassword,
                    decoration: InputDecoration(
                        labelText: "password".tr(),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                          onPressed: () {
                            provider.login();
                          },
                          child: Text("Login")))
                ],
              ),
            ),
          )),
    );
  }
}

class MapScreen extends StatelessWidget {
  final LatLng _center = const LatLng(45.521563, -122.677433);
  late GoogleMapController controller;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        drawer: Drawer(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      "S",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  accountName: Text("MyName"),
                  accountEmail: Text("MyEmail"))
            ],
          ),
        ),
        appBar: AppBar(),
        floatingActionButton: FloatingActionButton(onPressed: () async {
          Position position =
              await Provider.of<AppProvider>(context, listen: false)
                  .determinePosition();
          controller.animateCamera(CameraUpdate.newLatLngZoom(
              LatLng(position.latitude, position.longitude), 25));
        }),
        body: Column(
          children: [
            Text(
              Provider.of<AppProvider>(context).pos ?? '',
              style: TextStyle(fontSize: 40),
            ),
            Expanded(
              child: GoogleMap(
                onMapCreated: (controller) {
                  this.controller = controller;
                },
                onTap: (LatLng point) {
                  MapLauncher.showDirections(
                      mapType: MapType.google,
                      destination: Coords(point.latitude, point.longitude));
                  // Provider.of<AppProvider>(context, listen: false)
                  //     .setPos(point);
                },
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 10.0,
                ),
              ),
            ),
          ],
        ));
  }
}
