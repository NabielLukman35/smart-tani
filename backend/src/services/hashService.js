const crypto = require('crypto');

/**
 * FR-13: Kalkulasi hash blok audit rantai log (SHA-256)
 * hash = SHA-256(data log + hash_sebelumnya + timestamp)
 */
function calculateBlockHash(dataLog, previousHash, timestamp) {
  const payload = `${dataLog}:${previousHash}:${timestamp}`;
  return crypto.createHash('sha256').update(payload).digest('hex');
}

/**
 * Memverifikasi validitas integritas seluruh blok rantai dari awal hingga akhir
 */
function verifyChain(blocks) {
  if (!Array.isArray(blocks) || blocks.length === 0) {
    return { valid: true, message: 'Rantai kosong' };
  }

  for (let i = 1; i < blocks.length; i++) {
    const current = blocks[i];
    const prev = blocks[i - 1];

    if (current.hash_sebelumnya !== prev.hash) {
      return {
        valid: false,
        brokenIndex: i,
        reason: `Hash sebelumnya pada blok #${current.id || i} tidak cocok dengan hash blok #${prev.id || (i - 1)}`,
      };
    }

    const recalculated = calculateBlockHash(current.data_log, current.hash_sebelumnya, current.timestamp);
    if (recalculated !== current.hash) {
      return {
        valid: false,
        brokenIndex: i,
        reason: `Integritas data pada blok #${current.id || i} telah diubah / dimanipulasi`,
      };
    }
  }

  return { valid: true, message: 'Seluruh blok blockchain terverifikasi valid dan immutable' };
}

module.exports = {
  calculateBlockHash,
  verifyChain,
};
