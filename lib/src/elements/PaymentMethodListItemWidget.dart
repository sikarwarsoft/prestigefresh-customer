import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:markets/src/controllers/checkout_controller.dart';
import 'package:markets/src/helpers/constants.dart';
import 'package:markets/src/models/cart.dart';
import 'package:markets/src/models/custom_fieldsss.dart';
import 'package:markets/src/models/order.dart';
import 'package:markets/src/models/order_status.dart';
import 'package:markets/src/models/payment.dart';
import 'package:markets/src/models/product_order.dart';
import 'package:markets/src/models/total_provider.dart';
import 'package:markets/src/repository/user_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import '../repository/settings_repository.dart' as settingRepo;
import 'package:markets/src/controllers/cart_controller.dart';
import '../models/payment_method.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

// ignore: must_be_immutable
class PaymentMethodListItemWidget extends StatefulWidget {
  PaymentMethod paymentMethod;

  PaymentMethodListItemWidget({Key key, this.paymentMethod}) : super(key: key);

  @override
  _PaymentMethodListItemWidgetState createState() => _PaymentMethodListItemWidgetState();
}

class _PaymentMethodListItemWidgetState extends StateMVC<PaymentMethodListItemWidget> {
  String heroTag;
  Razorpay _razorpay;
  CheckoutController _con;

  _PaymentMethodListItemWidgetState() : super(CheckoutController()) {
    _con = controller;
  }

  @override
  void initState() {
    // TODO: implement initState
    print('dasdsadadasdassda'+Provider.of<TotalProvider>(context, listen: false).getTotal().toString());
    print('dasdsadadasdassda'+Provider.of<TotalProvider>(context, listen: false).getDeliveryFee().toString());

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    super.initState();
  }

  void openCheckout() async {
    // SharedPreferences pref = await SharedPreferences.getInstance();
    // var key = pref.getString("rzp_key");
    // if (key.isEmpty) {
    //   Get.dialog(LoadingDialog(), barrierDismissible: false);
    //   await loadNewSettings();
    //   Get.back();
    // }
    // print("Razorpay: $key");
    final key = Provider.of<CustomFieldsss>(context, listen: false).getRazorKey;
    var options = {
      'key': "rzp_test_1EQTOegNCPi1dg",
      // 'key': '$key',
      'amount': Provider.of<TotalProvider>(context, listen: false).getTotal() * 100,
      'name': Constant.appName,
      'description': 'Wallet',
      'prefill': {
        'contact': '${currentUser.value.phone}',
        'email': '${currentUser.value.email}'
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print('done success');
    await _con.listenForCarts();
    _con.payment = new Payment("online");
    _con.payment.method = "online";
    _con.payment.id = response.paymentId;
    _con.onLoadingCartDone();
    Navigator.of(context)
        .pushReplacementNamed('/Pages', arguments: 3);
    // Get.to(orderSucess());
    //payment done
    //update on server
    // ApiService.createOrder(selectedBrand!.value.id.toString(),
    //   selectedModel!.value.id.toString(),selectedPolicy!.value.id.toString(),
    //   response.paymentId.toString(),response.paymentId.toString(),).then((value) {
    //   if (value.status == "true") {
    //     // isLoadingBrands.value = false;
    //     // brandList.clear();
    //     // brandList.value = value!.data!;
    //     Utility.showToastSuccess("order placed successfully", value.message!);
    //     Get.offAll(orderSucess());
    //   } else {
    //     isLoadingBrands.value = false;
    //     brandList.clear();
    //     Utility.showToastError("order cancelled", value.message!);
    //   }
    // });

    // Order order = Order(
    //     paymentId: response.paymentId,
    //     paymentMethod: "razorpay",
    //     paymentStatus: "success",
    //     cartId: "${_cart.cart.value.id}");
    // _repository.createorder(order, widget.addressId, widget.date).then((value) {
    //   _cart.cart.value = Cart();
    //   Get.off(OrderCompleteScreen(
    //     isSuccess: true,
    //     paymentId: response.paymentId,
    //     orderId: value.id.toString(),
    //   ));
    // });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('done fail');
    //payment failed
    Fluttertoast.showToast(
        msg: response.message);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Fluttertoast.showToast(
    //   msg: "EXTERNAL_WALLET: " + response.walletName,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).accentColor,
      focusColor: Theme.of(context).accentColor,
      highlightColor: Theme.of(context).primaryColor,
      onTap: () {
        if(widget.paymentMethod.route == "/RazorPay"){
          openCheckout();
        }else{
          print("route");
          Navigator.of(context).pushNamed(this.widget.paymentMethod.route);
          print(widget.paymentMethod.route);
          print(this.widget.paymentMethod.name);
        }

      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                image: DecorationImage(image: AssetImage(widget.paymentMethod.logo), fit: BoxFit.fill),
              ),
            ),
            SizedBox(width: 15),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.paymentMethod.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        Text(
                          widget.paymentMethod.description,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.keyboard_arrow_right,
                    color: Theme.of(context).focusColor,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
