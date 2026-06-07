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
      backgroundColor: const Color(0xFFF8FAFD),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, 0.58, 1],
            colors: [
              Color(0xFFFBFBFD),
              Color(0xFFFBFBFD),
              Color(0xFFA9D3F7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const _ChatHeader(),
              Expanded(
                child: messagesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(child: Text('대화를 불러오지 못했어요')),
                  data: (messages) {
                    final initialMessage =
                        messages.where((message) => message.isBot).isEmpty
                            ? null
                            : messages.firstWhere((message) => message.isBot);
                    final chatMessages = initialMessage == null
                        ? messages
                        : messages
                            .where((message) => message.id != initialMessage.id)
                            .toList();

                    if (chatMessages.isEmpty) {
                      return _ChatWelcome(
                        message: initialMessage?.content ??
                            '안녕하세요! 약쏙 AI 상담사입니다.\n약 복용, 부작용, 약 조합 등 궁금한 점을 질문해 보세요.',
                      );
                    }

                    WidgetsBinding.instance
                        .addPostFrameCallback((_) => _scrollToBottom());
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(
                        AppDimensions.paddingXl,
                        AppDimensions.paddingLg,
                        AppDimensions.paddingXl,
                        AppDimensions.padding3xl,
                      ),
                      itemCount: chatMessages.length,
                      itemBuilder: (context, index) =>
                          _ChatBubble(message: chatMessages[index]),
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
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingXl,
        AppDimensions.paddingLg,
        AppDimensions.paddingXl,
        AppDimensions.paddingMd,
      ),
      child: Row(
        children: [
          _CircleButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: AppDimensions.paddingXl),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
              children: [
                TextSpan(text: '약쏙 '),
                TextSpan(
                  text: 'AI',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 8,
      shadowColor: Colors.black12,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 58,
          height: 58,
          child: Icon(
            icon,
            color: AppColors.textPrimary,
            size: 27,
          ),
        ),
      ),
    );
  }
}

class _ChatWelcome extends StatelessWidget {
  const _ChatWelcome({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: AppDimensions.padding3xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SparkIcon(),
            const SizedBox(height: AppDimensions.paddingXxl),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 25,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SparkIcon extends StatelessWidget {
  const _SparkIcon();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFF5B5B),
          Color(0xFFF7C84B),
          Color(0xFF35C971),
          Color(0xFF4A7BFF),
        ],
      ).createShader(bounds),
      child: const Icon(
        Icons.auto_awesome_rounded,
        size: 48,
        color: Colors.white,
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
                    color: isBot ? AppColors.surface : const Color(0xFF1F7AE0),
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
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.paddingXl,
        AppDimensions.paddingLg,
        AppDimensions.paddingXl,
        AppDimensions.paddingXl + bottom,
      ),
      child: SafeArea(
        top: false,
        child: Material(
          color: AppColors.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.paddingMd,
              AppDimensions.paddingSm,
              AppDimensions.paddingSm,
              AppDimensions.paddingSm,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.add_rounded,
                  color: AppColors.textPrimary,
                  size: 34,
                ),
                const SizedBox(width: AppDimensions.paddingSm),
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      hintText: '약쏙 AI에게 물어보세요',
                      hintStyle: TextStyle(
                        color: Color(0xFF8E949B),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      isCollapsed: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend(),
                  ),
                ),
                GestureDetector(
                  onTap: onSend,
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1F7AE0),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
