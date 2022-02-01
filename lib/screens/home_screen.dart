import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project4/database/user_database.dart';
import 'package:image_network/image_network.dart';
import 'package:flutter_project4/dto/user_dto.dart';
import '../cubit/auth_cubit.dart';
import 'screen_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late User currentUser;
  final UserDatabase userDatabase = UserDatabase();

  @override
  void initState() {
    currentUser = widget.user;
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
                          key: ValueKey<Object>(snapshot.data!.docs[index]),
                          child: UserItemWidget(data),
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
  const UserItemWidget(this.user) : super();
  final DocumentSnapshot user;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/user',
          arguments: user,
        );
      },
      child: Card(
        margin: EdgeInsets.all(8),
        elevation: 8,
        child: Row(
          children: [userItemSection1(), userItemSection2()],
        ),
      ),
    );
  }

  Padding userItemSection1() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: ImageNetwork(
        image: user['picture'],
        imageCache: CachedNetworkImageProvider(user['picture']),
        height: 50,
        width: 50,
        duration: 1500,
        curve: Curves.easeIn,
        onPointer: true,
        fitAndroidIos: BoxFit.cover,
        fitWeb: BoxFitWeb.cover,
        borderRadius: BorderRadius.circular(70),
        onLoading: const CircularProgressIndicator(
          color: Colors.indigoAccent,
        ),
        onError: const Icon(
          Icons.error,
          color: Colors.red,
        ),
        onTap: () {
          debugPrint("©gabriel_patrick_souza");
        },
      ),
    );
  }

  Padding userItemSection2() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('profil',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ),
          Text(user['title'] + " " + user['firstName'] + " " + user['lastName'],
              style: TextStyle(color: Colors.grey[500], fontSize: 16))
        ],
      ),
    );
  }
}
