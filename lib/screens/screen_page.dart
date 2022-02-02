import 'package:flutter/material.dart';
import '../constant/constant.dart';
import '../ui/animation_button.dart';
import '../ui/myclipper.dart';
import 'login_screen.dart';
import 'sign_up_screen.dart';

class ScreenPage extends StatefulWidget {
  const ScreenPage({Key? key}) : super(key: key);

  @override
  _ScreenPageState createState() => _ScreenPageState();
}

class _ScreenPageState extends State<ScreenPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipPath(
              clipper: MyClipper(),
              child: Container(
                width: constantSize(context).width,
                height: constantSize(context).height * .55,
                color: kDefaultColor,
                alignment: const Alignment(-.9, 0),
                child: Image.asset(gif),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              screenTitle,
              style: googleStyle(color: kTitleColor, fontSize: 25),
            ),
            const SizedBox(height: 10),
            Text(
              screenSubtitle,
              style: googleStyle(color: ksubtitleColor, fontSize: 15),
            ),
            const SizedBox(height: 20),
            AnimePressButton(
                borderRadius: BorderRadius.circular(100),
                onTap: () {
                  Navigator.push(
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
                  );
                },
                title: Text(
                  loginTxt,
                  style: googleStyle(color: kTitleColor, fontSize: 22),
                ),
                titleColor: kTitleColor,
                width: constantSize(context).width * .9),
            const SizedBox(height: 20),
            AnimePressButton(
              borderRadius: BorderRadius.circular(100),
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    opaque: true,
                    pageBuilder: (BuildContext context, _, __) {
                      return const SignUp();
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
                );
              },
              title: Text(
                registration,
                style: googleStyle(color: kTitleColor, fontSize: 22),
              ),
              titleColor: kTitleColor,
              width: constantSize(context).width * .9,
            ),
          ],
        ),
      ),
    );
  }
}
