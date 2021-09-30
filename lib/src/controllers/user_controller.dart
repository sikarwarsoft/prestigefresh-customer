import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:markets/src/models/address.dart';
import 'package:markets/src/repository/settings_repository.dart';
import 'package:markets/src/repository/user_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as repository;
import 'delivery_addresses_controller.dart';

class UserController extends ControllerMVC {
  User user = new User();
  bool hidePassword = true;
  bool loading = false;
  GlobalKey<FormState> loginFormKey;
  GlobalKey<ScaffoldState> scaffoldKey;
  FirebaseMessaging _firebaseMessaging;
  OverlayEntry loader;
  DeliveryAddressesController _conAddress;

  UserController() {
    loader = Helper.overlayLoader(context);
    loginFormKey = new GlobalKey<FormState>();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    _conAddress = DeliveryAddressesController();
    _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.getToken().then((String _deviceToken) {
      user.deviceToken = _deviceToken;
    }).catchError((e) {
      print('Notification not configured');
    });
  }

  void login() async {
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      repository.login(user).then((value) async {
        loader.remove();
        if (value != null && value.apiToken != null) {
          _conAddress = DeliveryAddressesController();

          LocationResult result = await showLocationPicker(
            context,
            setting.value.googleMapsKey,
            initialCenter: LatLng(deliveryAddress.value?.latitude ?? 0,
                deliveryAddress.value?.longitude ?? 0),
            //automaticallyAnimateToCurrentLocation: true,
            //mapStylePath: 'assets/mapStyle.json',
            myLocationButtonEnabled: true,
            //resultCardAlignment: Alignment.bottomCenter,
          );
          print("result = $result");
          if (result != null) {
            _conAddress
                .addAddress(new Address.fromJSON({
              'address': result.address,
              'latitude': result.latLng.latitude,
              'longitude': result.latLng.longitude,
            }))
                .then((value) async {
              if (value != null) {
                Overlay.of(context).insert(loader);
                await _conAddress.chooseDeliveryAddress(value);;
                await _conAddress.changeDeliveryAddress(value);
                loader.remove();
                setState((){});
                Navigator.of(context)
                    .pushReplacementNamed('/Pages', arguments: 2);
              } else {
                scaffoldKey?.currentState?.showSnackBar(SnackBar(
                  content: Text("Error in Address"),
                ));
              }
            });
          } else {
            Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
          }
        } else {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).wrong_email_or_password),
          ));
        }
      }).catchError((e) {
        loader.remove();
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).this_account_not_exist),
        ));
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  Future<bool> register() async {
    print("register");
    FocusScope.of(context).unfocus();
    {
      Overlay.of(context).insert(loader);
      print("gerister");
      repository.register(user).then((value) async {
        print('i ma in');
        print(value);
        if (value != null && value.apiToken != null) {
          _conAddress = DeliveryAddressesController();

          // LocationResult result = await showLocationPicker(
          //   context,
          //   setting.value.googleMapsKey,
          //   initialCenter: LatLng(deliveryAddress.value?.latitude ?? 0,
          //       deliveryAddress.value?.longitude ?? 0),
          LocationResult result = await showLocationPicker(
            context,
            setting.value.googleMapsKey,
            initialCenter: LatLng(deliveryAddress.value?.latitude ?? 0,
                deliveryAddress.value?.longitude ?? 0),

            //automaticallyAnimateToCurrentLocation: true,
            //mapStylePath: 'assets/mapStyle.json',
            myLocationButtonEnabled: true,
            //resultCardAlignment: Alignment.bottomCenter,
          );
          print("result = $result");
          if (result != null) {
            _conAddress
                .addAddress(new Address.fromJSON({
              'address': result.address,
              'latitude': result.latLng.latitude,
              'longitude': result.latLng.longitude,
            }))
                .then((value) async {
              if (value != null) {
                Overlay.of(context).insert(loader);
                await _conAddress.chooseDeliveryAddress(value);;
                await _conAddress.changeDeliveryAddress(value);
                loader.remove();
                setState((){});
                Navigator.of(context)
                    .pushReplacementNamed('/Pages', arguments: 2);
              } else {
                scaffoldKey?.currentState?.showSnackBar(SnackBar(
                  content: Text("Error in Address"),
                ));
              }
            });
          } else {
            Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
          }
        } else {
          print("elseu");

          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).wrong_email_or_password),
          ));
          Navigator.pop(context);
          return false;
        }
      }).catchError((e) {
        loader.remove();
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).this_email_account_exists),
        ));
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  void showToast(message, Color color) {
    print(message);
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        backgroundColor: color,
        textColor: Colors.orange,
        fontSize: 16.0);
  }

  void resetPassword() {
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      repository.resetPassword(user).then((value) {
        if (value != null && value == true) {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content:
                Text(S.of(context).your_reset_link_has_been_sent_to_your_email),
            action: SnackBarAction(
              label: S.of(context).login,
              onPressed: () {
                Navigator.of(scaffoldKey.currentContext)
                    .pushReplacementNamed('/Login');
              },
            ),
            duration: Duration(seconds: 10),
          ));
        } else {
          loader.remove();
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).error_verify_email_settings),
          ));
        }
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }
}
