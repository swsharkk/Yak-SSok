import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../models/chat_message.dart';
import '../../providers/chat_provider.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    await ref.read(chatControllerProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.searchChatBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: AppColors.searchChatPrimary, size: 20),
            ),
            const SizedBox(width: AppDimensions.paddingMd),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '약쏙 AI 상담',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Firebase 대화 기록',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('대화를 불러오지 못했어요')),
              data: (messages) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingXl,
                    vertical: AppDimensions.paddingLg,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) =>
                      _ChatBubble(message: messages[index]),
                );
              },
            ),
          ),
          _InputBar(
            controller: _inputController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

// ─── 채팅 버블 ─────────────────────────────────────────────
class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isBot = message.isBot;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingLg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isBot) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.searchChatBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: AppColors.searchChatPrimary, size: 18),
            ),
            const SizedBox(width: AppDimensions.paddingSm),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingLg,
                    vertical: AppDimensions.paddingMd,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isBot ? AppColors.surface : AppColors.searchChatPrimary,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(AppDimensions.radiusXl),
                      topRight: const Radius.circular(AppDimensions.radiusXl),
                      bottomLeft: Radius.circular(isBot
                          ? AppDimensions.radiusSm
                          : AppDimensions.radiusXl),
                      bottomRight: Radius.circular(isBot
                          ? AppDimensions.radiusXl
                          : AppDimensions.radiusSm),
                    ),
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isBot ? AppColors.textPrimary : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!isBot) const SizedBox(width: 4),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$period $displayHour:$minute';
  }
}

// ─── 입력창 ────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller, required this.onSend});
  final TextEditingController controller;
  final Future<void> Function() onSend;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.paddingXl,
        AppDimensions.paddingMd,
        AppDimensions.paddingMd,
        AppDimensions.paddingMd + bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style:
                    const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '약에 대해 무엇이든 물어보세요...',
                  hintStyle: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 14),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingLg,
                    vertical: AppDimensions.paddingMd,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusPill),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingSm),
            GestureDetector(
              onTap: onSend,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.searchChatPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
