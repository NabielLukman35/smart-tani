const express = require('express');
const router = express.Router();
const ghController = require('../controllers/ghController');

// FR-03: Sinkronisasi offline-first
router.post('/sync', ghController.syncOfflineData);
router.get('/greenhouses', ghController.listGreenhouses);

// FR-09: AI Assistant consultation
router.post('/ai/ask', ghController.askAiAssistant);

// FR-13: Blockchain verification
router.post('/blockchain/verify', ghController.verifyBlockchain);

module.exports = router;
