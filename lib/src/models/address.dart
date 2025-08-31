import 'package:location/location.dart';
import 'package:markets/generated/i18n.dart';

class Address {
  String? id;
  String? description;
  String? address;
  var title;
  double? latitude;
  double? longitude;
  bool? isDefault;
  String? userId;

  Address(this.id, this.description, this.address, this.latitude,
      this.longitude, this.isDefault, this.userId)
      : title = address!.split(','); // title is the first part of the address

  Address.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      userId = jsonMap['user_id'].toString();
      description = jsonMap['description'] != null
          ? jsonMap['description'].toString()
          : null;
      address =
          jsonMap['address'] != null ? jsonMap['address'] : S.current.unknown;
      if (jsonMap['address'] != null)
        title = address!.split(',');
      else
        title = 'unknow,unknow'.split(',');
      latitude = jsonMap['latitude'] != null ? jsonMap['latitude'] : null;
      longitude = jsonMap['longitude'] != null ? jsonMap['longitude'] : null;
      isDefault = jsonMap['is_default'] ?? false;
    } catch (e) {
      id = '';
      description = '';
      address = S.current.unknown;
      latitude = null;
      longitude = null;
      isDefault = false;
      print(e);
    }
  }

  Address.empty();

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["description"] = description;
    map["address"] = address;
    map["latitude"] = latitude;
    map["longitude"] = longitude;
    map["is_default"] = isDefault;
    map["user_id"] = userId;
    return map;
  }

  LocationData toLocationData() {
    return LocationData.fromMap({
      "latitude": latitude,
      "longitude": longitude,
    });
  }
}
