import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project4/database/user_database.dart';
import 'package:flutter_project4/screens/edit_screen.dart';
import 'package:image_network/image_network.dart';
import 'package:flutter_project4/dto/user_dto.dart';
import 'package:cached_network_image/cached_network_image.dart';

Padding userItemSection1(user) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
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

Padding userItemSection2(user, index) {
  return Padding(
    padding: EdgeInsets.all(8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('profil ' + index.toString(),
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        Text(user['title'] + " " + user['firstName'] + " " + user['lastName'],
            style: TextStyle(color: Colors.grey[500], fontSize: 20))
      ],
    ),
  );
}

Card userItemCard(user, index) {
  return Card(
    margin: EdgeInsets.all(8),
    elevation: 8,
    child: Row(
      children: [userItemSection1(user), userItemSection2(user, index + 1)],
    ),
  );
}
