import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/category.dart';
import '../models/route_argument.dart';

// ignore: must_be_immutable
class MarketCategoriesCarouselItemWidget extends StatelessWidget {
  double marginLeft;
  Category category;
  String marketId;
  MarketCategoriesCarouselItemWidget(
      {Key key, this.marginLeft, this.category, this.marketId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).accentColor.withOpacity(0.08),
      highlightColor: Colors.transparent,
      onTap: () {
        Navigator.of(context).pushNamed('/MarketCategory',
            arguments: RouteArgument(
                id: category.id,
                marketID: this.marketId,
                category: this.category));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Hero(
            tag: category.id,
            child: Container(
              margin:
                  EdgeInsetsDirectional.only(start: this.marginLeft, end: 5),
              // width: 110,
              height: 110,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).focusColor.withOpacity(0.2),
                        offset: Offset(0, 2),
                        blurRadius: 7.0)
                  ]),
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: CachedNetworkImage(
                    imageUrl: category.image.url,
                    fit: BoxFit.fill,
                  )
                  // category.image.url.toString().split(".").contains("svg")
                  // ? SvgPicture.network(
                  //     category.image.url,
                  //     color: Theme.of(context).accentColor,
                  //   )
                  // : Image.network(category.image.url),
                  ),
            ),
          ),
          SizedBox(height: 5),
          Container(
            child: Flexible(
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.body1.merge(
                    TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          // SizedBox(height: 5),
        ],
      ),
    );
  }
}
