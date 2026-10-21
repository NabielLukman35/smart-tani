const { calculateBlockHash, verifyChain } = require('../services/hashService');
const { generateAgronomyAdvice } = require('../services/aiService');

// In-Memory Cloud Store
const cloudGreenhouses = [];
const cloudSensorLogs = [];
const cloudSchedules = [];
const cloudBlocks = [];

/**
 * FR-03: Sinkronisasi Data Offline-to-Online
 * Menerima kumpulan data dari SQLite yang berstatus 'Menunggu Unggah'
 */
async function syncOfflineData(req, res, next) {
  try {
    const { userId, greenhouses = [], sensorLogs = [], schedules = [], blocks = [] } = req.body;

    // Simpan ke cloud store
    greenhouses.forEach(gh => cloudGreenhouses.push({ ...gh, syncedAt: new Date().toISOString() }));
    sensorLogs.forEach(log => cloudSensorLogs.push({ ...log, syncedAt: new Date().toISOString() }));
    schedules.forEach(sc => cloudSchedules.push({ ...sc, syncedAt: new Date().toISOString() }));
    blocks.forEach(b => cloudBlocks.push({ ...b, syncedAt: new Date().toISOString() }));

    res.status(200).json({
      status: 'success',
      message: 'Seluruh data offline berhasil disinkronkan ke server pusat.',
      summary: {
        greenhousesSynced: greenhouses.length,
        sensorLogsSynced: sensorLogs.length,
        schedulesSynced: schedules.length,
        blocksSynced: blocks.length,
      },
      timestamp: new Date().toISOString(),
    });
  } catch (err) {
    next(err);
  }
}

/**
 * FR-09: Endpoint Tanya Asisten AI (Gemini LLM)
 */
async function askAiAssistant(req, res, next) {
  try {
    const { prompt } = req.body;
    if (!prompt || prompt.trim() === '') {
      return res.status(400).json({ status: 'error', message: 'Pertanyaan atau prompt wajib diisi.' });
    }

    const reply = await generateAgronomyAdvice(prompt.trim());
    res.status(200).json({
      status: 'success',
      reply,
      timestamp: new Date().toISOString(),
    });
  } catch (err) {
    next(err);
  }
}

/**
 * FR-13: Verifikasi Integritas Audit Blockchain
 */
async function verifyBlockchain(req, res, next) {
  try {
    const blocksToVerify = req.body.blocks || cloudBlocks;
    const result = verifyChain(blocksToVerify);
    res.status(200).json({
      status: 'success',
      ...result,
      totalBlocks: blocksToVerify.length,
    });
  } catch (err) {
    next(err);
  }
}

/**
 * Mengambil daftar greenhouse tersinkronisasi
 */
async function listGreenhouses(req, res) {
  res.status(200).json({
    status: 'success',
    data: cloudGreenhouses,
  });
}

module.exports = {
  syncOfflineData,
  askAiAssistant,
  verifyBlockchain,
  listGreenhouses,
};
