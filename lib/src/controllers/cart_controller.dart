import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_utils/spherical_utils.dart';
import 'package:markets/src/helpers/global.dart';
import 'package:markets/src/models/Coupon.dart';
import 'package:markets/src/repository/settings_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/i18n.dart';
import '../models/cart.dart';
import '../models/market.dart';
import '../repository/cart_repository.dart';
import '../models/address.dart' as model;

class CartController extends ControllerMVC {
  List<Cart> carts = <Cart>[];
  double taxAmount = 0.0;
  double deliveryFee = 0.0;
  int cartCount = 0;
  double subTotal = 0.0;
  double? minimum = 0.0;
  double total = 0.0;
  int countMarket = 0;
  // List<Market> markets = <Market>[];
  List<String> markets = <String>[];
  // model.Address deliveryAddress;
  late GlobalKey<ScaffoldState> scaffoldKey;
  bool navigate = false;
  bool longDistance = false;

  CartController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForCarts({String? message}) async {
    final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
      if (!carts!.contains(_cart)) {
        setState(() {
          carts!.add(_cart);
        });
      }
    }, onError: (a) {
      // print(a);
      ScaffoldMessenger.of(scaffoldKey.currentState!.context)
          .showSnackBar(SnackBar(
        content: Text(S.current.verify_your_internet_connection),
      ));
    }, onDone: () {
      if (carts!.isNotEmpty) {
        calculateSubtotal();
        isUniqueMarketOrNot();
      }
      if (message != null) {
        ScaffoldMessenger.of(scaffoldKey.currentState!.context)
            .showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void listenForCartsCount({String? message}) async {
    final Stream<int> stream = await getCartCount();
    stream.listen((int _count) {
      setState(() {
        this.cartCount = _count;
      });
    }, onError: (a) {
      // print(a);
      ScaffoldMessenger.of(scaffoldKey.currentState!.context)
          .showSnackBar(SnackBar(
        content: Text(S.current.verify_your_internet_connection),
      ));
    });
  }

  void couponCalc({String? code}) async {
    couponDiscount = 0;
    startValue = 0;
    couponDiscountValue = 0;
    final Stream<Coupon> stream = await getCoupon(code);
    try {
      stream.listen((Coupon _coupon) {
        // print(subTotal);
        if ((_coupon.marketId == carts![0].product!.market.id &&
                subTotal >= _coupon.start! &&
                _coupon.value! > 0 &&
                _coupon.forDelivery == false) ||
            (_coupon.forAll == true &&
                _coupon.value! > 0 &&
                subTotal >= _coupon.start! &&
                _coupon.forDelivery == false)) {
          final dateNow = DateTime.now();
          final difference = _coupon.dateExp!.difference(dateNow).inDays;
          if (difference + 1 > 0) {
            couponDiscount = _coupon.value!;
            startValue = _coupon.start!;
            calculateSubtotal();
          } else {
            ScaffoldMessenger.of(scaffoldKey.currentState!.context)
                .showSnackBar(SnackBar(
              content: Text(S.current.this_coupon_wrong),
            ));
            couponDiscount = 0;
            startValue = 0;
            couponDiscountValue = 0;
            couponDiscountForDelivery = 0;
            calculateSubtotal();
          }
        } else if ((_coupon.marketId == carts![0].product!.market.id &&
                deliveryFee >= _coupon.start! &&
                _coupon.value! > 0 &&
                _coupon.forDelivery!) ||
            (_coupon.forAll == true &&
                _coupon.forDelivery == true &&
                _coupon.value! > 0 &&
                deliveryFee >= _coupon.start!)) {
          final dateNow = DateTime.now();
          print('gggggg');
          final difference = _coupon.dateExp!.difference(dateNow).inDays;
          if (difference + 1 > 0) {
            couponDiscountForDelivery = _coupon.value!;
            startValue = _coupon.start!;
            calculateSubtotal();
          } else {
            ScaffoldMessenger.of(scaffoldKey.currentState!.context)
                .showSnackBar(SnackBar(
              content: Text(S.current.this_coupon_wrong),
            ));
            couponDiscount = 0;
            startValue = 0;
            couponDiscountValue = 0;
            couponDiscountForDelivery = 0;
            calculateSubtotal();
          }
        } else {
          couponDiscount = 0;
          startValue = 0;
          couponDiscountValue = 0;
          couponDiscountForDelivery = 0;
          calculateSubtotal();
          ScaffoldMessenger.of(scaffoldKey.currentState!.context)
              .showSnackBar(SnackBar(
            content: Text(S.current.this_coupon_wrong),
          ));
        }
      }, onError: (a) {
        couponDiscount = 0;
        startValue = 0;
        couponDiscountValue = 0;
        couponDiscountForDelivery = 0;
        calculateSubtotal();
        ScaffoldMessenger.of(scaffoldKey.currentState!.context)
            .showSnackBar(SnackBar(
          content: Text(S.current.verify_your_internet_connection),
        ));
      }, onDone: () {});
    } catch (e) {
      couponDiscount = 0;
      startValue = 0;
      couponDiscountValue = 0;
      couponDiscountForDelivery = 0;
      calculateSubtotal();
    }
  }

  Future<void> refreshCarts() async {
    listenForCarts(message: S.current.carts_refreshed_successfuly);
  }

  void removeFromCart(Cart _cart) async {
    setState(() {
      this.carts!.remove(_cart);
    });
    removeCart(_cart).then((value) {
      calculateSubtotal();
      ScaffoldMessenger.of(scaffoldKey.currentState!.context)
          .showSnackBar(SnackBar(
        content: Text(S.current
            .the_product_was_removed_from_your_cart(_cart.product!.name)),
      ));
    });
  }

  bool isUniqueMarketOrNot() {
    for (var cart in carts!) {
      if (cart.product!.unique == true) {
        setState(() => minimum = cart.product!.market.minimum);
        return true;
      }
    }
    setState(() => minimum = setting.value.minimum);
    return false;
  }

  bool isOutOfStock() {
    for (var cart in carts!) {
      if (cart.product!.inStock == false) {
        return true;
      }
    }
    return false;
  }

  double distanceCalc() {
    double sum = 0;
    // if()
    Point from = Point(
        double.parse(carts.elementAt(0).product!.market.latitude!),
        double.parse(carts.elementAt(0).product!.market.longitude!));
    Point to = Point(
        deliveryAddress.value.latitude!, deliveryAddress.value.longitude!);
    double distance =
        SphericalUtils.computeDistanceBetween(from, to).toDouble();

    if (setting.value.maxRadius! < (distance * 1000)) {
      longDistance = true;
    } else if (distance > setting.value.maxDistance! &&
        setting.value.maxDistance! > 0 &&
        setting.value.distanceFee! > 0) {
      longDistance = false;
      double diff = distance - (setting.value.maxDistance! * 1000);
      sum = setting.value.distanceFee! * (diff / 1000);
      setting.value.distanceFeeOrder = sum;
      print('---------------------------distance ${diff / 1000}');
      print(
          '---------------------------distance Fee ${setting.value.distanceFee}');
      // sum = _order.deliveryFee + distanceFee;
      // print('distance fee: ${_order.deliveryFee} ');
    }

    print('---------------------------sum $sum');
    return sum;
  }

  int get marketCount => this.markets.length;

  void calculateSubtotal() async {
    subTotal = 0;
    this.markets.clear();
    carts.forEach((cart) {
      subTotal += cart.quantity! * cart.product!.price;
      print(
          "${cart.product!.market.id} - ${this.markets.indexOf(cart.product!.market.id!)}");
      if (this.markets.indexOf(cart.product!.market.id!) == -1)
        this.markets.add(cart.product!.market.id!);
    });

    if (couponDiscount > 0) {
      couponDiscountValue = subTotal * (couponDiscount / 100);
      // subTotal -= subTotal * (couponDiscount / 100);
    }
    // else if(couponDiscountForDelivery>0){
    deliveryFee =
        carts[0].product!.market.deliveryFee! - couponDiscountForDelivery;
    if (deliveryFee < 0) deliveryFee = 0;
    if (deliveryAddress.value?.latitude != null) deliveryFee += distanceCalc();

    if (this.markets.length > setting.value.maxMarket! &&
        setting.value.maxMarket! > 0) {
      int rest = this.markets.length - setting.value.maxMarket!.toInt();
      deliveryFee += (rest * setting.value.marketFeeOrder!);
    }

    // }

    // deliveryFee = carts[0].product.market.deliveryFee;
    taxAmount =
        (subTotal + deliveryFee) * carts[0].product!.market.defaultTax! / 100;
    total = subTotal + taxAmount + deliveryFee - couponDiscountValue;
    setState(() {});
  }

  incrementQuantity(Cart cart) {
    if (cart.quantity! <= 99) {
      cart.quantity = cart.quantity! + 1;
      updateCart(cart);
      calculateSubtotal();
    }
  }

  decrementQuantity(Cart cart) {
    if (cart.quantity! > 1) {
      cart.quantity = cart.quantity! - 1;
      updateCart(cart);
      calculateSubtotal();
    } else {
      setState(() {
        couponDiscount = 0.0;
        startValue = 0.0;
        couponDiscountValue = 0.0;
        couponDiscountForDelivery = 0.0;
      });
    }
  }
}
