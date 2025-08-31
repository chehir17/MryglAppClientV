import 'package:flutter/material.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:markets/src/helpers/global.dart';
import 'package:markets/src/helpers/helper.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/i18n.dart';
import '../models/order.dart';
import '../repository/order_repository.dart';

class OrderController extends ControllerMVC {
  late List<Order> orders = <Order>[];
  late GlobalKey<ScaffoldState> scaffoldKey;

  OrderController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    listenForOrders();
  }

  Future<void> showReviewsDialogOrNot() async {
    int installDays = 1;
    int ordersDeliverdCount = 0;
    late bool firstShow;
    await Helper.getInstallDate().then((value) => installDays += value);
    await Helper.getFirstShow().then((value) => firstShow = value);

    orders.forEach((element) {
      if (element.orderStatus!.id == '5') ordersDeliverdCount++;
    });

    if (ordersDeliverdCount >= 2 && orders.length >= 3) {
      if (!firstShow) {
        print('Fiiiiiiiiiiiiiiiiiiiiiirst');
        goToGoogleReviews();
      } else if (installDays % 30 == 0 && orders.length > 3) {
        goToGoogleReviews();
      }
    }
  }

  Future<void> goToGoogleReviews() async {
    Future.delayed(Duration(seconds: 3), () {
      showDialog(
          context: scaffoldKey.currentContext!,
          builder: (_) {
            return GiffyDialog.image(
              Image.asset(
                "assets/img/google_play.png",
                fit: BoxFit.cover,
              ),
              title: Text(
                'تقييم التطبيق على غوغل بلاي',
                textAlign: TextAlign.center,
                style: Theme.of(scaffoldKey.currentContext!)
                    .textTheme
                    .titleLarge!
                    .merge(const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.3,
                    )),
              ),
              content: Text(
                  'عملا على تحسين خدماتنا وإرضائكم المرجو عمل تقييم للتطبيق لمساعدتنا أكثر وأكثر',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600)),
              entryAnimation: EntryAnimation.bottom,
              actions: [
                TextButton(
                  onPressed: () async {
                    showD = false;
                    const url =
                        'https://play.google.com/store/apps/details?id=com.mriguel.markets';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                    Navigator.pop(scaffoldKey.currentContext!);
                  },
                  child: Text(
                    'تقييم',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    showD = false;
                    Navigator.pop(scaffoldKey.currentContext!);
                    // setDisableUpdate();
                  },
                  child: Text('تجاهل',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            );
          });
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
      ScaffoldMessenger.of(scaffoldKey.currentState!.context)
          .showSnackBar(SnackBar(
        content: Text(S.current.verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        ScaffoldMessenger.of(scaffoldKey.currentState!.context)
            .showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
      // goToGoogleReviews();
      showReviewsDialogOrNot();
    });
  }

  Future<void> refreshOrders() async {
    orders.clear();
    listenForOrders(message: S.current.order_refreshed_successfuly);
  }
}
