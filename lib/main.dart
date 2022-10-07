import 'package:flutter/material.dart';
import 'package:nc_jwt_auth/register.dart';

import 'login.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'test ',
      initialRoute: LoginPage.routeName,
      routes: {
        LoginPage.routeName: (context) => LoginPage(),
        RegisterPage.routeName: (context) => RegisterPage(),
      },
    ));
