import 'package:flutter/material.dart';

import '../../generated/i18n.dart';
import '../elements/SearchWidget.dart';

class SearchBarWidget extends StatelessWidget {
  final ValueChanged? onClickFilter;
  final Widget? getLocation;

  const SearchBarWidget({Key? key, this.onClickFilter, this.getLocation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(SearchModal());
      },
      child: Container(
        padding: this.getLocation != null
            ? EdgeInsets.only(left: 5, right: 5)
            : EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
              color: Theme.of(context).focusColor.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(4)),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 12, left: 0),
              child: Icon(Icons.search,
                  color: Theme.of(context).colorScheme.secondary),
            ),
            Expanded(
              child: Text(
                S.of(context).search_for_markets_or_products,
                maxLines: 1,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .merge(TextStyle(fontSize: 14)),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(right: 5, left: 5, top: 3, bottom: 3),
              child: getLocation,
            )
            // InkWell(
            //   onTap: () {
            //     onClickFilter('e');
            //   },
            //   child: Padding(
            //     padding: const EdgeInsets.only(right: 5, left: 5, top: 3, bottom: 3),
            //     child: Icon(Icons.filter_list, color: Theme.of(context).accentColor),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
