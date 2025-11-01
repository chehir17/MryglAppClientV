import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:markets/src/helpers/global.dart';
import 'package:markets/src/helpers/helper.dart';
import 'package:markets/src/models/slider.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import '../models/category.dart';
import '../models/market.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../repository/slider_repository.dart';
import '../repository/category_repository.dart';
import '../repository/market_repository.dart';
import '../repository/product_repository.dart';
import '../repository/settings_repository.dart';

class HomeController extends ControllerMVC {
  late List<Category> categories = <Category>[];
  late List<Market> topMarkets = <Market>[];
  late List<Market> topRests = <Market>[];
  late List<Review> recentReviews = <Review>[];
  late List<Product> trendingProducts = <Product>[];
  late List<SliderProduct> sliders = <SliderProduct>[];
  late GlobalKey<ScaffoldState> scaffoldKey;
  late String version;

  HomeController() {
    scaffoldKey = GlobalKey<ScaffoldState>();
    listenForSliders();
    listenForCategories();
    listenForTopMarkets();
    listenForTopRests();
    Helper.getInstallDate();
  }

  void setDisableUpdate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('disable_update_msg', true);
  }

  Future<void> goToGoogleReviews(BuildContext context) async {
    Future.delayed(const Duration(seconds: 3), () {
      showDialog(
        context: scaffoldKey.currentContext!,
        barrierDismissible: true,
        builder: (context) {
          return RatingDialog(
            title: const Text(
              "Rate Our App",
              textAlign: TextAlign.center,
            ),
            message: const Text(
              "Tap a star to set your rating. Add a comment if you like.",
              textAlign: TextAlign.center,
            ),
            image: Image.asset(
              'assets/img/google_play.png',
              height: 100,
            ),
            submitButtonText: "SUBMIT",
            onSubmitted: (response) {
              debugPrint(
                  "Rating: ${response.rating}, Comment: ${response.comment}");
              Navigator.pop(context);
            },
            onCancelled: () {
              debugPrint("Dialog dismissed without rating");
            },
          );
        },
      );
    });
  }

  Future<void> checkAppVersion(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;

    Future.delayed(const Duration(seconds: 5), () async {
      if (setting.value.appVersion != version && showD) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.info,
          animType: AnimType.bottomSlide,
          headerAnimationLoop: false,
          title: 'عملا على تحسين تجربتكم يرجى تحديث التطبيق',
          desc: '', // description vide si nécessaire
          btnOkText: 'تحديث',
          btnCancelText: 'تجاهل',
          btnOkOnPress: () async {
            showD = false;
            final url = Uri.parse(
                'https://play.google.com/store/apps/details?id=com.mriguel.markets');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
          btnCancelOnPress: () {
            showD = false;
          },
        ).show();
      }
    });
  }

  Future<void> listenForSliders() async {
    final Stream<SliderProduct> stream = await getSliders();
    stream.listen((SliderProduct _slider) {
      setState(() => sliders.add(_slider));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  Future<void> listenForCategories() async {
    final Stream<Category> stream = await getCategories();
    stream.listen((Category _category) {
      setState(() => categories.add(_category));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  Future<void> listenForTopMarkets() async {
    final Stream<Market> stream =
        await getNearMarkets(deliveryAddress.value, deliveryAddress.value);
    stream.listen((Market _market) {
      setState(() => topMarkets.add(_market));
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForTopRests() async {
    final Stream<Market> stream =
        await getRests(deliveryAddress.value, deliveryAddress.value);
    stream.listen((Market _market) {
      setState(() => topRests.add(_market));
    }, onError: (a) {}, onDone: () {});
  }

  void requestForCurrentLocation(BuildContext context) {
    Helper.locationPermission();
    OverlayEntry loader = Helper.overlayLoader(context);
    Overlay.of(context).insert(loader);
    setCurrentLocation().then((_address) async {
      deliveryAddress.value = _address;
      await refreshHome();
      loader.remove();
    });
  }

  Future<void> refreshHome() async {
    categories = <Category>[];
    topMarkets = <Market>[];
    topRests = <Market>[];
    trendingProducts = <Product>[];
    sliders = <SliderProduct>[];

    await listenForSliders();
    await listenForCategories();
    await listenForTopMarkets();
    await listenForTopRests();
  }
}
