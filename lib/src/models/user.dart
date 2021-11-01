import '../models/media.dart';

class User {
  String id;
  String name;
  String email;
  String wallet;
  String reffer;
  String password;
  String apiToken;
  String deviceToken;
  String phone;
  String address;
  String bio;
  Media image;

  // used for indicate if client logged in or not
  bool auth;

//  String role;

  User();

  User.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'] != null ? jsonMap['name'] : '';
      email = jsonMap['email'] != null ? jsonMap['email'] : '';
      phone = jsonMap['mobile_number'] != null ? jsonMap['mobile_number'] : "";
      apiToken = jsonMap['api_token'];
      deviceToken = jsonMap['device_token'];
      try {
        wallet = jsonMap['custom_fields']['ewallet_amount']['view'];
      } catch (e) {
        wallet = "";
      }
      try {
        reffer = jsonMap['custom_fields']['user_refer_code']['view'];
      } catch (e) {
        reffer = "";
      }
      // try {
      //   phone = jsonMap['custom_fields']['phone']['view'];
      // } catch (e) {
      //   phone = "";
      // }
      try {
        address = jsonMap['custom_fields']['address']['view'];
      } catch (e) {
        address = "";
      }
      try {
        bio = jsonMap['custom_fields']['bio']['view'];
      } catch (e) {
        bio = "";
      }
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0 ? Media.fromJSON(jsonMap['media'][0]) : new Media();
    } catch (e) {
      print(e);
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["email"] = email;
    map["name"] = name;
    map["password"] = password;
    map["api_token"] = apiToken;
    if (deviceToken != null) {
      map["device_token"] = deviceToken;
    }
    map["ewallet_amount"] = wallet;
    map["user_refer_code"] = reffer;
    map["mobile_number"] = phone;
    map["address"] = address;
    map["bio"] = bio;
    map["media"] = image?.toMap();
    return map;
  }

  Map toRestrictMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["email"] = email;
    map["name"] = name;
    map["thumb"] = image?.thumb;
    map["device_token"] = deviceToken;
    return map;
  }

  @override
  String toString() {
    var map = this.toMap();
    map["auth"] = this.auth;
    return map.toString();
  }

  bool profileCompleted() {
    return address != null && address != '' && phone != null && phone != '';
  }
}
