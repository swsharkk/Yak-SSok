enum ChatRole { user, assistant }

enum ChatMessageStatus { sending, sent, failed }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.status = ChatMessageStatus.sent,
  });

  final String id;
  final ChatRole role;
  final String content;
  final DateTime createdAt;
  final ChatMessageStatus status;

  bool get isBot => role == ChatRole.assistant;

  ChatMessage copyWith({
    String? id,
    ChatRole? role,
    String? content,
    DateTime? createdAt,
    ChatMessageStatus? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}
