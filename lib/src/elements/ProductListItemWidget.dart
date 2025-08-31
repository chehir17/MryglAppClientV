import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:markets/generated/i18n.dart';

import '../helpers/helper.dart';
import '../models/product.dart';
import '../models/route_argument.dart';

// ignore: must_be_immutable
class ProductListItemWidget extends StatelessWidget {
  String heroTag;
  Product product;
  final VoidCallback onPressed;

  ProductListItemWidget(
      {Key? key,
      required this.heroTag,
      required this.product,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).colorScheme.secondary,
      focusColor: Theme.of(context).colorScheme.secondary,
      highlightColor: Theme.of(context).primaryColor,
      onTap: () {
        if (product.inStock)
          Navigator.of(context).pushNamed('/Product',
              arguments: new RouteArgument(
                  heroTag: this.heroTag,
                  id: this.product.id,
                  marketID: this.product.market.id));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).focusColor.withOpacity(0.1),
                blurRadius: 5,
                offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: heroTag + product.id,
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  // color: Theme.of(context).accentColor.withOpacity(0.3),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(this.product.image.url!),
                    fit: BoxFit.fill,
                    colorFilter: !product.inStock
                        ? ColorFilter.mode(
                            Colors.black.withOpacity(0.2),
                            BlendMode.dstIn,
                          )
                        : null,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            SizedBox(width: 15),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          product.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '${product.capacity != "null" ? product.capacity : ""} ${product.unit != "null" ? product.unit : ""}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.bodySmall!.merge(
                              TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Row(
                    children: [
                      product.inStock
                          ? Column(
                              children: [
                                Helper.getPrice(product.price, context,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge!),
                                product.discountPrice > 0
                                    ? Helper.getPrice(
                                        product.discountPrice, context,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .merge(TextStyle(
                                                decoration: TextDecoration
                                                    .lineThrough)))
                                    : SizedBox(height: 0),
                              ],
                            )
                          : SizedBox(
                              height: 0,
                            ),
                      product.inStock
                          ? Container(
                              margin: EdgeInsets.all(10),
                              width: 40,
                              height: 40,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.all(0),
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.9),
                                  shape: StadiumBorder(),
                                ),
                                onPressed: () {
                                  onPressed();
                                },
                                child: Icon(
                                  Icons.shopping_cart,
                                  color: Theme.of(context).primaryColor,
                                  size: 24,
                                ),
                              ),
                            )
                          : Center(
                              child: Container(
                                  padding: EdgeInsets.all(1),
                                  // decoration: BoxDecoration(
                                  //   border: Border.all(color: Colors.red)
                                  // ),
                                  child: Text(
                                    S.of(context).out_of_stock,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red),
                                  )))
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
