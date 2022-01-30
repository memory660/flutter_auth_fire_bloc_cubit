import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// constant Size
Size constantSize(BuildContext context) {
  return MediaQuery.of(context).size;
}

// text Style
TextStyle textStyle(BuildContext context, Color color) {
  return Theme.of(context).textTheme.subtitle1!.copyWith(color: color);
}

// button Style
TextStyle googleStyle(
    {BuildContext? context, required Color color, required double fontSize}) {
  return GoogleFonts.mochiyPopPOne().copyWith(
      color: color, fontSize: fontSize, fontWeight: FontWeight.normal);
}

RegExp regExp() {
  return RegExp(
      r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$");
}

// Screen page
String get screenTitle => 'Paltar magazam';
String get screenSubtitle =>
    'Soyez au courant des derniers produits en magasin et livrés...';
// Login page
String get pLoginTitle => 'Connexion';
String get pLoginSubtitle => 'Bienvenue';
// register page
String get pRegisterTitle => 'Inscription';
String get loginBackTxt => 'retour à la connexion';
// for SnackBar
String get snackBarErrorText =>
    'La plupart de ces produits sont vendus à des prix très compétitifs...';
String get snackBartitleText => 'Oops..!';
// for Password
String get passwordisEmpty => '*';
String get hintTextForPass => '';
String get labelTextForPass => 'password';
String get forgotPass => 'mot passe oublié ?';
String get register => 'inscription';
String get passwordIncorrect => 'mot passe incorrect';
// for re-Enter password
String get labelTextforReEnter => 'confirmation';
String get rePasswordisEmpty => '*';
// for Email
String get emailIncorrect => 'format email incorrect';
String get emailisEmpty => '*';
String get hintTextForEmail => '';
String get labelTextForEmail => 'email';
// for Buttons
String get loginTxt => 'se connecter';
String get registration => 'enregistrer';
//GIF
String get gif => 'assets/img/shopping.gif';
//Colors
Color get kDefaultColor => const Color(0xFF2C4162);
Color get kBackgroundColor => const Color(0xFF141F33);
Color get kTitleColor => const Color(0xFFFFFFFF);
Color get ksubtitleColor => const Color(0xFFDBDBDB);
Color get kFieldBorderColor => const Color(0xFF7091C5);
Color get kSnackBarColor => const Color(0xFF750A0A);
Color get verifyColor => const Color(0xFF278A34);

class AppRoutes {
  static const screen = '/screen';
  static const login = '/login';
  static const signUp = '/signUp';
  static const forgotPassword = '/forgotPassword';
  static const home = '/home';
}
