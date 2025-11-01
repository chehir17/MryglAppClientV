import 'package:flutter/material.dart';

import '../../generated/i18n.dart';
import '../elements/BlockButtonWidget.dart';
import '../helpers/app_config.dart' as config;

class MobileVerification2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _ac = config.App(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: _ac.appWidth(100),
              child: Column(
                children: <Widget>[
                  Text(
                    'Verify Your Account',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'We are sending OTP to validate your mobile number. Hang on!',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
            TextField(
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
              decoration: new InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).focusColor.withOpacity(0.2)),
                ),
                focusedBorder: new UnderlineInputBorder(
                  borderSide: new BorderSide(
                    color: Theme.of(context).focusColor.withOpacity(0.5),
                  ),
                ),
                hintText: '000-000',
              ),
            ),
            SizedBox(height: 15),
            Text(
              'SMS has been sent to +155 4585 555',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 80),
            new BlockButtonWidget(
              onPressed: () {
                Navigator.of(context)
                    .pushReplacementNamed('/Pages', arguments: 2);
              },
              color: Theme.of(context).colorScheme.secondary,
              text: Text(S.of(context).verify.toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .merge(TextStyle(color: Theme.of(context).primaryColor))),
            ),
          ],
        ),
      ),
    );
  }
}
