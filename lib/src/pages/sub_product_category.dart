import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:markets/src/repository/user_repository.dart';
import '../../generated/i18n.dart';
import '../controllers/category_controller.dart';
import '../elements/AddToCartAlertDialog.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/DrawerWidget.dart';
import '../elements/FilterWidget.dart';
import '../elements/ProductGridItemWidget.dart';
import '../elements/ProductListItemWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../models/route_argument.dart';

class SubProductCategoryWidget extends StatefulWidget {
  final RouteArgument routeArgument;

  SubProductCategoryWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _SubProductCategoryWidgetState createState() =>
      _SubProductCategoryWidgetState();
}

class _SubProductCategoryWidgetState
    extends StateMVC<SubProductCategoryWidget> {
  // TODO add layout in configuration file
  String layout = 'grid';
  ScrollController scrollController = ScrollController();

  CategoryController _con;

  _SubProductCategoryWidgetState() : super(CategoryController()) {
    _con = controller;
  }

  @override
  void initState() {
    scrollController.addListener(() {
      double maxScroll = scrollController.position.maxScrollExtent;
      double currentScroll = scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.50;

      if (maxScroll - currentScroll <= delta) {
        _con.listenForPaginateSubCatMarketProducts(
            id: widget.routeArgument.id,
            marketId: widget.routeArgument.marketID);
      }
    });
    _con.listenForCategory(
        id: widget.routeArgument.id, cat: widget.routeArgument.category);
    _con.listenForProductsByMarketSubCategory(
      id: widget.routeArgument.id,
      marketId: widget.routeArgument.marketID,
    );
    _con.listenForCart();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      drawer: DrawerWidget(),
      endDrawer: FilterWidget(onFilter: (filter) {
        Navigator.of(context).pushReplacementNamed('/Category',
            arguments: RouteArgument(id: widget.routeArgument.id));
      }),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).category,
          style: Theme.of(context)
              .textTheme
              .title
              .merge(TextStyle(letterSpacing: 0)),
        ),
        actions: <Widget>[
          _con.loadCart
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22.5, vertical: 15),
                  child: SizedBox(
                    width: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              : ShoppingCartButtonWidget(
                  iconColor: Theme.of(context).hintColor,
                  labelColor: Theme.of(context).accentColor),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _con.refreshCategory,
        child: SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 20),
              //   child: SearchBarWidget(onClickFilter: (filter) {
              //     _con.scaffoldKey.currentState.openEndDrawer();
              //   }),
              // ),
              // SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 10),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  leading: Icon(
                    Icons.category,
                    color: Theme.of(context).hintColor,
                  ),
                  title: Text(
                    _con.category?.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.display1,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          setState(() {
                            this.layout = 'list';
                          });
                        },
                        icon: Icon(
                          Icons.format_list_bulleted,
                          color: this.layout == 'list'
                              ? Theme.of(context).accentColor
                              : Theme.of(context).focusColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            this.layout = 'grid';
                          });
                        },
                        icon: Icon(
                          Icons.apps,
                          color: this.layout == 'grid'
                              ? Theme.of(context).accentColor
                              : Theme.of(context).focusColor,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              _con.products.isEmpty
                  ? CircularLoadingWidget(height: 500)
                  : Offstage(
                      offstage: this.layout != 'list',
                      child: ListView.separated(
                        scrollDirection: Axis.vertical,
                        // controller: scrollController,
                        shrinkWrap: true,
                        primary: false,
                        itemCount: _con.products.length,
                        separatorBuilder: (context, index) {
                          return SizedBox(height: 10);
                        },
                        itemBuilder: (context, index) {
                          return ProductListItemWidget(
                              heroTag: 'favorites_list',
                              product: _con.products.elementAt(index),
                              onPressed: () {
                                if (currentUser.value.apiToken == null) {
                                  Navigator.of(context).pushNamed('/Login');
                                }

                                if (_con.isAllUnique(
                                    _con.products.elementAt(index))) {
                                  _con.addToCart(
                                      _con.products.elementAt(index));
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      // return object of type Dialog
                                      return AddToCartAlertDialogWidget(
                                          oldProduct:
                                              _con.carts.elementAt(0)?.product,
                                          newProduct:
                                              _con.products.elementAt(index),
                                          onPressed: (product, {reset: true}) {
                                            return _con.addToCart(
                                                _con.products.elementAt(index),
                                                reset: true);
                                          });
                                    },
                                  );
                                }
                              });
                        },
                      ),
                    ),
              _con.products.isEmpty
                  ? CircularLoadingWidget(height: 500)
                  : Offstage(
                      offstage: this.layout != 'grid',
                      child: GridView.count(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        primary: false,
                        // controller:scrollController,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 20,
                        childAspectRatio: 1 / 1.25,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        // Create a grid with 2 columns. If you change the scrollDirection to
                        // horizontal, this produces 2 rows.
                        crossAxisCount: MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? 2
                            : 4,
                        // Generate 100 widgets that display their index in the List.
                        children: List.generate(_con.products.length, (index) {
                          return ProductGridItemWidget(
                              heroTag: 'favorites_grid',
                              product: _con.products.elementAt(index),
                              onPressed: () {
                                if (currentUser.value.apiToken == null) {
                                  Navigator.of(context).pushNamed('/Login');
                                } else if (_con.isAllUnique(
                                    _con.products.elementAt(index))) {
                                  _con.addToCart(
                                      _con.products.elementAt(index));
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      // return object of type Dialog
                                      return AddToCartAlertDialogWidget(
                                          oldProduct:
                                              _con.carts.elementAt(0)?.product,
                                          newProduct:
                                              _con.products.elementAt(index),
                                          onPressed: (product, {reset: true}) {
                                            return _con.addToCart(
                                                _con.products.elementAt(index),
                                                reset: true);
                                          });
                                    },
                                  );
                                }
                              });
                        }),
                      ),
                    ),
              _con.isLoadingMore
                  ? CircularLoadingWidget(height: 50)
                  : SizedBox(
                      height: 0,
                    )
            ],
          ),
        ),
      ),
    );
  }
}
