import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
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
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  bool _isListening = false;
  bool _speechAvailable = false;

  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text: 'Halo Petani! Saya Asisten Tani berbasis Google Gemini AI & Smart Agronomy Engine.\n'
          'Tanyakan apa saja seputar diagnosis hama, daun menguning, jadwal pemupukan NPK, atau rekomendasi perawatan greenhouse Anda.',
      isBot: true,
      time: 'Asisten AI',
    ),
  ];
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initSpeechToText();
  }

  Future<void> _initSpeechToText() async {
    try {
      _speechAvailable = await _speech.initialize(
        onStatus: (status) {
          if (status == 'notListening' || status == 'done') {
            if (mounted) setState(() => _isListening = false);
          }
        },
        onError: (_) {
          if (mounted) setState(() => _isListening = false);
        },
      );
    } catch (_) {
      _speechAvailable = false;
    }
  }

  Future<void> _toggleVoiceRecording() async {
    if (!_speechAvailable) {
      await _initSpeechToText();
    }

    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    if (_speechAvailable) {
      if (mounted) setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _promptController.text = result.recognizedWords;
            });
          }
        },
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin mikrofon belum aktif atau fitur suara tidak tersedia.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _askGemini([String? customPrompt]) async {
    final query = (customPrompt ?? _promptController.text).trim();
    if (query.isEmpty || _isLoading) return;

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    }

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
          time: 'Asisten Tani (Gemini AI)',
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
    _speech.stop();
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
                subtitle: 'Didukung Google Gemini & Agronomi Engine',
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
                              'Gemini AI sedang menganalisis...',
                              style: TextStyle(color: AppTheme.pastelLime, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Listening Voice Status Indicator (FR-05)
              if (_isListening)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE74C3C).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE74C3C).withValues(alpha: 0.5)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mic_rounded, color: Color(0xFFFF5252), size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Mendengarkan suara Anda... (Bicara sekarang)',
                          style: TextStyle(color: Color(0xFFFF8A80), fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
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
                    _buildPromptChip('Berapa pH ideal tanaman melon?'),
                  ],
                ),
              ),

              // Input Bar (Input Suara FR-05 & Teks FR-09)
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
                    // Tombol Input Suara Mikrofon (FR-05)
                    GestureDetector(
                      onTap: _toggleVoiceRecording,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _isListening
                              ? const Color(0xFFFF5252)
                              : AppTheme.emeraldGreen.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _isListening
                                ? Colors.white
                                : AppTheme.neonLime.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Icon(
                          _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                          color: _isListening ? Colors.white : AppTheme.neonLime,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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
