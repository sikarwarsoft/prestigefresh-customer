class Payment {
  String id;
  String status;
  String method;
  String walletAmmount;
  String discount;
  String discount_coupon;

  Payment.init();

  Payment(this.method);

  Payment.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      status = jsonMap['status'] ?? '';
      method = jsonMap['method'] ?? '';
      walletAmmount = jsonMap['method'] ?? "";
      discount = jsonMap['discount'] ?? "0";
      discount_coupon = jsonMap['discount_coupon'] ?? "";
    } catch (e) {
      id = '';
      status = '';
      method = '';
      print(e);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status,
      'method': method,
      'discount' : discount,
      'discount_coupon' : discount_coupon,
    };
  }
}
