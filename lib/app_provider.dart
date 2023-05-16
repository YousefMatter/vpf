import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:string_validator/string_validator.dart';

class AppProvider extends ChangeNotifier {
  Locale selectedLocale = const Locale('en');
  changeLocale(BuildContext context) {
    if (context.locale == const Locale("ar")) {
      selectedLocale = const Locale('en');
      context.setLocale(selectedLocale = const Locale('en'));
    } else {
      selectedLocale = const Locale('ar');
      context.setLocale(selectedLocale = const Locale('ar'));
    }
    notifyListeners();
  }

  String? checkEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return "required_field".tr();
    }
  }

  String? checkEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "required_field".tr();
    } else if (!isEmail(value)) {
      return "incorrect email syntax";
    }
  }

  String? checkPassword(String? value) {
    if ((value?.length ?? 0) < 6) {
      return "The password must be at least 6 letters";
    }
  }

  GlobalKey<FormState> formKey = GlobalKey();
  login() {
    bool result = formKey.currentState!.validate();
    if (result) {
      // send to server
    }
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  String? pos;
  setPos(LatLng point) {
    pos = "${point.latitude} , ${point.longitude}";
    notifyListeners();
  }

  getDistanceBetweenTwopoints(LatLng firstpos, LatLng secondPo) {
    double x = Geolocator.distanceBetween(firstpos.latitude, firstpos.longitude,
        secondPo.latitude, secondPo.longitude);
    log(x.toString());
  }
}
