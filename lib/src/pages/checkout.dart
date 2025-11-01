import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/i18n.dart';
import '../controllers/checkout_controller.dart';
import '../elements/CreditCardsWidget.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';

class CheckoutWidget extends StatefulWidget {
//  RouteArgument routeArgument;
//  CheckoutWidget({Key key, this.routeArgument}) : super(key: key);
  @override
  _CheckoutWidgetState createState() => _CheckoutWidgetState();
}

class _CheckoutWidgetState extends StateMVC<CheckoutWidget> {
  late CheckoutController _con;

  _CheckoutWidgetState() : super(CheckoutController()) {
    _con = controller as CheckoutController;
  }
  @override
  void initState() {
    _con.listenForCarts(withAddOrder: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).checkout,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .merge(TextStyle(letterSpacing: 1.3)),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 10),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    leading: Icon(
                      Icons.payment,
                      color: Theme.of(context).hintColor,
                    ),
                    title: Text(
                      S.of(context).payment_mode,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    subtitle: Text(
                      S.of(context).select_your_preferred_payment_mode,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                new CreditCardsWidget(
                    creditCard: _con.creditCard,
                    onChanged: (creditCard) {
                      _con.updateCreditCard(creditCard);
                    }),
                SizedBox(height: 40),
                setting.value.payPalEnabled
                    ? Text(
                        S.of(context).or_checkout_with,
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    : SizedBox(
                        height: 0,
                      ),
                SizedBox(height: 40),
                setting.value.payPalEnabled
                    ? SizedBox(
                        width: 320,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacementNamed('/PayPal');
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            backgroundColor:
                                Theme.of(context).focusColor.withOpacity(0.2),
                            shape: StadiumBorder(),
                          ),
                          child: Image.asset(
                            'assets/img/paypal2.png',
                            height: 28,
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 0,
                      ),
                SizedBox(height: 20),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              height: 230,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).focusColor.withOpacity(0.15),
                        offset: Offset(0, -2),
                        blurRadius: 5.0)
                  ]),
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            S.of(context).subtotal,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        Helper.getPrice(_con.subTotal, context,
                            style: Theme.of(context).textTheme.bodyMedium)
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '${S.of(context).tax} (${setting.value.defaultTax}%)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        Helper.getPrice(_con.taxAmount, context,
                            style: Theme.of(context).textTheme.bodyMedium)
                      ],
                    ),
                    Divider(height: 30),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            S.of(context).total,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Helper.getPrice(_con.total, context,
                            style: Theme.of(context).textTheme.titleMedium)
                      ],
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/OrderSuccess',
                              arguments: new RouteArgument(
                                  param: 'Credit Card (Stripe Gateway)'));
//                                      Navigator.of(context).pushReplacementNamed('/Checkout',
//                                          arguments:
//                                              new RouteArgument(param: [_con.carts, _con.total, setting.defaultTax]));
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          shape: StadiumBorder(),
                        ),
                        child: Text(
                          S.of(context).confirm_payment,
                          textAlign: TextAlign.start,
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
