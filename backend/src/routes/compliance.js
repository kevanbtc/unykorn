const express = require('express');
const router = express.Router();

router.post('/report', (req, res) => {
  res.json({ status: 'received', data: req.body });
});

module.exports = router;
