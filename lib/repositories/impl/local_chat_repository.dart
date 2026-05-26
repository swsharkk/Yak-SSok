import 'package:uuid/uuid.dart';

import '../../models/chat_message.dart';
import '../chat_repository.dart';

class LocalChatRepository implements ChatRepository {
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: 'welcome',
      role: ChatRole.assistant,
      content: '안녕하세요! 약쏙 AI 상담사입니다.\n약 복용, 부작용, 약 조합 등 궁금한 점을 질문해 보세요.',
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<ChatMessage>> getMessages() async => List.unmodifiable(_messages);

  @override
  Future<ChatMessage> sendMessage(String text) async {
    final now = DateTime.now();
    _messages.add(ChatMessage(
      id: const Uuid().v4(),
      role: ChatRole.user,
      content: text,
      createdAt: now,
    ));

    final reply = ChatMessage(
      id: const Uuid().v4(),
      role: ChatRole.assistant,
      content: '현재는 백엔드 연결 전 임시 답변입니다.\n\n질문: $text',
      createdAt: now.add(const Duration(milliseconds: 300)),
    );
    _messages.add(reply);
    return reply;
  }
}
