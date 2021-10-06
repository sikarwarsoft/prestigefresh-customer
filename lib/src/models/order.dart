import '../models/address.dart';
import '../models/order_status.dart';
import '../models/payment.dart';
import '../models/product_order.dart';
import '../models/user.dart';

class Order {
  String id;
  List<ProductOrder> productOrders;
  OrderStatus orderStatus;
  double tax;
  double deliveryFee;
  String hint;
  bool active;
  DateTime dateTime;
  User user;
  Payment payment;
  Address deliveryAddress;
  String driver_id;
  double total;
  double finalTax;
  int isWallet;
  String order_status_id;

  Order();

  Order.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      tax = jsonMap['tax'] != null ? jsonMap['tax'].toDouble() : 0.0;
      deliveryFee = jsonMap['delivery_fee'] != null
          ? jsonMap['delivery_fee'].toDouble()
          : 0.0;
      hint = jsonMap['hint'] != null ? jsonMap['hint'].toString() : '';
      active = jsonMap['active'] ?? false;
      orderStatus = jsonMap['order_status'] != null
          ? OrderStatus.fromJSON(jsonMap['order_status'])
          : OrderStatus.fromJSON({});
      dateTime = DateTime.parse(jsonMap['updated_at']);
      order_status_id = jsonMap['order_status_id'].toString();
      user = jsonMap['user'] != null
          ? User.fromJSON(jsonMap['user'])
          : User.fromJSON({});
      deliveryAddress = jsonMap['delivery_address'] != null
          ? Address.fromJSON(jsonMap['delivery_address'])
          : Address.fromJSON({});
      payment = jsonMap['payment'] != null
          ? Payment.fromJSON(jsonMap['payment'])
          : Payment.fromJSON({});
      productOrders = jsonMap['product_orders'] != null
          ? List.from(jsonMap['product_orders'])
              .map((element) => ProductOrder.fromJSON(element))
              .toList()
          : [];

      driver_id =
          jsonMap['driver_id'] != null ? jsonMap['driver_id'].toString() : "";
      total = jsonMap['total'] != null ? jsonMap['total'].toDouble() : 0.0;
      finalTax =
          jsonMap['finalTax'] != null ? jsonMap['finalTax'].toDouble() : 0.0;
    } catch (e) {
      id = '';
      tax = 0.0;
      deliveryFee = 0.0;
      finalTax = 0.0;
      total = 0.0;
      hint = '';
      active = false;
      orderStatus = OrderStatus.fromJSON({});
      dateTime = DateTime(0);
      user = User.fromJSON({});
      payment = Payment.fromJSON({});
      deliveryAddress = Address.fromJSON({});
      productOrders = [];
      driver_id = '';
      isWallet = 0;
      print(jsonMap);
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["user_id"] = user?.id;
    map["order_status_id"] = orderStatus?.id;
    map["tax"] = tax;
    map['total'] = total;
    map['finalTax'] = finalTax;
    map['hint'] = hint;
    map["delivery_fee"] = deliveryFee;
    map["products"] =
        productOrders?.map((element) => element.toMap())?.toList();
    map["payment"] = payment?.toMap();
    map["delivery_address_id"] =
        deliveryAddress?.id == 'null' ? '24' : deliveryAddress?.id;
    map["isWallet"] = isWallet;

    return map;
  }

  Map deliveredMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["order_status_id"] = 5;
    print("mapmap");
    print(deliveryAddress?.id);
    if (deliveryAddress?.id != null && deliveryAddress?.id != 'null')
      map["delivery_address_id"] = deliveryAddress.id;
    return map;
  }

  Map cancelMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    if (orderStatus?.id != null && orderStatus?.id == '1') map["active"] = 0;
    return map;
  }

  bool canCancelOrder() {
    return this.active == true &&
        this.orderStatus.id == '1'; // 1 for order received status
  }
}
