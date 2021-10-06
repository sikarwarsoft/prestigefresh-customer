import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:mvc_pattern/mvc_pattern.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:markets/src/controllers/home_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/custom_trace.dart';
import '../helpers/maps_util.dart';
import '../models/address.dart';
import '../models/coupon.dart';
import '../models/setting.dart';

ValueNotifier<Setting> setting = new ValueNotifier(new Setting());
ValueNotifier<Address> deliveryAddress = new ValueNotifier(new Address());
Coupon coupon = new Coupon.fromJSON({});
final navigatorKey = GlobalKey<NavigatorState>();

Future<Setting> initSettings() async {
  Setting _setting;
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}settings';
  try {
    final response = await http
        .get(url, headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    if (response.statusCode == 200 &&
        response.headers.containsValue('application/json')) {
      if (json.decode(response.body)['data'] != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'settings', json.encode(json.decode(response.body)['data']));
        _setting = Setting.fromJSON(json.decode(response.body)['data']);
        if (prefs.containsKey('language')) {
          _setting.mobileLanguage.value = Locale(prefs.get('language'), '');
        }
        _setting.brightness.value = prefs.getBool('isDark') ?? false
            ? Brightness.dark
            : Brightness.light;
        setting.value = _setting;
        // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
        setting.notifyListeners();
      }
    } else {
      print(CustomTrace(StackTrace.current, message: response.body).toString());
    }
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url).toString());
    return Setting.fromJSON({});
  }
  return setting.value;
}

Future<void> setCurrentLocation() async {
  print("setcurrentlocatiom");
  var location = new Location();
  MapsUtil mapsUtil = new MapsUtil();
  final whenDone = new Completer();
  Address address = new Address();
  location.getLocation().then((_locationData) async {
    print("getloco00");
    print(_locationData.latitude);
    print(_locationData.toString());
    String _addressName = await mapsUtil.getAddressName(
        new LatLng(_locationData?.latitude, _locationData?.longitude),
        setting.value.googleMapsKey);
    print("addrename");
    print(_addressName);
    address = Address.fromJSON({
      'address': _addressName,
      'latitude': _locationData?.latitude,
      'longitude': _locationData?.longitude
    });
    print(address.toMap());
    print(address.latitude);
    deliveryAddress.value = address;
    deliveryAddress.notifyListeners();
    // if(address.latitude != null){
    //   print("ifof when done");
    //   return address;
    // }
    // HomeController _con;
    //
    // _con.listenForTopMarkets();
    // _con.listenForSlides();
    // _con.listenForTrendingProducts();
    // _con.listenForCategories();
    // _con.listenForPopularMarkets();
    // _con.listenForRecentReviews();
    // _con.listenForAllMarkets();
    await changeCurrentLocation(address);
    print("changecurrentlocationnnn");
    print("whendone");

    //return whenDone.complete(address);
    // return whenDone.future;
  }).whenComplete(() async {
    print("When Complete" + deliveryAddress.value.toMap().toString());
    await changeCurrentLocation(address);

    return whenDone.future;
    // return deliveryAddress.value;
  }).timeout(Duration(seconds: 10), onTimeout: () async {
    await changeCurrentLocation(address);
    whenDone.complete(address);
    return null;
  }).catchError((e) {
    whenDone.complete(address);
  });
  // location.requestService().then((value) async {
  //   print("locationserrr");
  //
  // });
  print("location get0");
  print(address.latitude);
  print(whenDone.isCompleted);
  print(address);
  // return address;
  // return whenDone.complete;
  // if(whenDone.isCompleted){
  //   print("ifof when done");
  //   return address;

  return address;
  // return whenDone.future;
}

Future<Address> changeCurrentLocation(Address _address) async {
  print("changecurrentlocation");
  if (!_address.isUnknown()) {
    print("addddd");
    print("homehome");
    print("afeter adddd");
    print(json.encode(_address.toMap()));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('delivery_address', json.encode(_address.toMap()));
    await getCurrentLocation();

    // HomeController _ = HomeController();

    print("afeter shareed pref");
  }
  return _address;
}

Future<Address> getCurrentLocation() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //await prefs.clear();
  if (prefs.containsKey('delivery_address')) {
    deliveryAddress.value =
        Address.fromJSON(json.decode(prefs.getString('delivery_address')));
    return deliveryAddress.value;
  } else {
    deliveryAddress.value = Address.fromJSON({});
    return Address.fromJSON({});
  }
}

void setBrightness(Brightness brightness) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (brightness == Brightness.dark) {
    prefs.setBool("isDark", true);
    brightness = Brightness.dark;
  } else {
    prefs.setBool("isDark", false);
    brightness = Brightness.light;
  }
}

Future<void> setDefaultLanguage(String language) async {
  if (language != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
  }
}

Future<String> getDefaultLanguage(String defaultLanguage) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('language')) {
    defaultLanguage = await prefs.get('language');
  }
  return defaultLanguage;
}

Future<void> saveMessageId(String messageId) async {
  if (messageId != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('google.message_id', messageId);
  }
}

Future<String> getMessageId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return await prefs.get('google.message_id');
}
