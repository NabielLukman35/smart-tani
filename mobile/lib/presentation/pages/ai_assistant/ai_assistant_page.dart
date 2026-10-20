import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/custom_sub_app_bar.dart';

class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  final TextEditingController _chatCtrl = TextEditingController();
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text: 'Halo Petani! Saya Asisten AI Smart Tani. Ada yang bisa saya bantu terkait greenhouse, hama, atau nutrisi tanaman Anda?',
      isBot: true,
      time: '10:00',
    ),
  ];

  void _sendMessage(String query) {
    if (query.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(
        text: query,
        isBot: false,
        time: 'Sekarang',
      ));
    });
    _chatCtrl.clear();

    // Jawaban simulasi pintar
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      String response = 'Berdasarkan data agronomi, menjaga kestabilan pH tanah antara 6.0 - 6.8 dan kelembapan 70-80% adalah kondisi paling ideal untuk pertumbuhan vegetatif.';
      if (query.toLowerCase().contains('ph')) {
        response = 'Untuk tanaman hidroponik & greenhouse, pH optimal adalah 5.8 - 6.5. Jika pH terlalu tinggi (>7), tanaman sulit menyerap zat besi (Fe).';
      } else if (query.toLowerCase().contains('pupuk') || query.toLowerCase().contains('npk')) {
        response = 'Gunakan rasio NPK 16-16-16 di fase awal vegetatif, lalu beralih ke kalium tinggi (NPK 10-10-30) saat mulai berbunga dan berbuah.';
      }

      setState(() {
        _messages.add(_ChatMessage(
          text: response,
          isBot: true,
          time: 'Sekarang',
        ));
      });
    });
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
                title: 'AI Assistant',
                subtitle: 'Konsultasi Budidaya & Diagnosa Penyakit',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF29B6F6).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF29B6F6).withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Text(
                    'AI Online',
                    style: TextStyle(
                      color: Color(0xFF29B6F6),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              // Chat Messages List
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
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
                          maxWidth: MediaQuery.of(context).size.width * 0.78,
                        ),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: msg.isBot
                              ? AppTheme.cardSurface
                              : AppTheme.neonLime,
                          borderRadius: BorderRadius.circular(16).copyWith(
                            bottomLeft: msg.isBot
                                ? const Radius.circular(0)
                                : const Radius.circular(16),
                            bottomRight: !msg.isBot
                                ? const Radius.circular(0)
                                : const Radius.circular(16),
                          ),
                          border: msg.isBot
                              ? Border.all(
                                  color: AppTheme.emeraldGreen.withValues(alpha: 0.35),
                                )
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.text,
                              style: TextStyle(
                                color: msg.isBot
                                    ? AppTheme.creamWhite
                                    : AppTheme.darkForest,
                                fontSize: 13,
                                height: 1.35,
                                fontWeight: msg.isBot
                                    ? FontWeight.w400
                                    : FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              msg.time,
                              style: TextStyle(
                                color: msg.isBot
                                    ? AppTheme.textGrey
                                    : AppTheme.darkForest.withValues(alpha: 0.6),
                                fontSize: 9.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Quick Prompts Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    _buildPromptChip('Berapa pH ideal tanaman melon?'),
                    _buildPromptChip('Jadwal pemupukan NPK minggu ini'),
                    _buildPromptChip('Cara mengatasi daun keriting'),
                  ],
                ),
              ),

              // Chat Input Bar
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.darkForest,
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.emeraldGreen.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.mic_rounded, color: AppTheme.neonLime),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mendengarkan suara input... (FR-05 Speech-to-Text)'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.inputFill,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.emeraldGreen.withValues(alpha: 0.4),
                          ),
                        ),
                        child: TextField(
                          controller: _chatCtrl,
                          style: const TextStyle(color: AppTheme.creamWhite, fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: 'Tanyakan sesuatu seputar tanaman...',
                            hintStyle: TextStyle(color: AppTheme.textGrey, fontSize: 12),
                            border: InputBorder.none,
                          ),
                          onSubmitted: _sendMessage,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _sendMessage(_chatCtrl.text),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppTheme.neonLime,
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
      onTap: () => _sendMessage(text),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.emeraldGreen.withValues(alpha: 0.35),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(color: AppTheme.pastelLime, fontSize: 11),
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
