import 'package:ai_chat_assistant/viewmodels/auth_viewmodel.dart';
import 'package:ai_chat_assistant/viewmodels/chat_viewmodel.dart';
import 'package:ai_chat_assistant/views/auth_screen.dart';
import 'package:ai_chat_assistant/views/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthViewmodel()),
          ChangeNotifierProxyProvider<AuthViewmodel, ChatViewModel>(
              create: (context) => ChatViewModel(userId: Provider.of<AuthViewmodel>(context, listen: false).userId),
              update: (context, auth, previousChatViewModel) => ChatViewModel(userId: auth.userId),
          ),
        ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "AI Chat Assistant",
        theme: ThemeData(primarySwatch: Colors.blue),
        home: Consumer<AuthViewmodel>(
            builder: (context, auth, child) {
              if(!auth.isLoggedIn) {
                return const AuthScreen();
              }
              return const ChatScreen();
            },
        ),
      ),
    );
  }
}
