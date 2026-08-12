class ChatModel {
  final String message;
  final bool isUser;

  ChatModel({required this.message, required this.isUser});

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    // Yahan 'user' ko bhi check karna zaroori hai kyunki Spring Boot 'isUser' ko 'user' banakar bhejta hai
    final rawVal = json['isUser'] ?? json['user'];
    bool parsedIsUser = false;

    if (rawVal != null) {
      parsedIsUser = rawVal is bool ? rawVal : rawVal.toString().toLowerCase() == 'true';
    } else if (json['sender'] != null) {
      parsedIsUser = json['sender'].toString().toLowerCase() == 'user';
    } else if (json['role'] != null) {
      parsedIsUser = json['role'].toString().toLowerCase() == 'user';
    }

    return ChatModel(
      message: json['message']?.toString() ?? json['text']?.toString() ?? '',
      isUser: parsedIsUser,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'isUser': isUser,
    };
  }
}