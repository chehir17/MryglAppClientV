import '../models/media.dart';

class User {
  String? id;
  String? name;
  String? email;
  String? password;
  String? apiToken;
  String? deviceToken;
  String? fbID;
  String? fbToken;
  // String deviceToken;
  String? phone;
  String? address;
  String? bio;
  Media? image;

  // used for indicate if client logged in or not
  bool? auth;

//  String role;
  User({
    this.id,
    this.name,
    this.email,
    this.password,
    this.apiToken,
    this.deviceToken,
    this.fbID,
    this.fbToken,
    this.phone,
    this.address,
    this.bio,
    this.image,
    this.auth,
  });

  User.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'];
      email = jsonMap['email'];
      apiToken = jsonMap['api_token'];
      deviceToken = jsonMap['device_token'];
      try {
        phone = jsonMap['phone'].toString();
      } catch (e) {
        phone = "";
      }
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
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0
          ? Media.fromJSON(jsonMap['media'][0])
          : new Media();
    } catch (e) {
      print(e);
    }
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

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["email"] = email;
    map["name"] = name;
    map["fb_id"] = fbID;
    map["fb_token"] = fbToken;
    map["password"] = password;
    map["api_token"] = apiToken;
    if (deviceToken != null) {
      map["device_token"] = deviceToken;
    }
    map["phone"] = phone;
    map["address"] = address;
    map["bio"] = bio;
    map["media"] = image?.toMap();
    return map;
  }

  Map toGgMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["email"] = email;
    map["name"] = name;
    map["fb_id"] = fbID;
    map["fb_token"] = fbToken;
    map["password"] = password;
    map["api_token"] = apiToken;
    map["google_log"] = name;
    if (deviceToken != null) {
      map["device_token"] = deviceToken;
    }
    map["phone"] = phone;
    map["address"] = address;
    map["bio"] = bio;
    map["media"] = image?.toMap();
    return map;
  }

  @override
  String toString() {
    var map = this.toMap();
    map["auth"] = this.auth;
    return map.toString();
  }
}
