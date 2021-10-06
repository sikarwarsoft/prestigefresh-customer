import 'package:flutter/material.dart';
import 'package:markets/src/repository/user_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/address.dart' as model;
import '../models/cart.dart';
import '../repository/cart_repository.dart';
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;

class DeliveryAddressesController extends ControllerMVC with ChangeNotifier {
  List<model.Address> addresses = <model.Address>[];
  GlobalKey<ScaffoldState> scaffoldKey;
  Cart cart;

  DeliveryAddressesController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    // if(userRepo.currentUser.value.apiToken!=null&&){
    //
    // }
    listenForAddresses();
    listenForCart();
  }

  void listenForAddresses({String message}) async {
    final Stream<model.Address> stream = await userRepo.getAddresses();
    stream.listen((model.Address _address) {
      setState(() {
        addresses.add(_address);
      });
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () async {
      if (addresses != null && addresses.length > 0) {
        await changeDeliveryAddress(addresses.elementAt(0));
      }

      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void listenForCart() async {
    final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
      cart = _cart;
    });
  }

  Future<void> refreshAddresses() async {
    addresses.clear();
    listenForAddresses(message: S.of(context).addresses_refreshed_successfuly);
  }

  Future<void> changeDeliveryAddress(model.Address address) async {
    await settingRepo.changeCurrentLocation(address);
    setState(() {
      settingRepo.deliveryAddress.value = address;
      userRepo.currentUser.value.address = address.address;
    });
    setState(() {});
    settingRepo.deliveryAddress.notifyListeners();
    userRepo.currentUser.notifyListeners();
    setState(() {});
  }

  Future<void> changeDeliveryAddressToCurrentLocation() async {
    await settingRepo.setCurrentLocation();
    model.Address _address = settingRepo.deliveryAddress.value;
    setState(() {
      print("addddd");
      settingRepo.deliveryAddress.value = _address;
      userRepo.currentUser.value.address = _address.address;
      currentUser.value.address = _address.address;
      print(_address.address);
    });
    settingRepo.deliveryAddress.notifyListeners();
    userRepo.currentUser.notifyListeners();
    setState(() {});
  }

  Future<model.Address> addAddress(model.Address address) async {
    // address.isDefault=true;
    var data = await userRepo.addAddress(address);
    print(data);
    if (data != null) {
      this.addresses.insert(0, data);
      currentUser.value.address = addresses[0].address;
      print("addaduu");
      print(addresses[0].address);
      return data;
    } else {
      return null;
    }
  }

  void chooseDeliveryAddress(model.Address address) {
    address.isDefault = true;
    setState(() {
      settingRepo.deliveryAddress.value = address;
      userRepo.currentUser.value.address = address.address;
    });
    userRepo.currentUser.notifyListeners();
    settingRepo.deliveryAddress.notifyListeners();
  }

  void updateAddress(model.Address address) {
    userRepo.updateAddress(address).then((value) {
      setState(() {});
      addresses.clear();
      listenForAddresses(
          message: S.of(context).the_address_updated_successfully);
    });
  }

  void removeDeliveryAddress(model.Address address) async {
    userRepo.removeDeliveryAddress(address).then((value) {
      setState(() {
        this.addresses.remove(address);
      });
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).delivery_address_removed_successfully),
      ));
    });
  }
}
