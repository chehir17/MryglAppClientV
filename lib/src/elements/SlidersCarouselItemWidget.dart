import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

import '../models/slider.dart';
import '../models/route_argument.dart';
import '../elements/CircularLoadingWidget.dart';

// ignore: must_be_immutable
class SlidersCarouselItemWidget extends StatefulWidget {
  double marginLeft;
  // SliderProduct slider;
  List<SliderProduct> slider;
  SlidersCarouselItemWidget(
      {Key? key, required this.marginLeft, required this.slider})
      : super(key: key);

  @override
  _SlidersCarouselItemWidgetState createState() =>
      _SlidersCarouselItemWidgetState();
}

class _SlidersCarouselItemWidgetState extends State<SlidersCarouselItemWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.slider.isEmpty
        ? CircularLoadingWidget(height: 200)
        : InkWell(
            splashColor:
                Theme.of(context).colorScheme.secondary.withOpacity(0.08),
            highlightColor: Colors.transparent,
            onTap: () {
              // Navigator.of(context).pushNamed('/Product', arguments: RouteArgument(id: product.id));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Container(
                child: GFCarousel(
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 5),
                  hasPagination: true,
                  items: this.widget.slider.map(
                    (item) {
                      return InkWell(
                        onTap: () {
                          if (item.productID != '0' &&
                              item.productID != "null" &&
                              item.productID != null)
                            Navigator.of(context).pushNamed(
                              '/Product',
                              arguments: RouteArgument(
                                id: item.productID,
                              ),
                            );
                          else if (item.categoryID != '0' &&
                              item.categoryID != "null" &&
                              item.categoryID != null)
                            Navigator.of(context).pushNamed(
                              '/Category',
                              arguments: RouteArgument(
                                id: item.categoryID,
                                category: item.category,
                              ),
                            );
                          else if (item.storeID != '0' &&
                              item.storeID != "null" &&
                              item.storeID != null)
                            //Navigator.of(context).pushNamed('/Details', arguments: RouteArgument(id:item.storeID, heroTag: 'home_top_markets'));
                            Navigator.of(context).pushNamed(
                              '/Details',
                              arguments: RouteArgument(
                                id: item.storeID,
                                heroTag: 'home_top_markets',
                              ),
                            );
                        },
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                            child: CachedNetworkImage(
                              fit: BoxFit.fill,
                              width: 1000.0,
                              imageUrl: item.image!.url!,
                            ),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                  onPageChanged: (index) {
                    // setState(() {});
                  },
                ),
              ),
            ),
          );
  }
}
