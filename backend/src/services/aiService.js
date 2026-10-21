/**
 * FR-09: AI & LLM Service untuk Konsultasi Agronomi, Diagnosa Penyakit & Perawatan Greenhouse
 */
async function generateAgronomyAdvice(prompt) {
  const apiKey = process.env.GEMINI_API_KEY;

  if (apiKey && apiKey !== 'your_gemini_api_key_here') {
    try {
      const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`;
      const response = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [
            {
              role: 'user',
              parts: [
                {
                  text: `Anda adalah Asisten Agronomi Cerdas untuk aplikasi Smart Tani (TaniGreen). Berikan panduan budidaya praktis, ramah petani, ilmiah dan ringkas mengenai pertanyaan berikut: ${prompt}`,
                },
              ],
            },
          ],
        }),
      });

      if (response.ok) {
        const data = await response.json();
        const reply = data.candidates?.[0]?.content?.parts?.[0]?.text;
        if (reply) return reply;
      }
    } catch (e) {
      console.warn('Gagal memanggil Gemini API, beralih ke agronomy knowledge base bawaan:', e.message);
    }
  }

  // Fallback Rule-Based Pintar Sesuai Domain Pertanian TaniGreen
  const lower = prompt.toLowerCase();
  if (lower.includes('ph')) {
    return 'Untuk tanaman hortikultura & greenhouse, rentang pH ideal larutan nutrisi adalah 5.8 - 6.5. Jika pH > 7.0, tanaman rentan mengalami klorosis karena defisiensi zat besi (Fe).';
  }
  if (lower.includes('pupuk') || lower.includes('npk') || lower.includes('nutrisi')) {
    return 'Pada fase vegetatif (pertumbuhan daun & batang), gunakan rasio NPK berimbang seperti 16-16-16. Saat fase generatif/pembungaan, tingkatkan unsur Kalium (K) dan Fosfor (P) untuk memaksimalkan bobot dan rasa manis buah.';
  }
  if (lower.includes('melon')) {
    return 'Tanaman melon membutuhkan suhu optimal 24 - 30°C dan kelembapan 60-70%. Pastikan pemangkasan tunas air (pruning) dilakukan rutin pada ruas 1-8 agar nutrisi terfokus ke buah utama di ruas 9-12.';
  }
  if (lower.includes('hama') || lower.includes('kutu')) {
    return 'Untuk mengendalikan hama kutu kebul atau thrips secara ramah lingkungan, pasang sticky trap kuning setinggi tajuk tanaman dan gunakan biopestisida berbahan ekstrak daun nimba atau minyak atsiri.';
  }

  return `Berdasarkan data agronomi Smart Tani mengenai "${prompt}": Kondisi lingkungan greenhouse yang stabil, pemantauan EC nutrisi secara berkala, dan ventilasi udara yang cukup adalah kunci utama produktivitas tanaman sehat.`;
}

module.exports = {
  generateAgronomyAdvice,
};
