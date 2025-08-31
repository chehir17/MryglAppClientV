import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:markets/src/helpers/helper.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
// import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'package:another_flushbar/flushbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;

import '../../generated/i18n.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as repository;

class UserController extends ControllerMVC {
  User user = new User();
  bool hidePassword = true;
  bool _isLoggedIn = false;
  late OverlayEntry loader;
  late GlobalKey<FormState> loginFormKey;
  late GlobalKey<ScaffoldState> scaffoldKey;
  late FirebaseMessaging _firebaseMessaging;
  // static final FacebookLogin facebookSignIn = new FacebookLogin();
  late Map userProfile;

  UserController() {
    loginFormKey = new GlobalKey<FormState>();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    // _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging.getToken().then((String? _deviceToken) {
      user.deviceToken = _deviceToken;
      print(user.deviceToken);
    });
    loader = Helper.overlayLoader(scaffoldKey.currentContext);
  }

  Future<void> loginwithfb() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final userData = await FacebookAuth.instance.getUserData(
          fields: "name,email,id",
        );

        User user = User();
        user.name = userData['name'];
        user.email = userData['email'];
        user.fbID = userData['id'];
        user.fbToken = accessToken.tokenString;

        print(userData);
        registerAndLoginWithFb(user);
      } else if (result.status == LoginStatus.cancelled) {
        print('Login cancelled by the user.');
      } else {
        print('Error during Facebook login: ${result.message}');
      }
    } catch (e) {
      print('Facebook login failed: $e');
    }
  }

  Future<Null> loginwithGg(_currentUser) async {
    User _user = new User();
    _user.name = _currentUser.displayName;
    _user.email = _currentUser.email;
    registerAndLoginWithGg(_user);
  }

  void login() async {
    FocusScope.of(scaffoldKey.currentContext!).unfocus();
    if (loginFormKey.currentState!.validate()) {
      loginFormKey.currentState!.save();
      Overlay.of(scaffoldKey.currentContext!).insert(loader);
      repository.login(user).then((value) {
        //print(value.apiToken);
        if (value != null && value.apiToken != null) {
          loader.remove();
          ScaffoldMessenger.of(scaffoldKey.currentState!.context)
              .showSnackBar(SnackBar(
            content: Text(S.current.welcome + value.name!),
            behavior: SnackBarBehavior.floating,
          ));
          Navigator.of(scaffoldKey.currentContext!)
              .pushReplacementNamed('/Pages', arguments: 2);
        } else {
          loader.remove();
          // scaffoldKey.currentState.showSnackBar(SnackBar(
          //   content: Text(S.current.wrong_email_or_password),
          //   behavior: SnackBarBehavior.floating,
          // ));
          Flushbar(
            title: "Ooops !!",
            message: S.current.wrong_email_or_password,
            duration: Duration(seconds: 3),
            flushbarPosition: FlushbarPosition.TOP,
          )..show(scaffoldKey.currentState!.context);
        }
      }).catchError((e) {
        loader.remove();
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  void register() async {
    FocusScope.of(scaffoldKey.currentContext!).unfocus();
    if (loginFormKey.currentState!.validate()) {
      loginFormKey.currentState!.save();
      Overlay.of(scaffoldKey.currentContext!).insert(loader);
      repository.register(user).then((value) {
        if (value != null && value.apiToken != null) {
          loader.remove();
          ScaffoldMessenger.of(scaffoldKey.currentState!.context)
              .showSnackBar(SnackBar(
            content: Text(S.current.welcome + value.name!),
          ));
          Navigator.of(scaffoldKey.currentContext!)
              .pushReplacementNamed('/Pages', arguments: 2);
        } else {
          loader.remove();
          ScaffoldMessenger.of(scaffoldKey.currentState!.context)
              .showSnackBar(SnackBar(
            content: Text(S.current.wrong_email_or_password),
          ));
        }
      }).catchError(() {
        loader.remove();
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  void registerAndLoginWithFb(User user) async {
    FocusScope.of(scaffoldKey.currentContext!).unfocus();
    Overlay.of(scaffoldKey.currentContext!).insert(loader);
    repository.registerOrLogin(user).then((value) {
      if (value != null && value.apiToken != null) {
        loader.remove();
        ScaffoldMessenger.of(scaffoldKey.currentState!.context)
            .showSnackBar(SnackBar(
          content: Text(S.current.welcome + value.name!),
        ));
        Navigator.of(scaffoldKey.currentContext!)
            .pushReplacementNamed('/Pages', arguments: 2);
      } else {
        loader.remove();
        ScaffoldMessenger.of(scaffoldKey.currentState!.context)
            .showSnackBar(SnackBar(
          content: Text(S.current.wrong_email_or_password),
        ));
      }
    }).catchError(() {
      loader.remove();
    }).whenComplete(() {
      Helper.hideLoader(loader);
    });
  }

  void registerAndLoginWithGg(User user) async {
    FocusScope.of(scaffoldKey.currentContext!).unfocus();
    Overlay.of(scaffoldKey.currentContext!).insert(loader);
    repository.registerOrLoginWithGg(user).then((value) {
      if (value != null && value.apiToken != null) {
        loader.remove();
        ScaffoldMessenger.of(scaffoldKey.currentState!.context)
            .showSnackBar(SnackBar(
          content: Text(S.current.welcome + value.name!),
        ));
        Navigator.of(scaffoldKey.currentContext!)
            .pushReplacementNamed('/Pages', arguments: 2);
      } else {
        loader.remove();
        ScaffoldMessenger.of(scaffoldKey.currentState!.context)
            .showSnackBar(SnackBar(
          content: Text(S.current.wrong_email_or_password),
        ));
      }
    }).catchError(() {
      loader.remove();
    }).whenComplete(() {
      Helper.hideLoader(loader);
    });
  }

  void resetPassword() {
    if (loginFormKey.currentState!.validate()) {
      loginFormKey.currentState!.save();
      repository.resetPassword(user).then((value) {
        if (value != null && value == true) {
          ScaffoldMessenger.of(scaffoldKey.currentState!.context)
              .showSnackBar(SnackBar(
            content:
                Text(S.current.your_reset_link_has_been_sent_to_your_email),
            action: SnackBarAction(
              label: S.current.login,
              onPressed: () {
                Navigator.of(scaffoldKey.currentContext!)
                    .pushReplacementNamed('/Login');
              },
            ),
            duration: Duration(seconds: 10),
          ));
        } else {
          ScaffoldMessenger.of(scaffoldKey.currentState!.context)
              .showSnackBar(SnackBar(
            content: Text(S.current.error_verify_email_settings),
          ));
        }
      });
    }
  }
}
