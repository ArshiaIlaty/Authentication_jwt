import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nc_jwt_auth/theme/colors.dart';

class AppTheme {
  static  AppColors colors = AppColors();

  const AppTheme._();

  static ThemeData define() {
    return ThemeData(
      primaryColor: HexColor("#673AB7")
    );
  }
}