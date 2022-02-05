import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project4/screens/list_screen.dart';
import 'package:flutter_project4/screens/map_sample2_screen.dart';
import 'package:flutter_project4/screens/map_sample_screen.dart';
import 'package:flutter_project4/screens/sign_up_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../constant/constant.dart';
import '../cubit/auth_cubit.dart';
import '../ui/animation_button.dart';
import '../ui/myclipper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  // TextEditingController : Un contrôleur pour un champ de texte modifiable.
  final _emailController = TextEditingController(
    text: 'poub440@gmail.com',
  );
  final _parolController = TextEditingController(text: '22222222');

  // Un objet qui peut être utilisé par un widget à état pour obtenir le focus sur le clavier et pour gérer les événements clavier.
  late FocusNode password;
  bool isVisible = false;
  User? user;

  @override
  void initState() {
    super.initState();
    password = FocusNode();
  }

  @override
  void dispose() {
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            PopupMenuButton(
                // add icon, by default "3 dot" icon
                // icon: Icon(Icons.book)
                itemBuilder: (context) {
              return [
                PopupMenuItem<int>(
                  value: 0,
                  child: Text("carte 1"),
                ),
                PopupMenuItem<int>(
                  value: 1,
                  child: Text("carte 2"),
                ),
              ];
            }, onSelected: (value) {
              if (value == 0) {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => MapSampleScreen()));
              } else if (value == 1) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MapSample2Screen()));
              } else if (value == 2) {
                print("Logout menu is selected.");
              }
            }),
          ],
        ),
        backgroundColor: kBackgroundColor,
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) async {
            if (state is AuthLoginError) {
              await flushbar(context).show(context);
            }
            if (state is AuthLoginSuccess) {
              // Pousse la route donnée sur le navigateur, puis supprime toutes les routes précédentes jusqu'à ce que le prédicat renvoie vrai.
              await Navigator.of(context)
                  .pushAndRemoveUntil(_pageRouteBuilder(), (route) => false);
            }

            return;
          },
          builder: (context, state) {
            return Stack(
              children: [
                Positioned(
                  top: 0,
                  child: clipPath(context),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: constantSize(context).width,
                    height: constantSize(context).height * .8,
                    color: const Color(0x00CBD7E9),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            loginPageTitle(),
                            const SizedBox(height: 20),
                            loginPageSubtitle(),
                            const SizedBox(height: 60),
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  emailFormField(context),
                                  const SizedBox(height: 20),
                                  passwordFormField(context),
                                  Align(
                                    heightFactor: 2.0,
                                    alignment: const Alignment(.95, 0),
                                    child: forgotPassword(),
                                  ),
                                  Align(
                                    heightFactor: 2.0,
                                    alignment: const Alignment(.95, 0),
                                    child: inscription(),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 15,
                  right: 15,
                  bottom: 20,
                  child: loginButton(context),
                )
              ],
            );
          },
        ));
  }

  PageRouteBuilder<dynamic> _pageRouteBuilder() {
    return PageRouteBuilder(
      opaque: true,
      pageBuilder: (BuildContext context, _, __) {
        return const ListScreen();
      },
      transitionDuration: const Duration(milliseconds: 700),
      reverseTransitionDuration: const Duration(milliseconds: 700),
      transitionsBuilder: (context, animation, anotherAnimation, child) {
        animation = CurvedAnimation(curve: Curves.linear, parent: animation);
        return _pageRouteBuilderAnimation(animation, child);
      },
    );
  }

  Align _pageRouteBuilderAnimation(Animation<double> animation, Widget child) {
    return Align(
      child: SlideTransition(
        position: Tween(
          begin: const Offset(1.0, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(animation),
        child: child,
      ),
    );
  }

  Text loginPageTitle() {
    return Text(
      pLoginTitle,
      style: googleStyle(color: Colors.yellow, fontSize: 20),
    );
  }

  Text loginPageSubtitle() {
    return Text(
      pLoginSubtitle,
      style: googleStyle(color: Colors.orange, fontSize: 30),
    );
  }

  ClipPath clipPath(BuildContext context) {
    return ClipPath(
      clipper: MyClipper(),
      child: Container(
        width: constantSize(context).width,
        height: constantSize(context).height * .55,
        color: kDefaultColor,
      ),
    );
  }

  TextFormField emailFormField(BuildContext context) {
    return TextFormField(
      textInputAction: TextInputAction.next,
      controller: _emailController,
      decoration: InputDecoration(
        label: Text(labelTextForEmail),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: kFieldBorderColor, width: 2),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: kFieldBorderColor, width: 2),
        ),
        hintStyle: textStyle(context, kTitleColor),
        labelStyle: textStyle(context, ksubtitleColor),
      ),
      style: textStyle(context, kTitleColor),
      keyboardType: TextInputType.emailAddress,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (email) {
        if (email!.isEmpty) {
          return emailisEmpty;
        } else if (!regExp().hasMatch(email)) {
          return emailIncorrect;
        }
      },
    );
  }

  TextFormField passwordFormField(BuildContext context) {
    return TextFormField(
      focusNode: password,
      controller: _parolController,
      decoration: InputDecoration(
        label: Text(labelTextForPass),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: kFieldBorderColor, width: 2),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: kFieldBorderColor, width: 2),
        ),
        hintStyle: textStyle(context, kTitleColor),
        labelStyle: textStyle(context, ksubtitleColor),
        suffixIcon: GestureDetector(
          onTap: onTap,
          child: isVisible
              ? Icon(Icons.visibility, color: kTitleColor)
              : Icon(Icons.visibility_off, color: ksubtitleColor),
        ),
      ),
      style: textStyle(context, kTitleColor),
      keyboardType: TextInputType.text,
      obscureText: isVisible ? false : true,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (password) {
        if (password!.isEmpty) {
          return passwordisEmpty;
        } else if (password.length < 8) {
          return passwordIncorrect;
        }
      },
    );
  }

  TextButton forgotPassword() {
    return TextButton(
      onPressed: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => forgotPassword()));
      },
      child: Text(forgotPass),
      style: TextButton.styleFrom(
          textStyle: googleStyle(color: kFieldBorderColor, fontSize: 13)),
    );
  }

  TextButton inscription() {
    return TextButton(
      onPressed: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const SignUp()));
      },
      child: Text(register),
      style: TextButton.styleFrom(
          textStyle: googleStyle(color: kFieldBorderColor, fontSize: 13)),
    );
  }

  AnimePressButton loginButton(BuildContext context) {
    return AnimePressButton(
      borderRadius: BorderRadius.circular(100),
      onTap: () async {
        if (_formKey.currentState!.validate()) {
          user = await BlocProvider.of<AuthCubit>(context).login(
              _emailController.text.trim(), _parolController.text.trim());
        } else {
          return;
        }
      },
      title: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLoginLoading) {
            return SpinKitCircle(color: kTitleColor);
          } else {
            return Text(
              loginTxt,
              style: googleStyle(color: kTitleColor, fontSize: 18),
            );
          }
        },
      ),
      titleColor: kTitleColor,
      width: constantSize(context).width * .9,
    );
  }

  Flushbar<dynamic> flushbar(BuildContext context) {
    return Flushbar(
      borderRadius: BorderRadius.circular(15),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.bounceIn,
      backgroundColor: kSnackBarColor,
      isDismissible: true,
      duration: const Duration(seconds: 4),
      icon: Icon(Icons.info, color: ksubtitleColor),
      titleText: Text(
        snackBartitleText,
        style: googleStyle(color: kTitleColor, fontSize: 18),
      ),
      messageText:
          Text(snackBarErrorText, style: textStyle(context, kTitleColor)),
    );
  }

  void onTap() {
    setState(() {
      isVisible = !isVisible;
    });
  }
}
