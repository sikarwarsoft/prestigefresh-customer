import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:markets/src/models/custom_fieldsss.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/cart.dart';
import '../models/coupon.dart';
import '../repository/cart_repository.dart';
import '../repository/coupon_repository.dart';
import '../repository/settings_repository.dart';
import '../repository/user_repository.dart';

class CartController extends ControllerMVC {
  List<Cart> carts = <Cart>[];
  double taxAmount = 0.0;
  double deliveryFee = 0.0;
  int cartCount = 0;
  double subTotal = 0.0;
  double total = 0.0;
  double subtotall = 0.0;
  double dis = 0;
  double maxDiscount = 0;
  double tempSubTotal = 0;
  bool isLoading = false;
  double discount = 0;
  String discountCoupon="";

  GlobalKey<ScaffoldState> scaffoldKey;

  CartController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForCarts({String message}) async {
    print("listen for carts");
    carts.clear();
    final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
      if (!carts.contains(_cart)) {
        setState(() {
          coupon = _cart.product.applyCoupon(coupon);
          carts.add(_cart);
        });
      }
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (carts.isNotEmpty) {
        calculateSubtotal();
      }
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
      onLoadingCartDone();
    });
  }

  void onLoadingCartDone() {}

  void listenForCartsCount({String message}) async {
    final Stream<int> stream = await getCartCount();
    stream.listen((int _count) {
      setState(() {
        this.cartCount = _count;
      });
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    });
  }

  Future<void> refreshCarts() async {
    setState(() {
      carts = [];
    });
    listenForCarts(message: S.of(context).carts_refreshed_successfuly);
  }

  void removeFromCart(Cart _cart) async {
    setState(() {
      this.carts.remove(_cart);
    });
    removeCart(_cart).then((value) {
      calculateSubtotal();
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S
            .of(context)
            .the_product_was_removed_from_your_cart(_cart.product.name)),
      ));
    });
  }

  void calculateSubtotal() async {
    double cartPrice = 0;
    subTotal = 0;
    carts.forEach((cart) {
      cartPrice = cart.product.price;
      cart.options.forEach((element) {
        // cartPrice += element.price;
        cartPrice = element.price + cartPrice;
      });
      // cartPrice *= cart.quantity;
      cartPrice = cart.quantity * cartPrice;
      // subTotal += cartPrice;
      subTotal = cartPrice + subTotal;
    });
    subtotall = subTotal;
    print("Subtotal From CART" + subTotal.toString());
    if (Helper.canDelivery(carts[0].product.market, carts: carts)) {
      deliveryFee = carts[0].product.market.deliveryFee;
    }
    taxAmount =
        (subTotal + deliveryFee) * carts[0].product.market.defaultTax / 100;
    total = subTotal + taxAmount + deliveryFee;
    // print("Tarun" + coupon.valid.toString());
    // print("DiscountType" + coupon.discountType);
    if (coupon.valid ?? false) {
      if (coupon.discountType == "percent") {
        if (dis > 0) {
          if ((dis * subTotal) / 100 < maxDiscount) {
            var discountt = (dis * subTotal) / 100;
            discount = discountt;


            subTotal -= discountt;
            dis = maxDiscount;
            taxAmount = (subTotal + deliveryFee) *
                carts[0].product.market.defaultTax /
                100;
            total = subTotal + taxAmount + deliveryFee;
          } else {
            subTotal -= maxDiscount;
            dis = maxDiscount;
            discount = maxDiscount;

            taxAmount = (subTotal + deliveryFee) *
                carts[0].product.market.defaultTax /
                100;
            total = subTotal + taxAmount + deliveryFee;
          }
        }
      } else {
        if (coupon.valid ?? false) {
          if (dis > 0) {
            if (dis < maxDiscount) {
              discount = dis;
              subTotal -= dis;
              // subTotal -= discountt;
              taxAmount = (subTotal + deliveryFee) *
                  carts[0].product.market.defaultTax /
                  100;
              total = subTotal + taxAmount + deliveryFee;
            } else {
              dis = maxDiscount;
              discount = dis;
              subTotal -= dis;
              taxAmount = (subTotal + deliveryFee) *
                  carts[0].product.market.defaultTax /
                  100;
              total = subTotal + taxAmount + deliveryFee;
            }
          }
        }
      }
      discountCoupon=coupon.code;
    }
    print("Doscount ON CALCULATION" + discount.toString());

    setState(() {});
  }

  void doApplyCoupon(String code, {String message}) async {
    print("do apply coupon");
    isLoading = true;
    setState(() {});
    coupon = new Coupon.fromJSON({"code": code, "valid": null});
    final Stream<Coupon> stream = await verifyCoupon(code);
    stream.listen((Coupon _coupon) async {
      coupon = _coupon;
      dis = _coupon.discount;
      print(_coupon.discount);
      print("double value" + _coupon.max_discount.toString());
      maxDiscount = double.parse(_coupon.max_discount.toString());
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      listenForCarts();
      isLoading = false;
    });
  }

  incrementQuantity(Cart cart) {
    if (cart.quantity <= 99) {
      ++cart.quantity;
      updateCart(cart);
      calculateSubtotal();
    }
  }

  decrementQuantity(Cart cart) {
    if (cart.quantity > 1) {
      --cart.quantity;
      updateCart(cart);
      calculateSubtotal();
    }
  }

  void goCheckout(BuildContext context) {
    if (carts[0].product.market.closed) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).this_market_is_closed_),
      ));
    } else {
      Navigator.of(context).pushNamed('/DeliveryPickup');
    }
  }

  Color getCouponIconColor() {
    if (coupon?.valid == true) {
      return Colors.green;
    } else if (coupon?.valid == false) {
      return Colors.redAccent;
    }
    return Theme.of(context).focusColor.withOpacity(0.7);
  }
}
