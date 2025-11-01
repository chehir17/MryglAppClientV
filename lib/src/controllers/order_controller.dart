import 'package:flutter/material.dart';
import 'package:markets/src/helpers/global.dart';
import 'package:markets/src/helpers/helper.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import '../../generated/i18n.dart';
import '../models/order.dart';
import '../repository/order_repository.dart';

class OrderController extends ControllerMVC {
  late List<Order> orders = <Order>[];
  late GlobalKey<ScaffoldState> scaffoldKey;

  OrderController() {
    scaffoldKey = GlobalKey<ScaffoldState>();
    listenForOrders();
  }

  Future<void> showReviewsDialogOrNot() async {
    int installDays = 1;
    int ordersDeliverdCount = 0;
    late bool firstShow;

    await Helper.getInstallDate().then((value) => installDays += value);
    await Helper.getFirstShow().then((value) => firstShow = value);

    orders.forEach((element) {
      if (element.orderStatus?.id == '5') ordersDeliverdCount++;
    });

    if (ordersDeliverdCount >= 2 && orders.length >= 3) {
      if (!firstShow) {
        goToGoogleReviews();
      } else if (installDays % 30 == 0 && orders.length > 3) {
        goToGoogleReviews();
      }
    }
  }

  Future<void> goToGoogleReviews() async {
    Future.delayed(const Duration(seconds: 3), () {
      AwesomeDialog(
        context: scaffoldKey.currentContext!,
        dialogType: DialogType.info,
        animType: AnimType.bottomSlide,
        headerAnimationLoop: false,
        title: 'تقييم التطبيق على غوغل بلاي',
        desc:
            'عملا على تحسين خدماتنا وإرضائكم المرجو عمل تقييم للتطبيق لمساعدتنا أكثر وأكثر',
        btnOkText: 'تقييم',
        btnCancelText: 'تجاهل',
        btnOkOnPress: () async {
          showD = false;
          final url = Uri.parse(
              'https://play.google.com/store/apps/details?id=com.mriguel.markets');
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            throw 'Could not launch $url';
          }
        },
        btnCancelOnPress: () {
          showD = false;
        },
      ).show();
    });
  }

  void listenForOrders({String? message}) async {
    final Stream<Order> stream = await getOrders();
    stream.listen((Order _order) {
      setState(() {
        orders.add(_order);
      });
    }, onError: (a) {
      print(a);
      ScaffoldMessenger.of(scaffoldKey.currentState!.context).showSnackBar(
        SnackBar(
          content: Text(S.current.verify_your_internet_connection),
        ),
      );
    }, onDone: () {
      if (message != null) {
        ScaffoldMessenger.of(scaffoldKey.currentState!.context).showSnackBar(
          SnackBar(
            content: Text(message),
          ),
        );
      }
      showReviewsDialogOrNot();
    });
  }

  Future<void> refreshOrders() async {
    orders.clear();
    listenForOrders(message: S.current.order_refreshed_successfuly);
  }
}
