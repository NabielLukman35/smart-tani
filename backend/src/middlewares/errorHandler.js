function errorHandler(err, req, res, next) {
  console.error('Server Error:', err);
  const statusCode = err.statusCode || 500;
  res.status(statusCode).json({
    status: 'error',
    message: err.message || 'Terjadi kesalahan internal pada server.',
  });
}

module.exports = errorHandler;
