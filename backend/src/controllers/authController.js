const { generateSalt, encryptPassword, verifyPassword } = require('../utils/encrypt');
const { generateToken } = require('../utils/jwt');

// Penyimpanan pengguna dalam memori server (In-Memory Database / Mock Store)
const users = [];

async function register(req, res, next) {
  try {
    const { nama, email, password } = req.body;

    if (!nama || !email || !password) {
      return res.status(400).json({
        status: 'error',
        message: 'Nama, email, dan password wajib diisi.',
      });
    }

    const cleanEmail = email.trim().toLowerCase();
    const existing = users.find(u => u.email === cleanEmail);
    if (existing) {
      return res.status(409).json({
        status: 'error',
        message: 'Email sudah terdaftar. Silakan login.',
      });
    }

    // FR-01: Enkripsi Custom
    const salt = generateSalt();
    const passwordTerenkripsi = encryptPassword(password, salt);

    const newUser = {
      id: users.length + 1,
      nama: nama.trim(),
      email: cleanEmail,
      passwordTerenkripsi,
      salt,
      biometrikAktif: false,
      saldoToken: 10,
      dibuatPada: new Date().toISOString(),
    };

    users.push(newUser);

    const token = generateToken({ id: newUser.id, email: newUser.email });

    res.status(201).json({
      status: 'success',
      message: 'Registrasi berhasil.',
      data: {
        id: newUser.id,
        nama: newUser.nama,
        email: newUser.email,
        saldoToken: newUser.saldoToken,
        token,
      },
    });
  } catch (err) {
    next(err);
  }
}

async function login(req, res, next) {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        status: 'error',
        message: 'Email dan password wajib diisi.',
      });
    }

    const cleanEmail = email.trim().toLowerCase();
    const user = users.find(u => u.email === cleanEmail);

    if (!user) {
      return res.status(401).json({
        status: 'error',
        message: 'Email atau kata sandi tidak cocok.',
      });
    }

    const isValid = verifyPassword(password, user.salt, user.passwordTerenkripsi);
    if (!isValid) {
      return res.status(401).json({
        status: 'error',
        message: 'Email atau kata sandi tidak cocok.',
      });
    }

    const token = generateToken({ id: user.id, email: user.email });

    res.status(200).json({
      status: 'success',
      message: 'Login berhasil.',
      data: {
        id: user.id,
        nama: user.nama,
        email: user.email,
        saldoToken: user.saldoToken,
        token,
      },
    });
  } catch (err) {
    next(err);
  }
}

async function getProfile(req, res) {
  const user = users.find(u => u.id === req.user.id);
  if (!user) {
    return res.status(404).json({ status: 'error', message: 'Pengguna tidak ditemukan.' });
  }

  res.status(200).json({
    status: 'success',
    data: {
      id: user.id,
      nama: user.nama,
      email: user.email,
      saldoToken: user.saldoToken,
      dibuatPada: user.dibuatPada,
    },
  });
}

module.exports = {
  register,
  login,
  getProfile,
};
