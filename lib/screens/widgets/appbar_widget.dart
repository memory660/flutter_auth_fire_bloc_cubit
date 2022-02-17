import 'package:flutter/material.dart';

class AppbarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppbarWidget({Key? key, required this.height, required this.title})
      : super(key: key);
  final double height;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        PopupMenuButton(itemBuilder: (context) {
          return [
            const PopupMenuItem<int>(
              value: 0,
              child: Text("connexion"),
            ),
            const PopupMenuItem<int>(
              value: 1,
              child: Text("carte 1"),
            ),
            const PopupMenuItem<int>(
              value: 2,
              child: Text("carte 2 - bloc"),
            ),
            const PopupMenuItem<int>(
              value: 3,
              child: Text("carte 3 - ChangeNotifier"),
            ),
            const PopupMenuItem<int>(
              value: 4,
              child: Text("crud - utilisateurs"),
            ),
          ];
        }, onSelected: (value) {
          if (value == 0) {
            Navigator.pushNamed(context, '/connexion');
          } else if (value == 1) {
            Navigator.pushNamed(context, '/google-maps');
          } else if (value == 2) {
            Navigator.pushNamed(context, '/bloc-google-maps');
          } else if (value == 3) {
            Navigator.pushNamed(context, '/changenotifier-google-maps');
          } else if (value == 4) {
            Navigator.pushNamed(context, '/users');
          } else if (value == 5) {
            print("Logout menu is selected.");
          }
        }),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
