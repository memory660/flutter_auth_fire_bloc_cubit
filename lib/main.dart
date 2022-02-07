import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_project4/database/user_database.dart';
import 'package:flutter_project4/models/google_maps_model.dart';
import 'package:provider/provider.dart';
import 'cubit/auth_cubit.dart';
import 'screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  UserDatabase userDatabase = UserDatabase();
  userDatabase.initialize();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
        ChangeNotifierProvider<GoogleMapsModel>(
            create: (context) => GoogleMapsModel()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
      ),
    );
  }
}
