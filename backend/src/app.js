const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const complianceRoutes = require('./routes/compliance');
const kycRoutes = require('./routes/kyc');

const app = express();
app.use(helmet());
app.use(cors({ origin: '*', credentials: true }));
app.use(express.json({ limit: '10mb' }));

app.use('/api', rateLimit({ windowMs: 15 * 60 * 1000, max: 1000 }));

app.use('/api/compliance', complianceRoutes);
app.use('/api/kyc', kycRoutes);

app.get('/health', (req, res) => res.json({ status: 'ok', ts: Date.now() }));

const port = process.env.PORT || 5000;
app.listen(port, () => console.log(`\u2705 Compliance API running on ${port}`));

module.exports = app;
