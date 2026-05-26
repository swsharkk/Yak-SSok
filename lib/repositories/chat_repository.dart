import '../models/chat_message.dart';

abstract class ChatRepository {
  Future<List<ChatMessage>> getMessages();

  Future<ChatMessage> sendMessage(String text);
}
