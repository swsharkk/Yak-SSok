import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants.dart';
import '../../models/chat_message.dart';
import '../chat_repository.dart';

class BackendChatRepository implements ChatRepository {
  BackendChatRepository({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConstants.apiBaseUrl,
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 20),
            ));

  final Dio _dio;
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

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/chat',
        data: {
          'uid': AppConstants.backendTestUid,
          'message': text,
        },
      );
      final reply = response.data?['reply'] as String?;
      if (reply == null || reply.isEmpty) return _fallbackReply(text);

      final message = ChatMessage(
        id: const Uuid().v4(),
        role: ChatRole.assistant,
        content: reply,
        createdAt: DateTime.now(),
      );
      _messages.add(message);
      return message;
    } catch (_) {
      return _fallbackReply(text);
    }
  }

  ChatMessage _fallbackReply(String text) {
    final message = ChatMessage(
      id: const Uuid().v4(),
      role: ChatRole.assistant,
      content: '백엔드 채팅 API가 아직 연결되지 않아 임시 답변을 보여드려요.\n\n질문: $text',
      createdAt: DateTime.now(),
    );
    _messages.add(message);
    return message;
  }
}
