import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/cart.dart';
import '../models/favorite.dart';
import '../models/option.dart';
import '../models/product.dart';
import '../repository/cart_repository.dart';
import '../repository/product_repository.dart';

class ProductController extends ControllerMVC {
  Product product;
  double quantity = 1;
  double total = 0;
  List<Cart> carts = [];
  Favorite favorite;
  bool loadCart = false;
  GlobalKey<ScaffoldState> scaffoldKey;

  ProductController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForProduct({String productId, String message}) async {
    final Stream<Product> stream = await getProduct(productId);
    stream.listen((Product _product) {
      setState(() => product = _product);
    }, onError: (a) {
      print(a);
      scaffoldKey.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      calculateTotal();
      if (message != null) {
        scaffoldKey.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void listenForFavorite({String productId}) async {
    final Stream<Favorite> stream = await isFavoriteProduct(productId);
    stream.listen((Favorite _favorite) {
      setState(() => favorite = _favorite);
    }, onError: (a) {
      print(a);
    });
  }

  void listenForCart() async {
    final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
      carts.add(_cart);
    });
  }

  bool isSameMarkets(Product product) {
    if (carts.isNotEmpty) {
      return carts[0].product?.market?.id == product.market?.id;
    }
    return true;
  }

  showAlertDialog(BuildContext context) {
    print("show dialog");
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Alert"),
      content: Text("You can add only ${product.packageItemsCount} of this product"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void addToCart(Product product, {bool reset = false}) async {
    setState(() {
      this.loadCart = true;
    });
    var _newCart = new Cart();
    _newCart.product = product;
    _newCart.options = product.options.where((element) => element.checked).toList();
    _newCart.quantity = this.quantity;
    // if product exist in the cart then increment quantity
    print("checkpoint");
    Cart _oldCart;
    Cart _tempCart;
    for(int i=0;i<carts.length ; i++ ){
      if(carts[i].product.id == _newCart.product.id){
        print("check ke if me aaya");
        setState((){
          _oldCart = _newCart;
          _tempCart = carts[i];
        });
        break;
      }else{
        _oldCart = null;
      }
    }
    // Cart _oldCart = carts.firstWhere((Cart oldCart) {
    //   if(_newCart.isSame(oldCart)){
    //     return oldCart;
    //   }else{
    //     return null;
    //   }
    // });
    // var _oldCart = isExistInCart(_newCart);
    if (_oldCart != null) {
      if((_oldCart.quantity + _tempCart.quantity) <= int.parse(product.packageItemsCount)){
        print(_oldCart.toMap());
        print(_oldCart.quantity + _tempCart.quantity);
        setState((){
          _oldCart.quantity = _oldCart.quantity + _tempCart.quantity;
          _oldCart.id = _tempCart.id;
        });
        print("ifme aaya");
        updateCart(_oldCart).then((value) {
          print("update cart");
          setState(() {
            this.loadCart = false;
          });
        }).whenComplete(() {
          // showAlertDialog(context);
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).this_product_was_added_to_cart),
          ));
        });
      }else{
        setState(() {
          this.loadCart = false;
        });
        showAlertDialog(context);
      }
    } else {
      print("else me aaya");
      // the product doesnt exist in the cart add new one
      addCart(_newCart, reset).then((value) {
        setState(() {
          this.loadCart = false;
        });
      }).whenComplete(() {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).this_product_was_added_to_cart),
        ));
      });
    }
  }

  Cart isExistInCart(Cart _cart) {
    carts.firstWhere((Cart oldCart) {
      if(_cart.isSame(oldCart)){
        return _cart.isSame(oldCart);
      }else{
        return null;
      }
    });
    // return carts.firstWhere((Cart oldCart) => _cart.isSame(oldCart), orElse: () => null);
  }

  void addToFavorite(Product product) async {
    var _favorite = new Favorite();
    _favorite.product = product;
    _favorite.options = product.options.where((Option _option) {
      return _option.checked;
    }).toList();
    addFavorite(_favorite).then((value) {
      setState(() {
        this.favorite = value;
      });
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).thisProductWasAddedToFavorite),
      ));
    });
  }

  void removeFromFavorite(Favorite _favorite) async {
    removeFavorite(_favorite).then((value) {
      setState(() {
        this.favorite = new Favorite();
      });
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).thisProductWasRemovedFromFavorites),
      ));
    });
  }

  Future<void> refreshProduct() async {
    var _id = product.id;
    product = new Product();
    listenForFavorite(productId: _id);
    listenForProduct(productId: _id, message: S.of(context).productRefreshedSuccessfuly);
  }

  void calculateTotal() {
    total = product?.price ?? 0;
    product?.options?.forEach((option) {
      total += option.checked ? option.price : 0;
    });
    total *= quantity;
    setState(() {});
  }

  incrementQuantity() {
    if (this.quantity <= 99) {
      ++this.quantity;
      calculateTotal();
    }
  }

  decrementQuantity() {
    if (this.quantity > 1) {
      --this.quantity;
      calculateTotal();
    }
  }
}
