import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../generated/i18n.dart';
import '../helpers/helper.dart';
import '../models/product.dart';
import '../models/route_argument.dart';

class ProductItemWidget extends StatelessWidget {
  final String heroTag;
  final Product product;
  final VoidCallback onPressed;
  final bool disableImg;

  const ProductItemWidget(
      {Key? key,
      required this.product,
      required this.heroTag,
      required this.onPressed,
      this.disableImg = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).colorScheme.secondary,
      focusColor: Theme.of(context).colorScheme.secondary,
      highlightColor: Theme.of(context).colorScheme.primary,
      onTap: () {
        Navigator.of(context).pushNamed('/Product',
            arguments: RouteArgument(
                id: product.id,
                heroTag: this.heroTag,
                marketID: product.market.id));
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
            this.disableImg == false
                ? Hero(
                    tag: heroTag + product.id,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      child: CachedNetworkImage(
                        height: 60,
                        width: 60,
                        fit: BoxFit.fill,
                        imageUrl: product.image.thumb!,
                        placeholder: (context, url) => Image.asset(
                          'assets/img/loading.gif',
                          fit: BoxFit.cover,
                          height: 60,
                          width: 60,
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  )
                : SizedBox(width: 0),
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
                          '${product.capacity} ${product.unit != "null" ? product.unit : ""}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.bodySmall!.merge(
                              TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                        // Text(
                        //   '${product.packageItemsCount} ${S.current.items}',
                        //   overflow: TextOverflow.ellipsis,
                        //   maxLines: 2,
                        //   style: Theme.of(context).textTheme.bodySmall.merge(TextStyle(fontWeight: FontWeight.bold,fontSize:13)),
                        // ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Row(
                    children: [
                      Center(
                          child: Helper.getPrice(product.price, context,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge!
                                  .merge(TextStyle(fontSize: 15)))),
                      Container(
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
                      ),
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
