import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../elements/DrawerWidget.dart';
import '../elements/FilterWidget.dart';
import '../models/route_argument.dart';
import '../pages/favorites.dart';
import '../pages/home.dart';
import '../pages/map.dart';
import '../pages/notifications.dart';
import '../pages/orders.dart';
import 'package:flutter/services.dart';
import '../../generated/i18n.dart';
import 'messages.dart';

class PagesWidget extends StatefulWidget {
  dynamic currentTab;
  late RouteArgument routeArgument;
  late String version;
  Widget currentPage = HomeWidget();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  PagesWidget({
    Key? key,
    this.currentTab,
  }) {
    if (currentTab != null) {
      if (currentTab is RouteArgument) {
        routeArgument = currentTab;
        currentTab = int.parse(currentTab.id);
      }
    } else {
      currentTab = 2;
    }
  }

  @override
  _PagesWidgetState createState() {
    return _PagesWidgetState();
  }
}

class _PagesWidgetState extends State<PagesWidget> {
  String? version;

  initState() {
    super.initState();
    _selectTab(widget.currentTab);
    // print('eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee');
    // checkAppVersion();
  }

  // Future<void> checkAppVersion() async {
  //   PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //   version = packageInfo.version;
  //   showDialog(
  //     context: widget.scaffoldKey.currentContext,
  //     builder: (context) => new AlertDialog(
  //       titleMedium: new Text('Update'),
  //       content: new Text('update'),
  //       actions: <Widget>[
  //         new FlatButton(
  //           onPressed: () => Navigator.of(context).pop(false),
  //           child: new Text(S.current.no),
  //         ),
  //         new FlatButton(
  //           onPressed: () async {
  //             const url = 'https://play.google.com/store/apps/details?id=com.mriguel.markets';
  //             if (await canLaunch(url)) {
  //               await launch(url);
  //             } else {
  //               throw 'Could not launch $url';
  //             }
  //           },
  //           child: new Text(S.current.yes),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  void didUpdateWidget(PagesWidget oldWidget) {
    _selectTab(oldWidget.currentTab);
    super.didUpdateWidget(oldWidget);
  }

  void _selectTab(int tabItem) {
    setState(() {
      widget.currentTab = tabItem;
      switch (tabItem) {
        case 0:
          widget.currentPage =
              NotificationsWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
        case 1:
          widget.currentPage = MapWidget(
              parentScaffoldKey: widget.scaffoldKey,
              routeArgument: widget.routeArgument);
          break;
        case 2:
          widget.currentPage =
              HomeWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
        case 3:
          widget.currentPage =
              OrdersWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
        case 4:
          // widget.currentPage = MessagesWidget(
          //     parentScaffoldKey: widget
          //         .scaffoldKey);
          widget.currentPage =
              FavoritesWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
      }
    });
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text(S.current.are_you_sure),
            content: new Text(S.current.do_you_want_to_exit_an_app),
            actions: <Widget>[
              new ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text(S.current.no),
              ),
              new ElevatedButton(
                onPressed: () => SystemNavigator.pop(),
                child: new Text(S.current.yes),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: widget.scaffoldKey,
        drawer: DrawerWidget(),
        endDrawer: FilterWidget(onFilter: (filter) {
          Navigator.of(context)
              .pushReplacementNamed('/Pages', arguments: widget.currentTab);
        }),
        body: widget.currentPage,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.secondary,
          selectedFontSize: 0,
          unselectedFontSize: 0,
          iconSize: 22,
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedIconTheme: IconThemeData(size: 28),
          unselectedItemColor: Theme.of(context).focusColor.withOpacity(1),
          currentIndex: widget.currentTab,
          onTap: (int i) {
            this._selectTab(i);
          },
          // this will be set when a new tab is tapped
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                // title: new Container(height: 0.0),
                label: ""),
            BottomNavigationBarItem(
                icon: Icon(Icons.location_on),
                // titleMedium: new Container(height: 0.0),
                label: ""),
            BottomNavigationBarItem(
                label: "",
                icon: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.all(
                      Radius.circular(50),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.4),
                          blurRadius: 40,
                          offset: Offset(0, 15)),
                      BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.4),
                          blurRadius: 13,
                          offset: Offset(0, 3))
                    ],
                  ),
                  child: new Icon(Icons.home,
                      color: Theme.of(context).primaryColor),
                )),
            BottomNavigationBarItem(
                icon: new Icon(Icons.local_mall),
                // titleMedium: new Container(height: 0.0),
                label: ""),
            BottomNavigationBarItem(
                icon: new Icon(Icons.favorite),
                // titleMedium: new Container(height: 0.0),
                label: ""),
          ],
        ),
      ),
    );
  }
}
