import 'dart:convert';

class Notification {
  String id;
  String type;
  NotificationData NotiData;
  NotificationData2 NotiData2;
  String data;
  bool read;
  DateTime createdAt;


  Notification();

  Notification.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      type = jsonMap['type'] != null ? jsonMap['type'].toString() : '';
      data = jsonMap['data'] != null ? jsonMap['data'] : "";
      print(jsonMap['data']);
      NotiData = jsonMap['data'] != null ? NotificationData.fromJson(jsonDecode(jsonMap['data'])) : NotificationData();
      read = jsonMap['read_at'] != null ? true : false;
      createdAt = DateTime.parse(jsonMap['created_at']);
    } catch (e) {
      print("eroro" + e.toString());
      print(jsonMap['data']);
      NotiData2 = jsonMap['data'] != null ? NotificationData2.fromJson(jsonDecode(jsonMap['data'])) : NotificationData2();
      print(NotiData2.toString());
      id = '';
      type = '';
      data = "";
      read = false;
      createdAt = new DateTime(0);
      print(e);
    }
  }

  Map markReadMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["read_at"] = !read;
    return map;
  }
}

class NotificationData {
  NotificationData({
    this.status,
    this.orderId,
  });

  String status;
  int orderId;

  factory NotificationData.fromJson(Map<String, dynamic> json) => NotificationData(
    status: json["status"],
    orderId: json["order_id"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "order_id": orderId,
  };
}

// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

class NotificationData2 {
  NotificationData2({
    this.status,
    this.orderId,
  });

  Status status;
  int orderId;

  factory NotificationData2.fromJson(Map<String, dynamic> json) => NotificationData2(
    status: Status.fromJson(json["status"]),
    orderId: json["order_id"],
  );

  Map<String, dynamic> toJson() => {
    "status": status.toJson(),
    "order_id": orderId,
  };
}

class Status {
  Status({
    this.id,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.customFields,
  });

  int id;
  String status;
  DateTime createdAt;
  DateTime updatedAt;
  List<dynamic> customFields;

  factory Status.fromJson(Map<String, dynamic> json) => Status(
    id: json["id"],
    status: json["status"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    customFields: List<dynamic>.from(json["custom_fields"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "custom_fields": List<dynamic>.from(customFields.map((x) => x)),
  };
}
