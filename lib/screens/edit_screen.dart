import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project4/constant/constant.dart';
import 'package:flutter_project4/database/user_database.dart';
import 'package:flutter_project4/screens/list_screen.dart';
import 'package:flutter_project4/screens/widgets/appbar_widget.dart';
import 'package:flutter_project4/screens/widgets/common.dart';
import 'package:flutter_project4/ui/animation_button.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_network/image_network.dart';
import 'package:flutter_project4/dto/user_dto.dart';
import '../cubit/auth_cubit.dart';
import 'screen_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditScreen extends StatefulWidget {
  final DocumentSnapshot user;
  final int index;
  const EditScreen({Key? key, required this.user, required this.index})
      : super(key: key);

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final UserDatabase userDatabase = UserDatabase();
  //
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void initState() {
    _titleController.text = widget.user["title"];
    _firstNameController.text = widget.user["firstName"];
    _lastNameController.text = widget.user["lastName"];
    //
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFfefefe),
        appBar: const AppbarWidget(height: 50, title: 'users - edit'),
        body: StreamBuilder<QuerySnapshot>(
            stream: userDatabase.readData(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      userItemCard(widget.user, widget.index),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 200,
                            child: titleFormField(context),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: 200,
                            child: firstNameFormField(context),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: 200,
                            child: lastNameFormField(context),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          cancelButton(context),
                          Container(
                            width: 100,
                          ),
                          loginButton(context, widget.user),
                        ],
                      )
                    ],
                  ));
            }));
  }

  TextFormField titleFormField(BuildContext context) {
    return TextFormField(
      textInputAction: TextInputAction.next,
      controller: _titleController,
      decoration: InputDecoration(
        label: Text(titleLabel),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: kFieldBorderColor, width: 2),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: kFieldBorderColor, width: 2),
        ),
        hintStyle: textStyle(context, kfieldColor),
        labelStyle: textStyle(context, kLabelColor),
      ),
      style: textStyle(context, kfieldColor),
      keyboardType: TextInputType.emailAddress,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (title) {
        if (title!.isEmpty) {
          return titleEmpty;
        } else if (title.length < 2) {
          return titleIncorrect;
        }
      },
    );
  }

  TextFormField firstNameFormField(BuildContext context) {
    return TextFormField(
      textInputAction: TextInputAction.next,
      controller: _firstNameController,
      decoration: InputDecoration(
        label: Text(firstNameLabel),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: kFieldBorderColor, width: 2),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: kFieldBorderColor, width: 2),
        ),
        hintStyle: textStyle(context, kLabelColor),
        labelStyle: textStyle(context, kLabelColor),
      ),
      style: textStyle(context, kfieldColor),
      keyboardType: TextInputType.emailAddress,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (firstName) {
        if (firstName!.isEmpty) {
          return titleEmpty;
        } else if (firstName.length < 2) {
          return titleIncorrect;
        }
      },
    );
  }

  TextFormField lastNameFormField(BuildContext context) {
    return TextFormField(
      textInputAction: TextInputAction.next,
      controller: _lastNameController,
      decoration: InputDecoration(
        label: Text(lastNameLabel),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: kFieldBorderColor, width: 2),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: kFieldBorderColor, width: 2),
        ),
        hintStyle: textStyle(context, kLabelColor),
        labelStyle: textStyle(context, kLabelColor),
      ),
      style: textStyle(context, kfieldColor),
      keyboardType: TextInputType.emailAddress,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (lastName) {
        if (lastName!.isEmpty) {
          return titleEmpty;
        } else if (lastName.length < 2) {
          return titleIncorrect;
        }
      },
    );
  }

  ElevatedButton loginButton(BuildContext context, DocumentSnapshot user) {
    return ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            UserDto userDto = UserDto(
                id: user["id"].trim(),
                title: _titleController.text.trim(),
                firstName: _firstNameController.text.trim(),
                lastName: _lastNameController.text.trim(),
                picture: user["picture"].trim());
            userDatabase.update(userDto);

            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => ListScreen()));
          } else {
            return;
          }
        },
        child: Text(editValidLabel));
  }

  ElevatedButton cancelButton(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => ListScreen()));
        },
        child: Text(editCancelLabel));
  }
}
