import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = 'AQ.Ab8RN6JGH8UbeIcA9a1glVsn5QiQ8MfuHoFD4iARmzaZaSjbOQ';

  static Future<String> getTaniAdvice(String userPrompt) async {
    // Daftar model aktif yang didukung API (gemini-1.5-flash telah digantikan oleh gemini-2.5-flash)
    final candidateModels = ['gemini-2.5-flash', 'gemini-flash-latest', 'gemini-2.5-pro'];

    String lastError = '';

    for (final modelName in candidateModels) {
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: _apiKey,
          systemInstruction: Content.text(
            'Kamu adalah "Asisten Tani", AI ahli agronom dan pertanian cerdas untuk aplikasi TaniGreen. '
            'Tugasmu adalah membantu petani muda dan peneliti mendiagnosis gejala penyakit tanaman (seperti melon, tomat, cabai), '
            'memberikan rekomendasi jadwal perawatan, dan menyusun deskripsi varietas tanaman secara profesional, ramah, ringkas, dan solutif.',
          ),
        );

        final content = [Content.text(userPrompt)];
        final response = await model.generateContent(content);

        if (response.text != null && response.text!.trim().isNotEmpty) {
          return response.text!;
        }
      } catch (e) {
        lastError = e.toString();
        // Coba model kandidat berikutnya
        continue;
      }
    }

    return 'Gagal terhubung ke Gemini AI: $lastError. Pastikan koneksi internet aktif.';
  }
}