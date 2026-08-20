import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class UserAvatar extends StatelessWidget{
  const UserAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewmodel>(
        builder: (context, auth, child) {
          String firstLetter = auth.userName.isNotEmpty ? auth.userName[0].toUpperCase() : "U";
          return PopupMenuButton<String>(
            offset: const Offset(0, 40),
              color: const Color(0xFF202123),
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: false,
                  child: Text("Signed in as\n${auth.userName}", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.redAccent, size: 18),
                        SizedBox(width: 8),
                        Text("Log out", style: TextStyle(color: Colors.redAccent))
                      ],
                    ),
                ),
              ],
            onSelected: (value) {
              if (value == 'logout') {
                auth.logout();
              }
            },
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: CircleAvatar(
                backgroundColor: Colors.blueAccent,
                radius: 16,
                child: Text(
                  firstLetter,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          );
        },
    );
  }
}