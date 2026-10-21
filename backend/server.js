require('dotenv').config();
const app = require('./src/app');

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`=======================================================`);
  console.log(` 🌱 Smart Tani (TaniGreen) Backend Server`);
  console.log(` 🚀 Berjalan di http://localhost:${PORT}`);
  console.log(` 📡 Android Emulator: http://10.0.2.2:${PORT}/api`);
  console.log(`=======================================================`);
});
