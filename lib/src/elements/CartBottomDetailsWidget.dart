import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:markets/src/models/route_argument.dart';
import 'package:markets/src/models/total_provider.dart';
import 'package:markets/src/pages/order_success.dart';
import 'package:markets/src/repository/settings_repository.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../controllers/cart_controller.dart';
import '../helpers/helper.dart';

class CartBottomDetailsWidget extends StatelessWidget {
  const CartBottomDetailsWidget({
    Key key,
    @required CartController con,
    bool deliveryAllowed,
    bool isDeliveryPage,
  })  : _con = con,
        _deliveryAllowed = deliveryAllowed,
        _isDeliveryPage = isDeliveryPage,
        super(key: key);

  final CartController _con;
  final bool _deliveryAllowed;
  final bool _isDeliveryPage;

  @override
  Widget build(BuildContext context) {
    Provider.of<TotalProvider>(context, listen: false).setTotal(
      _con.total,
    );
    Provider.of<TotalProvider>(context, listen: false).setSubTotal(
      _con.subTotal,
    );
    Provider.of<TotalProvider>(context, listen: false).setDeliveryFee(
      _con.deliveryFee,
    );
    Provider.of<TotalProvider>(context, listen: false).setFinalTax(
      _con.taxAmount,
    );
    return _con.carts.isEmpty
        ? SizedBox(height: 0)
        : Container(
            height: MediaQuery.of(context).size.height*0.28,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).focusColor.withOpacity(0.15),
                      offset: Offset(0, -2),
                      blurRadius: 5.0)
                ]),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        S.of(context).subtotal,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                    Row(
                      children: [
                        coupon.valid ?? false
                            ? _con.dis > 0
                                ? Text(
                                    '₹ ${_con.subtotall}',
                                    // '₹ ${_con.subTotal - _con.dis}',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w500,
                                      height: 1.3,
                                      decoration:
                                          TextDecoration.lineThrough,
                                    ),
                                  )
                                : SizedBox()
                            : SizedBox(),
                        SizedBox(
                          width: 4,
                        ),
                        Helper.getPrice(_con.subTotal, context,
                            style: Theme.of(context).textTheme.subtitle1,
                            zeroPlaceholder: '0'),
                      ],
                    )
                  ],
                ),
                SizedBox(height: 5),
                (_con.dis > 0)?Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Discount',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                    coupon.valid ?? false
                        ? _con.dis > 0
                            ? Text(
                                '-₹ ${_con.discount}',
                                // '₹ ${_con.dis}',
                                style:
                                    Theme.of(context).textTheme.subtitle1,
                              )
                            : Text('₹ 0',
                                style:
                                    Theme.of(context).textTheme.subtitle1)
                        : Text('₹ 0',
                            style: Theme.of(context).textTheme.subtitle1),
                  ],
                ):SizedBox(height: 0,),
                SizedBox(height: 5),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        S.of(context).delivery_fee,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                    if (Helper.canDelivery(_con.carts[0].product.market,
                        carts: _con.carts))
                      Text(
                        '₹ ${_con.deliveryFee.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.subtitle1,
                      )
                    else
                      Helper.getPrice(0, context,
                          style: Theme.of(context).textTheme.subtitle1,
                          zeroPlaceholder: 'Free')
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '${S.of(context).tax} (${_con.carts[0].product.market.defaultTax}%)',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                    Helper.getPrice(_con.taxAmount, context,
                        style: Theme.of(context).textTheme.subtitle1)
                  ],
                ),
                SizedBox(height: 10),
                Stack(
                  fit: StackFit.loose,
                  alignment: AlignmentDirectional.centerEnd,
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      child: FlatButton(
                        onPressed: () {
                          if (_isDeliveryPage) {
                            if (Helper.canDelivery(
                                _con.carts[0].product.market,
                                carts: _con.carts)) {
                              try {
                                _con.goCheckout(context);
                              } catch (e) {
                                Fluttertoast.showToast(
                                    msg: 'Please Select Delivery Address');
                              }
                            } else {
                              Fluttertoast.showToast(
                                  msg: 'Please Select Delivery Address');
                            }
                          } else {
                            try {
                              _con.goCheckout(context);
                            } catch (e) {
                              Fluttertoast.showToast(
                                  msg: 'Please Select Delivery Address');
                            }
                          }

                          // if (screen == 'cart') {
                          //   _con.goCheckout(context);
                          //   return;
                          // }
                          // if (screen == 'delivery_pickup') {
                          //
                          //   print('aefef');
                          //   function();
                          //   return;
                          // }
                        },
                        disabledColor:
                            Theme.of(context).focusColor.withOpacity(0.5),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        color: Helper.canDelivery(
                                _con.carts[0].product.market,
                                carts: _con.carts)
                            ? !_con.carts[0].product.market.closed
                                ? Theme.of(context).accentColor
                                : Theme.of(context)
                                    .focusColor
                                    .withOpacity(0.5)
                            : Theme.of(context).focusColor.withOpacity(0.5),
                        shape: StadiumBorder(),
                        child: Text(
                          S.of(context).checkout,
                          textAlign: TextAlign.start,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .merge(TextStyle(
                                  color: Theme.of(context).primaryColor)),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {

                        if (_isDeliveryPage) {
                          if (Helper.canDelivery(
                              _con.carts[0].product.market,
                              carts: _con.carts)) {
                            try {
                              _con.goCheckout(context);
                            } catch (e) {
                              Fluttertoast.showToast(
                                  msg: 'Please Select Delivery Address');
                            }
                          } else {
                            Fluttertoast.showToast(
                                msg: 'Please Select Delivery Address');
                          }
                        } else {
                          try {
                            _con.goCheckout(context);
                          } catch (e) {
                            Fluttertoast.showToast(
                                msg: 'Please Select Delivery Address');
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        // child: Helper.getPrice(_con.total, context,
                        //     style: Theme.of(context).textTheme.headline4.merge(TextStyle(color: Theme.of(context).primaryColor)), zeroPlaceholder: 'Free'),
                        child: Text(
                          '₹ ${_con.total.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headline4.merge(
                              TextStyle(
                                  color: Theme.of(context).primaryColor)),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          );
  }
}
