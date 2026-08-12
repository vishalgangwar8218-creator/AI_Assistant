import 'package:ai_chat_assistant/views/widgets/chat_bubble.dart';
import 'package:ai_chat_assistant/views/widgets/input_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/chat_viewmodel.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients){
        _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Sidebar / Drawer ka common content (New Chat & Recent Chats)
  Widget _buildSidebarContent(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
          decoration: const BoxDecoration(
            color: Color(0xFF202123),
            border: Border(bottom: BorderSide(color: Colors.white12, width: 1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.blueAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "AI Assistant",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: InkWell(
            onTap: () {
              Provider.of<ChatViewModel>(context, listen: false).clearChat();
              if(Scaffold.of(context).isDrawerOpen) {
                Navigator.pop(context); // Mobile ke liye drawer band karne ke liye
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text(
                    "New Chat",
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                  )
                ],
              ),
            ),
          ),
        ),
        const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 2),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Recent Chats",
              style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
            child: Consumer<ChatViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.recentChats.isEmpty) {
                    return const Padding(
                        padding: EdgeInsets.all(16.0),
                      child: Text(
                        "No Recent Chat",
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: viewModel.recentChats.length,
                      itemBuilder: (context, index) {
                      final chatTitle = viewModel.recentChats[index];
                      return ListTile(
                        dense: true,
                        visualDensity: const VisualDensity(vertical: -2),
                        leading: const Icon(Icons.chat_bubble_outline, color: Colors.white70, size: 16),
                        title: Text(
                          chatTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        onTap: () {
                          Provider.of<ChatViewModel>(context, listen: false).selectRecentChat(chatTitle, index);
                          // Agar mobile view me hain toh drawer band karo, web me zaroorat nahi
                          if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                            Navigator.pop(context);
                          }
                        },
                      );
                      }
                  );
                }
            )
        )
      ],
    );
  }

  // 2. Chat screen ka main body (Messages list + Input bar) jo dono jagah same rahega
  Widget _buildChatBody() {
    return Column(
      children: [
        Expanded(
            child: Consumer<ChatViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.messages.isEmpty) {
                    return const Center(
                      child: Text(
                        "How can I help you today?",
                        style: TextStyle(color: Colors.white54, fontSize: 20),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                      itemCount: viewModel.messages.length,
                      itemBuilder: (context, index) {
                       final msg = viewModel.messages[index];

                       return ChatBubble(
                           message: msg.message,
                           isUser: msg.isUser,
                       );
                      }
                  );
                }
            ),
        ),
        Consumer<ChatViewModel>(
            builder: (context, viewModel, child) {
              return InputBar(
                  onSendMessage: (text) {
                    viewModel.sendMessage(text, onMessageSent: () {
                      _scrollToBottom();
                    });
                  },
                  isLoading: viewModel.isLoading,
                onAttachedPressed: () {
                    viewModel.pickAndSendFile(onMessageSent: () {
                      _scrollToBottom();
                    });
                },
              );
            },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return LayoutBuilder(
        builder: (context, constraints) {
          // Agar screen badi hai (Web / Desktop, width > 768px)
          if (constraints.maxWidth > 768) {
            return Scaffold(
              backgroundColor: const Color(0xFF343541),
              body: Row(
                children: [
                  // Left side permanent Sidebar
                  Container(
                    width: 280,
                    color: const Color(0xFF202123),
                    child: _buildSidebarContent(context),
                  ),
                  // Right side chat area
                  Expanded(
                      child: _buildChatBody(),
                  )
                ],
              ),
            );
          }

          // Agar mobile screen hai (width <= 768px)
          return Scaffold(
            backgroundColor: const Color(0xFF343541),
            appBar: AppBar(
              backgroundColor: const Color(0xFF202123),
              title: const Text("AI Assistant", style: TextStyle(color: Colors.white)),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            drawer: Drawer(
              backgroundColor: const Color(0xFF202123),
              child: _buildSidebarContent(context),
            ),
            body: _buildChatBody(),
          );
        }
    );
  }
}