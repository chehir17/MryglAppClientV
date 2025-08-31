import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_utils/spherical_utils.dart';
import 'package:markets/src/helpers/global.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:rating_dialog/rating_dialog.dart';

import '../../generated/i18n.dart';
import '../models/cart.dart';
import '../models/credit_card.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/payment.dart';
import '../models/product_order.dart';
import '../repository/cart_repository.dart';
import '../repository/order_repository.dart' as orderRepo;
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;
import 'dart:math';

class CheckoutController extends ControllerMVC {
  List<Cart> carts = <Cart>[];
  late Payment payment;
  double taxAmount = 0.0;
  double deliveryFee = 0.0;
  double subTotal = 0.0;
  double total = 0.0;
  CreditCard creditCard = CreditCard();
  bool loading = true;
  late GlobalKey<ScaffoldState> scaffoldKey;
  List<String> markets = <String>[];

  CheckoutController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    listenForCreditCard();
  }

  void listenForCreditCard() async {
    creditCard = await userRepo.getCreditCard();
    setState(() {});
  }

  void listenForCarts({String? message, bool withAddOrder = false}) async {
    final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
      if (!carts.contains(_cart)) {
        setState(() {
          carts.add(_cart);
        });
      }
    }, onError: (a) {
      // print(a);
      if (scaffoldKey.currentState != null) {
        ScaffoldMessenger.of(scaffoldKey.currentState!.context)
            .showSnackBar(SnackBar(
          content: Text(S.current.verify_your_internet_connection),
        ));
      }
    }, onDone: () {
      calculateSubtotal();
      if (withAddOrder != null && withAddOrder == true) {
        addOrder(carts);
      }
      if (message != null) {
        ScaffoldMessenger.of(scaffoldKey.currentState!.context)
            .showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void addOrder(List<Cart> carts) async {
    markets.clear();
    Order _order = Order();
    _order.productOrders = <ProductOrder>[];
    _order.tax = carts[0].product!.market.defaultTax ?? 0.0;
    _order.deliveryFee = payment.method == 'Pay on Pickup'
        ? 0.0
        : (carts[0].product!.market.deliveryFee ?? 0.0);

    if (settingRepo.setting.value.distanceFeeOrder! > 0) {
      _order.deliveryFee = (_order.deliveryFee ?? 0) +
          settingRepo.setting.value.distanceFeeOrder!;
    }

    deliveryFee = _order.deliveryFee ?? 0.0;

    OrderStatus _orderStatus = OrderStatus();
    _orderStatus.id = '1'; // TODO default order status Id
    _order.orderStatus = _orderStatus;
    _order.deliveryAddress = settingRepo.deliveryAddress.value;

    for (var _cart in carts) {
      ProductOrder _productOrder = ProductOrder();
      _productOrder.quantity = _cart.quantity!;
      _productOrder.price = _cart.product!.price;
      _productOrder.product = _cart.product;
      _productOrder.options = _cart.options!;
      _order.productOrders!.add(_productOrder);

      final marketId = _cart.product!.market.id;
      if (marketId != null && !markets.contains(marketId)) {
        markets.add(marketId);
      }
    }

    if (markets.length > settingRepo.setting.value.maxMarket! &&
        settingRepo.setting.value.maxMarket! > 0) {
      int rest = markets.length - settingRepo.setting.value.maxMarket!.toInt();
      _order.deliveryFee = (_order.deliveryFee ?? 0) +
          (rest * settingRepo.setting.value.marketFeeOrder!);
      deliveryFee += rest * settingRepo.setting.value.marketFeeOrder!;
      total += rest * settingRepo.setting.value.marketFeeOrder!;
    }

    setState(() {});
    // print(_order.toMap());
    orderRepo.addOrder(_order, payment).then((value) {
      if (value is Order) {
        setState(() {
          loading = false;
        });
      }
    }).catchError((e) {
      print(e);
    });
  }

  void calculateSubtotal() async {
    subTotal = 0;
    deliveryFee = 0;

    carts.forEach((cart) {
      subTotal += cart.quantity! * cart.product!.price!;
    });

    if (payment.method != 'Pay on Pickup') {
      deliveryFee =
          carts[0].product!.market.deliveryFee! - couponDiscountForDelivery;
    }

    if (couponDiscount > 0) {
      // subTotal -= subTotal * (couponDiscount / 100);
    }

    if (settingRepo.setting.value.distanceFeeOrder! > 0) {
      deliveryFee += settingRepo.setting.value.distanceFeeOrder!;
    }

    taxAmount = (subTotal + deliveryFee) *
        ((carts[0].product!.market.defaultTax ?? 0.0) / 100);
    total = subTotal + taxAmount + deliveryFee - couponDiscountValue;
    setState(() {});
  }

  void updateCreditCard(CreditCard creditCard) {
    userRepo.setCreditCard(creditCard).then((value) {
      setState(() {});
      ScaffoldMessenger.of(scaffoldKey.currentState!.context)
          .showSnackBar(SnackBar(
        content: Text(S.current.payment_card_updated_successfully),
      ));
    });
  }
}
