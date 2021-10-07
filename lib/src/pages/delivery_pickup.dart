import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:markets/src/controllers/checkout_controller.dart';
import 'package:markets/src/elements/DeliveryAddressBottomSheetWidget.dart';
import 'package:markets/src/models/custom_fieldsss.dart';
import 'package:markets/src/models/selected_option.dart';
import 'package:markets/src/repository/settings_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../generated/l10n.dart';
import '../controllers/delivery_pickup_controller.dart';
import '../elements/CartBottomDetailsWidget.dart';
import '../elements/DeliveryAddressDialog.dart';
import '../elements/DeliveryAddressesItemWidget.dart';
import '../elements/NotDeliverableAddressesItemWidget.dart';
import '../elements/PickUpMethodItemWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/payment_method.dart';
import '../models/route_argument.dart';
import 'package:markets/src/models/total_provider.dart';

class DeliveryPickupWidget extends StatefulWidget {
  final RouteArgument routeArgument;

  DeliveryPickupWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _DeliveryPickupWidgetState createState() => _DeliveryPickupWidgetState();
}

class _DeliveryPickupWidgetState extends StateMVC<DeliveryPickupWidget> {
  DeliveryPickupController _con;
  CheckoutController _checkoutCon;

  String selectedOption = '';
  double deliveryFee = 0;
  double beforetax = 0;
  bool flag = false;
  double diff = 0;
  bool ispress = true;
  String couponValue;

  _DeliveryPickupWidgetState() : super(DeliveryPickupController()) {
    _con = controller;
  }

