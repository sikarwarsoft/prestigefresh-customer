import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:markets/src/controllers/product_controller.dart';
import 'package:markets/src/models/get_coupon.dart';
import 'package:markets/src/models/total_provider.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../controllers/cart_controller.dart';
import '../elements/CartBottomDetailsWidget.dart';
import '../elements/CartItemWidget.dart';
import '../elements/EmptyCartWidget.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';

class CartWidget extends StatefulWidget {
  final RouteArgument routeArgument;

  CartWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _CartWidgetState createState() => _CartWidgetState();
}

class _CartWidgetState extends StateMVC<CartWidget> {
  String screen = 'cart';
  CartController _con;

  _CartWidgetState() : super(CartController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.listenForCarts();
    super.initState();
  }

  Future<bool> _willPopCallback() async {
    // await showDialog or Show add banners or whatever
    // then
    Navigator.pop(context);
    return true; // return true if the route to be popped
  }


  @override
  Widget build(BuildContext context) {
    print(_con.total);
    return WillPopScope(
      onWillPop:() => _willPopCallback(),
      // onWillPop: Helper.of(context).onWillPop,
      child: Scaffold(
        key: _con.scaffoldKey,
        bottomSheet: CartBottomDetailsWidget(
            con: _con, deliveryAllowed: true, isDeliveryPage: false),
        // bottomNavigationBar: CartBottomDetailsWidget(
        //     con: _con, deliveryAllowed: true, isDeliveryPage: false),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              if (widget.routeArgument != null) {
                Navigator.of(context).pushReplacementNamed(
                    widget.routeArgument.param,
                    arguments: RouteArgument(id: widget.routeArgument.id));
              } else {
                Navigator.of(context)
                    .pushReplacementNamed('/Pages', arguments: 2);
              }
            },
            icon: Icon(Icons.arrow_back),
            color: Theme.of(context).hintColor,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            S.of(context).cart,
            style: Theme.of(context)
                .textTheme
                .headline6
                .merge(TextStyle(letterSpacing: 1.3)),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _con.refreshCarts,
          child: _con.carts.isEmpty
              ? EmptyCartWidget()
              : Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 10),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 0),
                            leading: Icon(
                              Icons.shopping_cart,
                              color: Theme.of(context).hintColor,
                            ),
                            title: Text(
                              S.of(context).shopping_cart,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                            subtitle: Text(
                              S
                                  .of(context)
                                  .verify_your_quantity_and_click_checkout,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(17),
                          child: Text(
                            "Swipe left/right to remove item from cart",
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Expanded(
                          child: ListView.separated(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            primary: true,
                            itemCount: _con.carts.length,
                            separatorBuilder: (context, index) {
                              return SizedBox(height: 15);
                            },
                            itemBuilder: (context, index) {
                              return CartItemWidget(
                                cart: _con.carts.elementAt(index),
                                heroTag: 'cart',
                                increment: () {
                                  _con.incrementQuantity(
                                      _con.carts.elementAt(index));
                                  //
                                  // if(_con.carts.elementAt(index).quantity < int.parse(_productController.product.packageItemsCount)){
                                  //   _con.incrementQuantity(
                                  //       _con.carts.elementAt(index));
                                  // }else{
                                  //   showAlertDialog(context);
                                  // }

                                },
                                decrement: () {
                                  _con.decrementQuantity(
                                      _con.carts.elementAt(index));
                                },
                                onDismissed: () {
                                  _con.removeFromCart(
                                      _con.carts.elementAt(index));
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
