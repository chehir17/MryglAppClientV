import 'package:flutter/material.dart';
import 'package:markets/src/elements/UpdateButtonWidget.dart';
import 'package:markets/src/helpers/helper.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../generated/i18n.dart';
import '../controllers/home_controller.dart';
import '../elements/CardsCarouselWidget.dart';
import '../elements/CaregoriesCarouselWidget.dart';
import '../elements/SlidersCarouselItemWidget.dart';
import '../elements/DeliveryAddressBottomSheetWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../repository/settings_repository.dart' as settingsRepo;
import '../repository/user_repository.dart';

class HomeWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  HomeWidget({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends StateMVC<HomeWidget> {
  HomeController _con;
  DateTime backButtonPressTime;
  static const snackBarDuration = Duration(seconds: 3);
  _HomeWidgetState() : super(HomeController()) {
    _con = controller;
    // requestPermission();
    // _con.checkAppVersion();
  }

  @override
  void initState() {
    // TODO: implement initState
    // _con.scaffoldKey = widget.parentScaffoldKey;
    // _con.isAlertboxOpened = false;
    super.initState();
    Future.delayed(Duration.zero, () {
      _con.checkAppVersion(context);
      // _con.goToGoogleReviews(context);
    });
  }

  // void requestPermission() async {
  //   PermissionStatus permission = await LocationPermissions().requestPermissions();
  // }
  final snackBar = SnackBar(
    content: Text('Press back again to leave'),
    duration: snackBarDuration,
  );

  @override
  Widget build(BuildContext context) {
    // _con.checkAppVersion();
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize:
              settingsRepo.deliveryAddress.value?.address != 'Unknown'
                  ? Size.fromHeight(40.0)
                  : Size.fromHeight(10.0),
          child: (settingsRepo.deliveryAddress.value?.address != 'Unknown' &&
                  !['null', null, '']
                      .contains(settingsRepo.deliveryAddress.value?.address))
              ? Column(
                  children: [
                    Text(S.current.delivery_address),
                    Text(
                      (settingsRepo.deliveryAddress.value?.title[0] ??
                          '' +
                              ',' +
                              settingsRepo.deliveryAddress.value?.title[1] ??
                          ''),
                      style: Theme.of(context).textTheme.caption.merge(
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                )
              : Text(''),
        ),
        leading: new IconButton(
          icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
          onPressed: () => widget.parentScaffoldKey.currentState.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Image.asset('assets/img/title.png', height: 35),
        // title: ValueListenableBuilder(
        //   valueListenable: settingsRepo.setting,
        //   builder: (context, value, child) {
        //     return Text(
        //       value.appName ?? S.of(context).home,
        //       style: Theme.of(context).textTheme.title.merge(TextStyle(letterSpacing: 1.3,fontFamily: 'AnnaCtt',fontSize: 25)),
        //     );
        //   },
        // ),
//        title: Text(
//          settingsRepo.setting?.value.appName ?? S.of(context).home,
//          style: Theme.of(context).textTheme.title.merge(TextStyle(letterSpacing: 1.3)),
//        ),
        actions: <Widget>[
          // _con.version != settingsRepo.setting.value.appVersion ? UpdateButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).accentColor) : SizedBox(height: 0,),
          new ShoppingCartButtonWidget(
              iconColor: Theme.of(context).hintColor,
              labelColor: Theme.of(context).accentColor),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _con.refreshHome,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SearchBarWidget(
                  getLocation: IconButton(
                    onPressed: () {
                      if (currentUser.value.apiToken == null) {
                        _con.requestForCurrentLocation(context);
                      } else {
                        Helper.locationPermission();
                        var bottomSheetController = widget
                            .parentScaffoldKey.currentState
                            .showBottomSheet(
                          (context) => DeliveryAddressBottomSheetWidget(
                              scaffoldKey: widget.parentScaffoldKey),
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10)),
                          ),
                        );
                        bottomSheetController.closed.then((value) {
                          _con.refreshHome();
                        });
                      }
                    },
                    icon: Icon(
                      Icons.my_location,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  onClickFilter: (event) {
                    widget.parentScaffoldKey.currentState.openEndDrawer();
                  },
                ),
              ),
              _con.sliders.length > 0
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                        leading: Icon(
                          Icons.local_offer,
                          color: Theme.of(context).hintColor,
                        ),
                        title: Text(
                          S.of(context).best_offers,
                          style: Theme.of(context).textTheme.display1,
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              _con.sliders.length > 0
                  ? SlidersCarouselItemWidget(slider: _con.sliders)
                  : SizedBox(
                      height: 0,
                    ),
              _con.topRests.length > 0
                  ? Padding(
                      padding:
                          const EdgeInsets.only(top: 5, left: 20, right: 20),
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                        leading: Icon(
                          Icons.stars,
                          color: Theme.of(context).hintColor,
                        ),
                        title: Text(
                          S.of(context).best_restaurants,
                          style: Theme.of(context).textTheme.display1,
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              CardsCarouselWidget(
                  marketsList: _con.topRests, heroTag: 'home_top_markets'),
              _con.topMarkets.length > 0
                  ? Padding(
                      padding:
                          const EdgeInsets.only(top: 5, left: 20, right: 20),
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                        leading: Icon(
                          Icons.stars,
                          color: Theme.of(context).hintColor,
                        ),
                        // trailing: IconButton(
                        //   onPressed: () {
                        //     if (currentUser.value.apiToken == null) {
                        //       _con.requestForCurrentLocation(context);
                        //     } else {
                        //       var bottomSheetController = widget.parentScaffoldKey.currentState.showBottomSheet(
                        //         (context) => DeliveryAddressBottomSheetWidget(scaffoldKey: widget.parentScaffoldKey),
                        //         shape: RoundedRectangleBorder(
                        //           borderRadius: new BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                        //         ),
                        //       );
                        //       bottomSheetController.closed.then((value) {
                        //         _con.refreshHome();
                        //       });
                        //     }
                        //   },
                        //   icon: Icon(
                        //     Icons.my_location,
                        //     color: Theme.of(context).hintColor,
                        //   ),
                        // ),
                        title: Text(
                          S.of(context).top_markets,
                          style: Theme.of(context).textTheme.display1,
                        ),
                        // subtitle: Text(
                        //   settingsRepo.deliveryAddress.value?.address != null
                        //       ? S.of(context).near_to + " " + (settingsRepo.deliveryAddress.value?.address ?? '')
                        //       : S.of(context).near_to_your_current_location,
                        //   style: Theme.of(context).textTheme.caption,
                        // ),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              CardsCarouselWidget(
                  marketsList: _con.topMarkets, heroTag: 'home_top_markets'),

              // ListTile(
              //   dense: true,
              //   contentPadding: EdgeInsets.symmetric(horizontal: 20),
              //   leading: Icon(
              //     Icons.trending_up,
              //     color: Theme.of(context).hintColor,
              //   ),
              //   title: Text(
              //     S.of(context).trending_this_week,
              //     style: Theme.of(context).textTheme.display1,
              //   ),
              //   subtitle: Text(
              //     S.of(context).double_click_on_the_product_to_add_it_to_the,
              //     style: Theme.of(context).textTheme.caption.merge(TextStyle(fontSize: 11)),
              //   ),
              // ),
              // ProductsCarouselWidget(productsList: _con.trendingProducts, heroTag: 'home_product_carousel'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  leading: Icon(
                    Icons.category,
                    color: Theme.of(context).hintColor,
                  ),
                  title: Text(
                    S.of(context).product_categories,
                    style: Theme.of(context).textTheme.display1,
                  ),
                ),
              ),
              CategoriesCarouselWidget(
                categories: _con.categories,
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 20),
              //   child: ListTile(
              //     dense: true,
              //     contentPadding: EdgeInsets.symmetric(vertical: 0),
              //     leading: Icon(
              //       Icons.trending_up,
              //       color: Theme.of(context).hintColor,
              //     ),
              //     title: Text(
              //       S.of(context).most_popular,
              //       style: Theme.of(context).textTheme.display1,
              //     ),
              //   ),
              // ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 20),
              //   child: GridWidget(
              //     marketsList: _con.topMarkets,
              //     heroTag: 'home_markets',
              //   ),
              // ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 20),
              //   child: ListTile(
              //     dense: true,
              //     contentPadding: EdgeInsets.symmetric(vertical: 20),
              //     leading: Icon(
              //       Icons.recent_actors,
              //       color: Theme.of(context).hintColor,
              //     ),
              //     title: Text(
              //       S.of(context).recent_reviews,
              //       style: Theme.of(context).textTheme.display1,
              //     ),
              //   ),
              // ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 20),
              //   child: ReviewsListWidget(reviewsList: _con.recentReviews),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