  void getIsPressed() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    ispress = preferences.getBool('isPress');
  }

  @override
  void initState() {
    // TODO: implement initState
    getIsPressed();
    super.initState();
    new Future.delayed(const Duration(seconds: 3), () {
      print('delivery');
      Provider.of<TotalProvider>(context, listen: false).setMethod('1');
      print(deliveryFee);
      selectedOption = 'delivery';

      if (_con.deliveryFee == 0) {
        _con.deliveryFee = deliveryFee;
        _con.taxAmount = (_con.subTotal + _con.deliveryFee) *
            _con.carts[0].product.market.defaultTax /
            100;
        _con.total = _con.subTotal + _con.deliveryFee + _con.taxAmount;
        Provider.of<TotalProvider>(context, listen: false).setTotal(_con.total);
        Provider.of<TotalProvider>(context, listen: false)
            .setDiscount(_con.discount);
      }

      Provider.of<SelectedOption>(context, listen: false).setOption('delivery');
      _con.toggleDelivery();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_con.list == null) {
      _con.list = new PaymentMethodList(context);
    }

    return Scaffold(
      key: _con.scaffoldKey,
      bottomNavigationBar: CartBottomDetailsWidget(
        con: _con,
        deliveryAllowed: _con.deliveryAddress.address == null ? false : true,
        isDeliveryPage: true,
        checkoutCon: _checkoutCon,
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Delivery",
          style: Theme.of(context)
              .textTheme
              .headline6
              .merge(TextStyle(letterSpacing: 1.3)),
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(
              iconColor: Theme.of(context).hintColor,
              labelColor: Theme.of(context).accentColor),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            // Padding(
            //   padding: const EdgeInsets.only(left: 20, right: 10),
            //   child: ListTile(
            //     contentPadding: EdgeInsets.symmetric(vertical: 0),
            //     leading: Icon(
            //       Icons.domain,
            //       color: Theme.of(context).hintColor,
            //     ),
            //     title: Text(
            //       S.of(context).pickup,
            //       maxLines: 1,
            //       overflow: TextOverflow.ellipsis,
            //       style: Theme.of(context).textTheme.headline4,
            //     ),
            //     subtitle: Text(
            //       S.of(context).pickup_your_product_from_the_market,
            //       maxLines: 1,
            //       overflow: TextOverflow.ellipsis,
            //       style: Theme.of(context).textTheme.caption,
            //     ),
            //   ),
            // ),
            // PickUpMethodItem(
            //     paymentMethod: _con.getPickUpMethod(),
            //     onPressed: (paymentMethod) {
            //       print(paymentMethod.name);
            //       print(deliveryFee);
            //       selectedOption = 'pickup';
            //       Provider.of<TotalProvider>(context, listen: false)
            //           .setMethod('0');
            //       beforetax = _con.taxAmount;
            //       diff = beforetax - _con.taxAmount;
            //       _con.taxAmount = (_con.subTotal) *
            //           _con.carts[0].product.market.defaultTax /
            //           100;
            //       _con.total = _con.total -
            //           _con.deliveryFee -
            //           (beforetax - _con.taxAmount);
            //       Provider.of<TotalProvider>(context, listen: false)
            //           .setTotal(_con.total);
            //       _con.deliveryFee = 0;
            //       Provider.of<SelectedOption>(context, listen: false)
            //           .setOption('pickup');
            //       print('pickup');
            //       _con.togglePickUp();
            //     }),
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20, bottom: 10, left: 20, right: 10),
                  child: _con.deliveryAddress.address == null
                      ? Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(vertical: 0),
                              leading: Icon(
                                Icons.map,
                                color: Theme.of(context).hintColor,
                              ),
                              trailing: InkWell(
                                onTap: () {
                                  var bottomSheetController = _con
                                      .scaffoldKey.currentState
                                      .showBottomSheet(
                                          (context) =>
                                              DeliveryAddressBottomSheetWidget(
                                                  scaffoldKey:
                                                      _con.scaffoldKey),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: new BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10)),
                                          ),
                                          clipBehavior: Clip.none,
                                          elevation: 0);
                                  bottomSheetController.closed.then((value) {
                                    _con.listenForDeliveryAddress();
                                    setState(() {});
                                  });
                                },
                                child: Icon(
                                  Icons.add_circle,
                                  color: Colors.black,
                                ),
                              ),
                              title: Text(
                                S.of(context).delivery,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.headline4,
                              ),
                              subtitle: _con.carts.isNotEmpty &&
                                      Helper.canDelivery(
                                          _con.carts[0].product.market,
                                          carts: _con.carts)
                                  ? Text(
                                      S
                                          .of(context)
                                          .click_to_confirm_your_address_and_pay_or_long_press,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    )
                                  : Text(
                                      S.of(context).deliveryMethodNotAllowed,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                            ),
                            NotDeliverableAddressesItemWidget(),
                          ],
                        )
                      : ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 0),
                          leading: Icon(
                            Icons.map,
                            color: Theme.of(context).hintColor,
                          ),
                          trailing: InkWell(
                            onTap: () {
                              var bottomSheetController =
                                  _con.scaffoldKey.currentState.showBottomSheet(
                                      (context) =>
                                          DeliveryAddressBottomSheetWidget(
                                              scaffoldKey: _con.scaffoldKey),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: new BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10)),
                                      ),
                                      clipBehavior: Clip.none,
                                      elevation: 0);
                              bottomSheetController.closed.then((value) {
                                _con.listenForDeliveryAddress();
                                setState(() {});
                              });
                            },
                            child: Icon(
                              Icons.add_circle,
                              color: Colors.black,
                            ),
                          ),
                          title: Text(
                            S.of(context).delivery,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headline4,
                          ),
                          subtitle: _con.carts.isNotEmpty &&
                                  Helper.canDelivery(
                                      _con.carts[0].product.market,
                                      carts: _con.carts)
                              ? Text(
                                  S
                                      .of(context)
                                      .click_to_confirm_your_address_and_pay_or_long_press,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.caption,
                                )
                              : Text(
                                  S.of(context).deliveryMethodNotAllowed,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.caption,
                                ),
                        ),
                ),

                _con.deliveryAddress.address == null
                    ? SizedBox()
                    : _con.carts.isNotEmpty &&
                            Helper.canDelivery(_con.carts[0].product.market,
                                carts: _con.carts)
                        ? DeliveryAddressesItemWidget(
                            paymentMethod: _con.getDeliveryMethod(),
                            address: _con.deliveryAddress,
                            onPressed: (Address _address) {
                              if (_con.deliveryAddress.id == null ||
                                  _con.deliveryAddress.id == 'null') {
                                DeliveryAddressDialog(
                                  context: context,
                                  address: _address,
                                  onChanged: (Address _address) {
                                    _con.addAddress(_address);
                                  },
                                );
                              } else {
                                print('delivery');
                                Provider.of<TotalProvider>(context,
                                        listen: false)
                                    .setMethod('1');
                                print(deliveryFee);
                                selectedOption = 'delivery';

                                if (_con.deliveryFee == 0) {
                                  _con.deliveryFee = deliveryFee;
                                  _con.taxAmount = (_con.subTotal +
                                          _con.deliveryFee) *
                                      _con.carts[0].product.market.defaultTax /
                                      100;
                                  _con.total = _con.subTotal +
                                      _con.deliveryFee +
                                      _con.taxAmount;
                                  Provider.of<TotalProvider>(context,
                                          listen: false)
                                      .setTotal(_con.total);
                                }

                                Provider.of<SelectedOption>(context,
                                        listen: false)
                                    .setOption('delivery');
                                _con.toggleDelivery();
                              }
                              Provider.of<TotalProvider>(context, listen: false)
                                  .setDiscount(_con.discount);
                            },
                            onLongPress: (Address _address) {
                              DeliveryAddressDialog(
                                context: context,
                                address: _address,
                                onChanged: (Address _address) {
                                  _con.updateAddress(_address);
                                },
                              );
                            },
                          )
                        : NotDeliverableAddressesItemWidget(),
                SizedBox(
                  height: 16,
                ),
                Container(
                  padding: const EdgeInsets.all(18),
                  margin: EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                            color:
                                Theme.of(context).focusColor.withOpacity(0.15),
                            offset: Offset(0, 2),
                            blurRadius: 5.0)
                      ]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        child: TextField(
                          keyboardType: TextInputType.text,
                          onChanged: (v) {
                            couponValue = v;
                          },
                          cursorColor: Theme.of(context).accentColor,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hintStyle: Theme.of(context).textTheme.bodyText1,
                            suffixText: _con.isLoading
                                ? 'Loading'
                                : coupon?.valid == null
                                    ? ''
                                    : (coupon.valid
                                        ? S.of(context).validCouponCode
                                        : S.of(context).invalidCouponCode),
                            suffixStyle: Theme.of(context)
                                .textTheme
                                .caption
                                .merge(TextStyle(
                                    color: _con.getCouponIconColor())),
                            // suffixIcon: Padding(
                            //   padding:
                            //   EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            //   child: InkWell(
                            //       onTap: () {
                            //         print(couponValue);
                            //
                            //       },
                            //       child: Text('Apply Coupon')),
                            // ),
                            hintText: S.of(context).haveCouponCode,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .focusColor
                                        .withOpacity(0.2))),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .focusColor
                                        .withOpacity(0.5))),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .focusColor
                                        .withOpacity(0.2))),
                          ),
                        ),
                        width: MediaQuery.of(context).size.width * .7,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_con.total <
                              Provider.of<CustomFieldsss>(context,
                                      listen: false)
                                  .getMaxDiscountPrice) {
                            Fluttertoast.showToast(
                                msg:
                                    'Minimum order must be greater than ₹ ${Provider.of<CustomFieldsss>(context, listen: false).getMaxDiscountPrice}');
                            return;
                          } else {
                            _con.doApplyCoupon(couponValue);
                            //_checkoutCon.payment.discount_coupon = couponValue;
                          }
                        },
                        child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).accentColor,
                            ),
                            child: _con.isLoading
                                ? CircularProgressIndicator(
                                    backgroundColor: Colors.white,
                                  )
                                : coupon.valid ?? true
                                    ? Icon(
                                        Icons.check,
                                        color: Theme.of(context).primaryColor,
                                      )
                                    : Icon(
                                        Icons.clear,
                                        color: Theme.of(context).primaryColor,
                                      )),
                      )
                    ],
                  ),
                ),
                // Container(
                //   color: Colors.white,
                //   child: ListTile(
                //     leading: Icon(Icons.schedule),
                //     title: Text('Want to Schedule delivery'),
                //     subtitle: Text('Click here to schedule delivery'),
                //     onTap: () {
                //       Fluttertoast.showToast(msg: 'Please try again later');
                //     },
                //   ),
                // )
              ],
            )
          ],
        ),
      ),
    );
  }
}
