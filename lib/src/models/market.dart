import 'package:markets/src/models/category.dart';
import 'package:markets/src/models/user.dart';

import '../models/media.dart';

class Market {
  String? id;
  String? name;
  Media? image;
  String? rate;
  String? address;
  String? description;
  String? phone;
  String? mobile;
  String? information;
  double? deliveryFee;
  double? adminCommission;
  double? defaultTax;
  String? latitude;
  String? longitude;
  bool? closed;
  bool? availableForDelivery;
  double? deliveryRange;
  double? distance;
  double? minimum;
  List<User>? users;
  List<Category>? categories;

  Market(this.id, this.name, this.latitude, this.longitude,
      {this.image,
      this.rate = '0',
      this.address = '',
      this.description = '',
      this.phone = '',
      this.mobile = '',
      this.information = '',
      this.deliveryFee = 0.0,
      this.adminCommission = 0.0,
      this.defaultTax = 0.0,
      this.closed = false,
      this.availableForDelivery = false,
      this.deliveryRange = 0.0,
      this.distance = 0.0,
      this.minimum = 0.0,
      this.users = const [],
      this.categories = const []});

  /// ✅ Empty constructor so you can call Market.empty()
  Market.empty()
      : id = '',
        name = '',
        latitude = '0',
        longitude = '0',
        image = Media(),
        rate = '0',
        address = '',
        description = '',
        phone = '',
        mobile = '',
        information = '',
        deliveryFee = 0.0,
        adminCommission = 0.0,
        defaultTax = 0.0,
        closed = false,
        availableForDelivery = false,
        deliveryRange = 0.0,
        distance = 0.0,
        minimum = 0.0,
        users = const [],
        categories = const [];

  // fromJSON stays the same
  Market.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'];
      image = jsonMap['media'] != null && (jsonMap['media'] as List).isNotEmpty
          ? Media.fromJSON(jsonMap['media'][0])
          : Media();
      rate = jsonMap['rate'] ?? '0';
      deliveryFee = jsonMap['delivery_fee'] != null
          ? jsonMap['delivery_fee'].toDouble()
          : 0.0;
      adminCommission = jsonMap['admin_commission'] != null
          ? jsonMap['admin_commission'].toDouble()
          : 0.0;
      deliveryRange = jsonMap['delivery_range'] != null
          ? jsonMap['delivery_range'].toDouble()
          : 0.0;
      address = jsonMap['address'];
      description = jsonMap['description'];
      phone = jsonMap['phone'];
      mobile = jsonMap['mobile'];
      defaultTax = jsonMap['default_tax'] != null
          ? jsonMap['default_tax'].toDouble()
          : 0.0;
      information = jsonMap['information'];
      latitude = jsonMap['latitude'];
      longitude = jsonMap['longitude'];
      closed = jsonMap['closed'] ?? false;
      availableForDelivery = jsonMap['available_for_delivery'] ?? false;
      distance = jsonMap['distance'] != null
          ? double.parse(jsonMap['distance'].toString())
          : 0.0;
      minimum = jsonMap['minimum'] != null
          ? double.parse(jsonMap['minimum'].toString())
          : 0.0;
      categories = jsonMap['market_categories'] != null &&
              (jsonMap['market_categories'] as List).isNotEmpty
          ? List.from(jsonMap['market_categories'])
              .map((element) => Category.fromJSON(element))
              .toSet()
              .toList()
          : [];
    } catch (e) {
      id = '';
      name = '';
      image = Media();
      rate = '0';
      deliveryFee = 0.0;
      adminCommission = 0.0;
      deliveryRange = 0.0;
      address = '';
      description = '';
      phone = '';
      mobile = '';
      defaultTax = 0.0;
      information = '';
      latitude = '0';
      longitude = '0';
      closed = false;
      availableForDelivery = false;
      distance = 0.0;
      users = [];
      categories = [];
      print(e);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'delivery_fee': deliveryFee,
      'distance': distance,
    };
  }
}
