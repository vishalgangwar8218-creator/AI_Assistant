import 'package:ai_chat_assistant/viewmodels/chat_viewmodel.dart';
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
    return ChangeNotifierProvider(
      create: (context) => ChatViewModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "AI Chat Assistant",
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const ChatScreen(),
      )
    );
  }
}
