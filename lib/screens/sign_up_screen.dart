import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ndialog/ndialog.dart';

import '../constant/constant.dart';
import '../cubit/auth_cubit.dart';
import '../ui/animation_button.dart';
import '../ui/myclipper.dart';
import 'login_screen.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _parolController = TextEditingController();
  final _reParolController = TextEditingController();

  late FocusNode password;
  late FocusNode rePassword;

  bool isVisible = false;

  bool confirmPass = false;

  @override
  void initState() {
    super.initState();
    password = FocusNode();
    rePassword = FocusNode();
  }

  @override
  void dispose() {
    password.dispose();
    rePassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kBackgroundColor,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) async {
          if (state is AuthSignUpSuccess) {
            await _zoomDialog(context).show(context);
            await Future.delayed(const Duration(seconds: 1)).then(
              (value) => Navigator.pushAndRemoveUntil(
                  context,
                  PageRouteBuilder(
                    opaque: true,
                    pageBuilder: (BuildContext context, _, __) {
                      return const LoginPage();
                    },
                    transitionDuration: const Duration(milliseconds: 700),
                    reverseTransitionDuration:
                        const Duration(milliseconds: 700),
                    transitionsBuilder:
                        (context, animation, anotherAnimation, child) {
                      animation = CurvedAnimation(
                          curve: Curves.linear, parent: animation);
                      return Align(
                        child: SlideTransition(
                          position: Tween(
                                  begin: const Offset(1.0, 0.0),
                                  end: const Offset(0.0, 0.0))
                              .animate(animation),
                          child: child,
                        ),
                      );
                    },
                  ),
                  (route) => false),
            );
          }
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
                  height: constantSize(context).height * .9,
                  color: const Color(0x00CBD7E9),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          registerPageTitle(),
                          const SizedBox(height: 30),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                emailFormField(context),
                                const SizedBox(height: 20),
                                passwordFormField(context),
                                const SizedBox(height: 20),
                                reEnterPasswordFormField(context),
                              ],
                            ),
                          ),
                          Align(
                            heightFactor: 2.0,
                            alignment: const Alignment(.95, 0),
                            child: loginButton(),
                          )
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
                child: registerButton(context),
              )
            ],
          );
        },
      ),
    );
  }

  ZoomDialog _zoomDialog(BuildContext context) {
    return ZoomDialog(
      blur: 3,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.topCenter,
        children: [
          Container(
            width: constantSize(context).width * .6,
            height: constantSize(context).height * .2,
            decoration: BoxDecoration(
              color: kTitleColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Vous êtes inscrit 🥳",
              softWrap: true,
              style: TextStyle(fontSize: 18),
            ),
            alignment: Alignment.center,
          ),
          Positioned(
            top: -constantSize(context).width * .05,
            child: Container(
              height: constantSize(context).width * .15,
              width: constantSize(context).width * .15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kTitleColor,
                image: const DecorationImage(
                  image: AssetImage('assets/img/verify.png'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Text registerPageTitle() {
    return Text(
      pRegisterTitle,
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
          color: kDefaultColor),
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
        hintText: hintTextForEmail,
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
      textInputAction: TextInputAction.next,
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
        hintText: hintTextForPass,
        hintStyle: textStyle(context, kTitleColor),
        labelStyle: textStyle(context, ksubtitleColor),
      ),
      style: textStyle(context, kTitleColor),
      keyboardType: TextInputType.text,
      obscureText: true,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (password) {
        if (password!.isEmpty) {
          return passwordisEmpty;
        } else if (password.length < 8) {
          return passwordIncorrect;
        }
        return null;
      },
    );
  }

  TextFormField reEnterPasswordFormField(BuildContext context) {
    return TextFormField(
      focusNode: rePassword,
      controller: _reParolController,
      decoration: InputDecoration(
        label: Text(labelTextforReEnter),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: kFieldBorderColor, width: 2),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: kFieldBorderColor, width: 2),
        ),
        hintText: hintTextForPass,
        hintStyle: textStyle(context, kTitleColor),
        labelStyle: textStyle(context, ksubtitleColor),
      ),
      style: textStyle(context, kTitleColor),
      keyboardType: TextInputType.text,
      obscureText: true,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (rePassword) {
        confirmPass = _parolController.text != _reParolController.text;
        if (rePassword!.isEmpty) {
          return rePasswordisEmpty;
        } else if (rePassword.length < 8) {
          return passwordIncorrect;
        } else if (confirmPass) {
          return 'Les mots de passe ne correspondent pas';
        }
        return null;
      },
    );
  }

  AnimePressButton registerButton(BuildContext context) {
    return AnimePressButton(
      borderRadius: BorderRadius.circular(100),
      onTap: () async {
        if (_formKey.currentState!.validate()) {
          final authCubit = BlocProvider.of<AuthCubit>(context);
          await authCubit.signUp(
              _emailController.text.trim(), _parolController.value.text);
        }
      },
      title: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthSignUpLoading) {
            return SpinKitCircle(color: kTitleColor);
          } else {
            return Text(
              register,
              style: googleStyle(color: kTitleColor, fontSize: 18),
            );
          }
        },
      ),
      titleColor: kTitleColor,
      width: constantSize(context).width * .9,
    );
  }

  TextButton loginButton() {
    return TextButton(
      onPressed: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const LoginPage()));
      },
      child: Text(loginBackTxt),
      style: TextButton.styleFrom(
          textStyle: googleStyle(color: kFieldBorderColor, fontSize: 13)),
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
