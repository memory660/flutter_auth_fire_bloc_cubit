import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project4/database/user_database.dart';
import 'package:flutter_project4/screens/edit_screen.dart';
import 'package:flutter_project4/screens/widgets/common.dart';
import 'package:image_network/image_network.dart';
import 'package:flutter_project4/dto/user_dto.dart';
import '../cubit/auth_cubit.dart';
import 'screen_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({Key? key}) : super(key: key);

  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late User currentUser;
  final UserDatabase userDatabase = UserDatabase();

  @override
  void initState() {
    final authCubit = BlocProvider.of<AuthCubit>(context);
    currentUser = authCubit.state.user!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Liste des utilisateurs',
        home: Scaffold(
            appBar: AppBar(title: const Text('Liste des utilisateurs')),
            body: StreamBuilder<QuerySnapshot>(
                stream: userDatabase.readData(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot data = snapshot.data!.docs[index];

                        return Dismissible(
                          background: Container(color: Colors.red),
                          key: ValueKey<Object>(data),
                          child: UserItemWidget(data, index),
                          onDismissed: (direction) {
                            setState(() {
                              userDatabase.remove(data["id"]);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(" supprimé")));
                          },
                        );
                      });
                })));
  }
}

class UserItemWidget extends StatelessWidget {
  const UserItemWidget(this.user, this.index) : super();
  final DocumentSnapshot user;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          print(user);
          print(index);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => EditScreen(user: user, index: index)));
        },
        child: userItemCard(user, index));
  }
}
