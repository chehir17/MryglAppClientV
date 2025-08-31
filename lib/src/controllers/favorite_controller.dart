import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/i18n.dart';
import '../models/favorite.dart';
import '../repository/product_repository.dart';

class FavoriteController extends ControllerMVC {
  late List<Favorite> favorites = <Favorite>[];
  late GlobalKey<ScaffoldState> scaffoldKey;

  FavoriteController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    listenForFavorites();
  }

  void listenForFavorites({String? message}) async {
    final Stream<Favorite> stream = await getFavorites();
    stream.listen((Favorite _favorite) {
      setState(() {
        favorites.add(_favorite);
      });
    }, onError: (a) {
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
    });
  }

  Future<void> refreshFavorites() async {
    favorites.clear();
    listenForFavorites(message: 'Favorites refreshed successfuly');
  }

  void removeFromFavorite(Favorite _favorite) async {
    removeFavorite(_favorite).then((value) {
      ScaffoldMessenger.of(scaffoldKey.currentState!.context)
          .showSnackBar(SnackBar(
        content: Text('This product was removed from favorites'),
      ));
    }).whenComplete(() {
      favorites.clear();
      setState(() {});
      listenForFavorites();
    });
  }
}
