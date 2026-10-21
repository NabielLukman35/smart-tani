import 'package:flutter/material.dart';
import '../../../core/services/gemini_services.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/custom_sub_app_bar.dart';

class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text: 'Halo! Saya Asisten Tani berbasis Google Gemini AI.\nTanyakan apa saja seputar diagnosis hama, daun menguning, jadwal pemupukan, atau rekomendasi perawatan greenhouse Anda.',
      isBot: true,
      time: 'Asisten AI',
    ),
  ];
  
  bool _isLoading = false;

  Future<void> _askGemini([String? customPrompt]) async {
    final query = (customPrompt ?? _promptController.text).trim();
    if (query.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(_ChatMessage(
        text: query,
        isBot: false,
        time: 'Anda',
      ));
      _isLoading = true;
    });
    _promptController.clear();
    _scrollToBottom();

    final result = await GeminiService.getTaniAdvice(query);

    if (mounted) {
      setState(() {
        _messages.add(_ChatMessage(
          text: result,
          isBot: true,
          time: 'Gemini 1.5 Flash',
        ));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              CustomSubAppBar(
                title: 'Asisten Tani AI (FR-09)',
                subtitle: 'Didukung Google Gemini AI',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.neonLime.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.neonLime.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, color: AppTheme.neonLime, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Gemini AI',
                        style: TextStyle(
                          color: AppTheme.neonLime,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Chat Messages View
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _messages.length,
                  itemBuilder: (ctx, idx) {
                    final msg = _messages[idx];
                    return Align(
                      alignment: msg.isBot
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.82,
                        ),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: msg.isBot
                              ? AppTheme.cardSurface
                              : AppTheme.neonLime,
                          borderRadius: BorderRadius.circular(18).copyWith(
                            bottomLeft: msg.isBot
                                ? const Radius.circular(2)
                                : const Radius.circular(18),
                            bottomRight: !msg.isBot
                                ? const Radius.circular(2)
                                : const Radius.circular(18),
                          ),
                          border: msg.isBot
                              ? Border.all(
                                  color: AppTheme.emeraldGreen.withValues(alpha: 0.45),
                                  width: 1.1,
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  msg.isBot
                                      ? Icons.smart_toy_rounded
                                      : Icons.person_rounded,
                                  size: 13,
                                  color: msg.isBot
                                      ? AppTheme.neonLime
                                      : AppTheme.darkForest,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  msg.time,
                                  style: TextStyle(
                                    color: msg.isBot
                                        ? AppTheme.pastelLime.withValues(alpha: 0.75)
                                        : AppTheme.darkForest.withValues(alpha: 0.7),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            SelectableText(
                              msg.text,
                              style: TextStyle(
                                color: msg.isBot
                                    ? AppTheme.creamWhite
                                    : AppTheme.darkForest,
                                fontSize: 13,
                                height: 1.4,
                                fontWeight: msg.isBot
                                    ? FontWeight.w400
                                    : FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Loading Indicator
              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.cardSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.neonLime.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.neonLime,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Gemini AI sedang berpikir...',
                              style: TextStyle(color: AppTheme.pastelLime, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Prompt Shortcut Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    _buildPromptChip('Daun melon bercak kuning, solusinya apa?'),
                    _buildPromptChip('Rekomendasi takaran pupuk AB Mix hidroponik'),
                    _buildPromptChip('Cara mengatasi hama kutu kebul'),
                  ],
                ),
              ),

              // Input Bar
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.darkForest,
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.emeraldGreen.withValues(alpha: 0.35),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.inputFill,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: AppTheme.emeraldGreen.withValues(alpha: 0.5),
                          ),
                        ),
                        child: TextField(
                          controller: _promptController,
                          style: const TextStyle(color: AppTheme.creamWhite, fontSize: 13.5),
                          cursorColor: AppTheme.neonLime,
                          decoration: const InputDecoration(
                            hintText: 'Tanyakan keluhan atau perawatan tanaman...',
                            hintStyle: TextStyle(color: AppTheme.textGrey, fontSize: 12),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (val) => _askGemini(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _isLoading ? null : () => _askGemini(),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isLoading
                              ? AppTheme.textGrey.withValues(alpha: 0.3)
                              : AppTheme.neonLime,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: AppTheme.darkForest,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromptChip(String text) {
    return GestureDetector(
      onTap: _isLoading ? null : () => _askGemini(text),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.emeraldGreen.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.help_outline_rounded, size: 12, color: AppTheme.neonLime),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(color: AppTheme.pastelLime, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isBot;
  final String time;

  const _ChatMessage({
    required this.text,
    required this.isBot,
    required this.time,
  });
}