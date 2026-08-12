import 'dart:io';

import 'package:ai_chat_assistant/services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/chat_model.dart';

class ChatViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  Map<String, List<ChatModel>> _chatSessions = {};
  Map<String, String> _chatTitles = {};

  final List<ChatModel> _messages = [];
  final List<String> _recentChats = [];

  bool _isLoading = false;
  final String userId = "user_123";

  String? _currentChatId;
  String? _currentChatTitle;

  List<ChatModel> get messages => _messages;
  List<String> get recentChats => _recentChats;
  bool get isLoading => _isLoading;
  String? get currentChatTitle => _currentChatTitle;

  ChatViewModel() {
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    List<Map<String, dynamic>> historyData = await _apiService.getChatHistory(userId);

    if(historyData.isNotEmpty) {
      _chatSessions.clear();
      _chatTitles.clear();
      _recentChats.clear();

     for(var item in historyData) {
       String chatId = item['chatId'] ?? 'default_chat';
       String message = item['message'] ?? '';
       bool isUser = item['isUser'] ?? false;

       if(!_chatSessions.containsKey(chatId)) {
         _chatSessions[chatId] = [];
       }
       _chatSessions[chatId]!.add(ChatModel(message: message, isUser: isUser));

       // Har chat ka jo pehla user message hoga, wo uska title ban jayega
       if(isUser && !_chatTitles.containsKey(chatId)){
         _chatTitles[chatId] = message;
       }
     }
      _recentChats.addAll(_chatTitles.values.toList().reversed);
    }
    notifyListeners();
  }

  void clearChat() {
    if(_isLoading) return;
    _messages.clear();
    _currentChatId = null;
    _currentChatTitle = null;
    notifyListeners();
  }

  void selectRecentChat(String chatTitle, int targetIndex) {
    _currentChatTitle = chatTitle;

    String? foundChatID;
    _chatTitles.forEach((chatId, title){
      if(title == chatTitle) {
        foundChatID = chatId;
      }
    });

    if(foundChatID != null && _chatSessions.containsKey(foundChatID)) {
      _currentChatId = foundChatID;
      _messages.clear();
      _messages.addAll(_chatSessions[foundChatID]!);
    }
    notifyListeners();
  }

  Future<void> pickAndSendFile({Function? onMessageSent}) async {
    if(_isLoading) return;

    try{
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'txt'],
      );

      if(result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        String fileName = file.name;

        if(_currentChatTitle == null) {
          _currentChatTitle = "File: $fileName";
        }

        final userModel = ChatModel(message: "📎 Uploaded file: $fileName", isUser: true);
        _messages.add(userModel);

        _isLoading = true;
        notifyListeners();

        if (onMessageSent != null) onMessageSent();

        // Spring Boot backend par file aur message bhejna
        var response = await _apiService.sendChatMessage
          (userId,
            "Please analyze this attached file.",
            _currentChatId,
            file: file
        );

        ChatModel aiModel;
        if (response != null) {
          if (_currentChatId == null) {
            _currentChatId = response['chatId'];
          }
          aiModel = ChatModel(message: response['message'], isUser: false);
        } else {
          aiModel = ChatModel(message: "Error: Failed to process file with AI server", isUser: false);
        }

        _messages.add(aiModel);

        if (_currentChatId == null) {
          _currentChatId = "chat_${DateTime.now().millisecondsSinceEpoch}";
        }

        if (_currentChatId != null) {
          _chatSessions[_currentChatId!] = List.from(_messages);
          _chatTitles[_currentChatId!] = _currentChatTitle!;
        }

        _isLoading = false;
        _recentChats.clear();
        _recentChats.addAll(_chatTitles.values.toList().reversed);
        notifyListeners();

        if(onMessageSent != null) onMessageSent();
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint("File picking error: $e");
    }
  }

  Future<void> sendMessage(String text, {Function? onMessageSent}) async{
    final trimmedText = text.trim();
    if(trimmedText.isEmpty || _isLoading) return;

    if(_messages.isNotEmpty && _messages.last.isUser && _messages.last.message == trimmedText){
      return;
    }

    if(_currentChatTitle == null) {
      _currentChatTitle = trimmedText;
    }

    final userModel = ChatModel(message: trimmedText, isUser: true);
    _messages.add(userModel);

    _isLoading = true;
    notifyListeners();

    if(onMessageSent != null) onMessageSent();

    var response = await _apiService.sendChatMessage(userId, trimmedText, _currentChatId);

    ChatModel aiModel;
    if(response != null) {
      if(_currentChatId == null) {
        _currentChatId = response['chatId'];
      }
      aiModel = ChatModel(message: response['message'], isUser: false);
    }else {
      aiModel = ChatModel(message: "Error: Failed to connect with AI server", isUser: false);
    }

    _messages.add(aiModel);

    if(_currentChatId != null){
      _chatSessions[_currentChatId!] = List.from(_messages);
      _chatTitles[_currentChatId!] = _currentChatTitle!;
    }

    _isLoading = false;

    // Sidebar ko update karne ke liye recent chats list ko refresh karo
    _recentChats.clear();
    _recentChats.addAll(_chatTitles.values.toList().reversed);
    notifyListeners();
    if(onMessageSent != null) onMessageSent();
  }
}