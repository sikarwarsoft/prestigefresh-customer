import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:global_configuration/global_configuration.dart';
import 'package:markets/src/helpers/constants.dart';
import 'package:markets/src/models/custom_fieldsss.dart';
import 'package:markets/src/models/user_transation.dart';
import 'package:markets/src/models/wallet_details.dart';
import 'package:markets/src/repository/passbook_repository.dart';
import 'package:markets/src/repository/user_repository.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class WalletScreen extends StatefulWidget {
  String token;
  String id;

  WalletScreen({this.token, this.id});

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  String amount = '0';
  String addAmount = '';
  String transType = '';
  String transAmount = '';
  String transId = ' ';
  Datum lol;
  List<Datum> llol = [];
  bool isLoading = true;
  Razorpay _razorpay;

  Future<void> getDetails() async {
    print(widget.id);
    print('i am o44545odd');
    final String url =
        '${GlobalConfiguration().getString('api_base_url')}wallet/passbook';
    final client = new http.Client();
    final response = await client.post(
      url,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode({'user_id': widget.id}),
    );
    final WalletDetail walletDetail = walletDetailFromJson(response.body);
    setState(() {
      amount = walletDetail.data.ewalletAmount.toString();
    });
    print('resss' + walletDetail.data.email);
  }

  Future<void> userStatement() async {
    llol = [];
    print('user staaa');
    final String url =
        '${GlobalConfiguration().getString('api_base_url')}wallet/statement';
    final client = new http.Client();
    final response = await client.post(
      url,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode({'user_id': widget.id}),
    );
    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
      print(response.statusCode);
      final UserTransaction userTransaction =
          UserTransaction.fromJson(json.decode(response.body));
      print('my res' + response.body);
      print('length' + userTransaction.data.length.toString());
      setState(() {
        for (int i = 0; i < userTransaction.data.length; i++) {
          print('ttyppee' + userTransaction.data[i].transactionType.toString());
          lol = Datum(
            transactionAmount: userTransaction.data[i].transactionAmount,
            transactionId: userTransaction.data[i].transactionId,
            transactionType: userTransaction.data[i].transactionType,
          );
          llol.add(lol);
        }
      });
    } else {
      throw new Exception(response.body);
    }
  }

  Future<void> showAddMoneyDialog(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              height: MediaQuery.of(context).size.height * .6,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Money to Wallet',
                          style: Theme.of(context).textTheme.subtitle1,
                          // style: TextStyle(
                          //     color: Theme.of(context).accentColor,
                          //     fontSize: 25,
                          //     // fontWeight: FontWeight.w500
                          // ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            Text(
                              'Available Balance',
                              style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              '₹ $amount',
                              style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Form(
                      key: _key,
                      child: TextFormField(
                        style: TextStyle(
                          fontSize: 32,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'This field is required';
                          }
                          return null;
                        },
                        onSaved: (value) => addAmount = value,
                        decoration: InputDecoration(
                          labelText: 'amount',
                          labelStyle:
                              TextStyle(color: Theme.of(context).accentColor),
                          contentPadding: EdgeInsets.all(12),
                          hintText: '',
                          hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.7)),
                          prefixIcon: Icon(Icons.lock_outline,
                              color: Theme.of(context).accentColor),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                        ),
                      ),
                    ),
                    RaisedButton(
                        color: Theme.of(context).accentColor,
                        child: Text(
                          'Proceed',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        onPressed: () {
                          if (_key.currentState.validate()) {
                            _key.currentState.save();
                            openCheckout();
                          }
                        })
                  ],
                ),
              ),
            ),
          );
        });
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: false,
        builder: (context) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 15, right: 15, top: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Money to Wallet',
                      style: Theme.of(context).textTheme.headline1,
                          // style: TextStyle(
                          //     color: Theme.of(context).accentColor,
                          //     fontSize: 25,
                              // fontWeight: FontWeight.w500
                          // ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            Text(
                              'Available Balance',
                              style: Theme.of(context).textTheme.subtitle1,
                              // style: TextStyle(
                              //     color: Theme.of(context).accentColor,
                              //     fontSize: 15,
                              //     fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              '₹ $amount',
                              style: Theme.of(context).textTheme.subtitle1,
                              // style: TextStyle(
                              //     color: Theme.of(context).accentColor,
                              //     fontSize: 15,
                              //     fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Form(
                      key: _key,
                      child: TextFormField(
                        style: TextStyle(
                          fontSize: 25,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'This field is required';
                          }
                          return null;
                        },
                        onSaved: (value) => addAmount = value,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          labelStyle: Theme.of(context).textTheme.subtitle1,
                          contentPadding: EdgeInsets.all(12),
                          hintText: '',
                          // hintStyle: TextStyle(
                          //     color: Theme.of(context)
                          //         .focusColor
                          //         .withOpacity(0.7)),
                          prefixIcon: Icon(Icons.lock_outline,
                              color: Theme.of(context).focusColor.withOpacity(1),),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: RaisedButton(
                        color: Theme.of(context).accentColor,
                        padding: EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20.0),
                                bottom: Radius.circular(20.0))),
                        child: Text(
                          'Proceed',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16),
                        ),
                        onPressed: () {
                          if (_key.currentState.validate()) {
                            _key.currentState.save();
                            openCheckout();
                          }
                        }),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          );
        });
  }

  void openCheckout() async {
    print("dlldld");
    final key = Provider.of<CustomFieldsss>(context, listen: false).getRazorKey;
    print('sdsadsdsadasdsa' + key);
    var options = {
      'key': "rzp_test_1EQTOegNCPi1dg",
      // 'key': '$key',
      'amount': int.parse(addAmount) * 100,
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
      debugPrint(e);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('done success');
    addMoney(int.parse(addAmount), 'RazorPay').then((value) {
      print('done done');
      Fluttertoast.showToast(
        msg: "SUCCESS: " + response.paymentId,
      );
      Navigator.pop(context);
      isLoading = true;
      getDetails();
      userStatement();
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('done fail');
    Fluttertoast.showToast(
      msg: "ERROR: " + response.code.toString() + " - " + response.message,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    addMoney(int.parse(addAmount), 'RazorPay').then((value) {
      print('done done');
      Fluttertoast.showToast(
        msg: "SUCCESS: " + response.walletName,
      );
      Navigator.pop(context);
      isLoading = true;
      getDetails();
      userStatement();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getDetails();
    userStatement();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // backgroundColor: Theme.of(context).accentColor,
      appBar: AppBar(
        title: Text(
          'My Wallet',
          style: TextStyle(color: Theme.of(context).accentColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Theme.of(context).accentColor,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Add Money'),
        icon: Icon(Icons.add),
        backgroundColor: Color(0xff12295b),
        // backgroundColor: Theme.of(context).accentColor,
        onPressed: () {
          // showAddMoneyDialog(context);
          _settingModalBottomSheet(context);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      body:
          // currentUser.value.apiToken == null
          //     ? PermissionDeniedWidget() :
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                  child: Column(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        // color: Colors.blue[900],
                        // decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.all(Radius.circular(16)),
                        //     color: Colors.green.shade300),
                        // padding:
                        //     EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Container(
                          height: MediaQuery.of(context).size.height*0.25,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            image: DecorationImage(
                              image: AssetImage("assets/img/bgcard.png"),
                              fit: BoxFit.fitWidth,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Available Balance',
                                    style: TextStyle(
                                        fontSize: 18,
                                        // fontWeight: FontWeight.w500,
                                        color: Colors.white
                                        // color: Theme.of(context).accentColor

                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    '₹ $amount',
                                    style: TextStyle(
                                        fontSize: 50,
                                        // fontWeight: FontWeight.bold,
                                        color: Colors.white
                                    ),
                                  ),

                                ],
                              ),
                              // CircleAvatar(
                              //   child: Icon(
                              //     Icons.arrow_forward_ios,
                              //     color: Colors.green,
                              //   ),
                              //   backgroundColor: Colors.white,
                              // ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16)),
                              ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 0, vertical: 8),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Transactions',
                                    // style: TextStyle(
                                    //     // color: Colors.white,
                                    //   // color: Color(0xff12295b),
                                    //     color: Theme.of(context).accentColor,
                                    //     // color: Colors.green.shade300,
                                    //     fontSize: 25,
                                    //     fontWeight: FontWeight.w600
                                    // ),
                                    style: Theme.of(context).textTheme.subtitle1,
                                  ),
                                  Icon(
                                    Icons.bar_chart,
                                    // color: Colors.green.shade300,
                                    // color: Color(0xff12295b),
                                    // color: Colors.white,
                                    color: Theme.of(context).focusColor.withOpacity(1),
                                    // color: Theme.of(context).accentColor,
                                    size: 30,
                                  )
                                ],
                              ),
                              Divider(
                                height: 20,
                                thickness: 5,
                                // indent: 20,
                                // endIndent: 20,
                              ),
                              Container(
                                width: double.infinity,
                                height: 400,
                                child: ListView.builder(
                                    itemCount: llol.length,
                                    itemBuilder: (context, index) {
                                      return Card(
                                        child: ListTile(
                                          // leading: Icon(Icons.money,
                                          //     color: Colors.black),
                                          title: Text(
                                            '${llol[index].transactionType}',
                                            style: Theme.of(context).textTheme.subtitle2,
                                            // style: TextStyle(
                                            //   color: Color(0xff12295b),
                                            //   // color: Theme.of(context).accentColor,
                                            // ),
                                          ),
                                          subtitle: Text(
                                            '${llol[index].transactionId}',
                                            style: Theme.of(context).textTheme.bodyText1,
                                            // style: TextStyle(
                                            //     // color: Theme.of(context).accentColor,
                                            //     color: Color(0xff12295b),
                                            //     fontSize: 14),
                                          ),
                                          trailing: Text(
                                            '  ₹ ${llol[index].transactionAmount.toString()}',
                                            style: Theme.of(context).textTheme.bodyText1,
                                            // style: TextStyle(
                                            //     // color: Theme.of(context).accentColor,
                                            //     color: Color(0xff12295b),
                                            //     fontSize: 18),
                                          ),
                                        ),
                                      );
                                    }),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
