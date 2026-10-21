const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'TaniGreen_JWT_Secret_Super_Secure_2026';

function generateToken(payload, expiresIn = '7d') {
  return jwt.sign(payload, JWT_SECRET, { expiresIn });
}

function verifyToken(token) {
  try {
    return jwt.verify(token, JWT_SECRET);
  } catch (err) {
    return null;
  }
}

module.exports = {
  generateToken,
  verifyToken,
};
