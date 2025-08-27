const express = require('express');
const router = express.Router();

router.post('/check', (req, res) => {
  res.json({ kyc: 'pending', user: req.body });
});

module.exports = router;
