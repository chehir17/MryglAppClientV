import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/i18n.dart';
import '../controllers/paypal_controller.dart';
import '../models/route_argument.dart';

class PayPalPaymentWidget extends StatefulWidget {
  RouteArgument routeArgument;
  PayPalPaymentWidget({Key? key, required this.routeArgument})
      : super(key: key);
  @override
  _PayPalPaymentWidgetState createState() => _PayPalPaymentWidgetState();
}

class _PayPalPaymentWidgetState extends StateMVC<PayPalPaymentWidget> {
  late PayPalController _con;
  _PayPalPaymentWidgetState() : super(PayPalController()) {
    _con = controller as PayPalController;
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
          S.of(context).paypal_payment,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .merge(TextStyle(letterSpacing: 1.3)),
        ),
      ),
      body: Stack(
        children: <Widget>[
          // InAppWebView(
          //   initialUrl: _con.url,
          //   initialHeaders: {},
          //   initialOptions: {},
          //   onWebViewCreated: (InAppWebViewController controller) {
          //     _con.webView = controller;
          //   },
          //   onLoadStart: (InAppWebViewController controller, String url) {
          //     setState(() {
          //       _con.url = url;
          //     });
          //     if (url ==
          //         "${GlobalConfiguration().getString('base_url')}payments/paypal") {
          //       Navigator.of(context)
          //           .pushReplacementNamed('/Pages', arguments: 3);
          //     }
          //   },
          //   onProgressChanged:
          //       (InAppWebViewController controller, int progress) {
          //     setState(() {
          //       _con.progress = progress / 100;
          //     });
          //   },
          // ),
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(_con.url)),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                javaScriptEnabled: true,
              ),
            ),
            onWebViewCreated: (controller) {
              _con.webView = controller;
            },
            onLoadStart: (controller, url) {
              setState(() {
                _con.url = url.toString();
              });
              if (_con.url ==
                  "${GlobalConfiguration().getString('base_url')}payments/paypal") {
                Navigator.of(context)
                    .pushReplacementNamed('/Pages', arguments: 3);
              }
            },
            onProgressChanged: (controller, progress) {
              setState(() {
                _con.progress = progress / 100;
              });
            },
          ),
          _con.progress < 1
              ? SizedBox(
                  height: 3,
                  child: LinearProgressIndicator(
                    value: _con.progress,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.2),
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
