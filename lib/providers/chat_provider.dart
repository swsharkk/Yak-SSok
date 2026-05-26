import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../models/chat_message.dart';
import '../repositories/chat_repository.dart';
import '../repositories/impl/backend_chat_repository.dart';
import '../repositories/impl/local_chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  if (AppConstants.apiBaseUrl.isNotEmpty) {
    return BackendChatRepository();
  }
  return LocalChatRepository();
});

final chatControllerProvider =
    StateNotifierProvider<ChatController, AsyncValue<List<ChatMessage>>>(
  (ref) => ChatController(ref.read(chatRepositoryProvider))..load(),
);

class ChatController extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  ChatController(this._repository) : super(const AsyncValue.loading());

  final ChatRepository _repository;

  Future<void> load() async {
    state = await AsyncValue.guard(_repository.getMessages);
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final current = state.valueOrNull ?? const <ChatMessage>[];
    final pending = ChatMessage(
      id: 'pending_${DateTime.now().microsecondsSinceEpoch}',
      role: ChatRole.user,
      content: trimmed,
      createdAt: DateTime.now(),
      status: ChatMessageStatus.sending,
    );
    state = AsyncValue.data([...current, pending]);

    try {
      final assistant = await _repository.sendMessage(trimmed);
      final withoutPending =
          state.valueOrNull?.where((m) => m.id != pending.id).toList() ??
              current;
      state = AsyncValue.data([...withoutPending, assistant]);
      await load();
    } catch (_) {
      final failed = pending.copyWith(status: ChatMessageStatus.failed);
      final withoutPending =
          state.valueOrNull?.where((m) => m.id != pending.id).toList() ??
              current;
      state = AsyncValue.data([...withoutPending, failed]);
    }
  }
}
