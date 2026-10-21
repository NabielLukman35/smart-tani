const crypto = require('crypto');

const SECRET_KEY = process.env.SECRET_KEY || 'TaniGreen_PAM_2026_Key';

/**
 * FR-01: Pembuatan Salt Acak sepanjang 16 Karakter
 */
function generateSalt(length = 16) {
  const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  let salt = '';
  const bytes = crypto.randomBytes(length);
  for (let i = 0; i < length; i++) {
    salt += chars[bytes[i] % chars.length];
  }
  return salt;
}

/**
 * FR-01: Algoritma Enkripsi Custom Sesuai Spesifikasi Mobile (Salt + XOR Shift + Permutasi Blok)
 */
function encryptPassword(plainPassword, salt) {
  const combined = `${salt}:${plainPassword}:${SECRET_KEY}`;
  const bytes = Buffer.from(combined, 'utf8');
  const keyBytes = Buffer.from(salt + SECRET_KEY, 'utf8');

  // 1. Transformasi Substitusi (XOR dengan key byte + pergeseran indeks)
  const substituted = [];
  for (let i = 0; i < bytes.length; i++) {
    const k = keyBytes[i % keyBytes.length];
    substituted.push(((bytes[i] ^ k) + (i * 7)) % 256);
  }

  // 2. Transformasi Permutasi (Menukar indeks pasangan ganjil-genap)
  for (let i = 0; i < substituted.length - 1; i += 2) {
    const temp = substituted[i];
    substituted[i] = substituted[i + 1];
    substituted[i + 1] = temp;
  }

  // 3. Konversi menjadi hex string
  return substituted.map(b => b.toString(16).padStart(2, '0')).join('');
}

/**
 * Verifikasi kecocokan password plaintext terhadap hash tersimpan
 */
function verifyPassword(inputPassword, salt, storedCiphertext) {
  return encryptPassword(inputPassword, salt) === storedCiphertext;
}

module.exports = {
  generateSalt,
  encryptPassword,
  verifyPassword,
};
