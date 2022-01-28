import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import 'screen_page.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late User currentUser;
  @override
  void initState() {
    currentUser = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLogout) {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ScreenPage()));
        }
      },
      child: MaterialButton(
          color: Colors.red,
          onPressed: () {
            BlocProvider.of<AuthCubit>(context).logout();
          },
          child: const Text('button')),
    )));
  }
}
