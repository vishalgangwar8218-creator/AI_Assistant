import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../models/chat_model.dart';

class ApiService {
  final String baseUrl = "http://10.172.235.22:8080/api/chat";

  Future<Map<String, dynamic>?> sendChatMessage(String userId, String message, String? chatId, {PlatformFile? file}) async {
    try{
      var uri = Uri.parse("$baseUrl/send");
      var request = http.MultipartRequest('POST', uri);

      // Fields add karein
      request.fields['userId'] = userId;
      request.fields['message'] = message;
      if (chatId != null && chatId.isNotEmpty) {
        request.fields['chatId'] = chatId;
      }

      // Agar file select ki gayi hai toh use request mein jodein
      if (file != null) {
        if (file.bytes != null) {
          request.files.add(http.MultipartFile.fromBytes(
            'file',
            file.bytes!,
            filename: file.name,
          ));
        } else if (file.path != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'file',
            file.path!,
          ));
        }
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "message": data['message'],
          "chatId": data['chatId'],
        };
      }
      return null;
    } catch(e) {
      print("API Error: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getChatHistory(String userId) async{
    try {
      final response = await http.get(Uri.parse("$baseUrl/history/$userId"));

      if(response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) =>
        {
          "message": item['message'] ?? '',
          "isUser": item['isUser'] ?? false,
          "chatId": item['chatId'] ?? '',
        }).toList();
      }

      return [];
    } catch (e) {
      print("History Error: $e");
      return [];
    }
  }
}