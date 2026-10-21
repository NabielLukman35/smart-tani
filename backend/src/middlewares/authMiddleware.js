const { verifyToken } = require('../utils/jwt');

function authenticate(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      status: 'error',
      message: 'Akses ditolak. Token otorisasi tidak ditemukan.',
    });
  }

  const token = authHeader.split(' ')[1];
  const decoded = verifyToken(token);
  if (!decoded) {
    return res.status(401).json({
      status: 'error',
      message: 'Token otorisasi tidak valid atau telah kedaluwarsa.',
    });
  }

  req.user = decoded;
  next();
}

module.exports = authenticate;
