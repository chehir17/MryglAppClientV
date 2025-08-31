import '../models/media.dart';

class Option {
  String id;
  String optionGroupId;
  String name;
  double price;
  Media image;
  String description;
  bool checked;

  Option()
      : id = '',
        optionGroupId = '0',
        name = '',
        price = 0.0,
        image = Media(),
        description = '',
        checked = false;

  Option.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id']?.toString() ?? '',
        optionGroupId = jsonMap['option_group_id'] != null
            ? jsonMap['option_group_id'].toString()
            : '0',
        name = jsonMap['name']?.toString() ?? '',
        price = jsonMap['price'] != null
            ? (jsonMap['price'] is double
                ? jsonMap['price']
                : double.tryParse(jsonMap['price'].toString()) ?? 0.0)
            : 0.0,
        description = jsonMap['description']?.toString() ?? '',
        checked = false,
        image =
            (jsonMap['media'] != null && (jsonMap['media'] as List).isNotEmpty)
                ? Media.fromJSON(jsonMap['media'][0])
                : Media();

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["name"] = name;
    map["price"] = price;
    map["description"] = description;
    return map;
  }

  @override
  bool operator ==(dynamic other) {
    return other.id == this.id;
  }
}
