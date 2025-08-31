class Coupon {
  String? code;
  String? marketId;
  double? value;
  double? start;
  DateTime? dateExp;
  bool? forAll;
  bool? forDelivery;
  bool? v;

  Coupon(this.code, this.marketId, this.value, this.start, this.dateExp,
      this.forAll, this.forDelivery, this.v);

  Coupon.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      code = jsonMap['code'].toString();
      marketId = jsonMap['market_id'].toString();
      value = jsonMap['value'] != null
          ? double.parse(jsonMap['value'].toString())
          : 0.0;
      start = jsonMap['start'] != null
          ? double.parse(jsonMap['start'].toString())
          : 0.0;
      dateExp = jsonMap['date_exp'] != null
          ? DateTime.parse(jsonMap['date_exp'])
          : null;
      forAll = jsonMap['all_products'] == 0 ? false : true;
      forDelivery = jsonMap['for_delivery'] == 0 ? false : true;
      print('++++++++++++++++++ $forDelivery');
      v = true;
    } catch (e) {
      print('this from coupom $e');
      code = null;
      marketId = null;
      start = null;
      dateExp = null;
      forAll = null;
    }
  }

  Coupon.fromJSONFalse() {
    v = false;
  }
}
