import express from 'express';
import { generateFinancialModel } from '../ai_agents/financialModel';
const router = express.Router();

router.post('/', (req, res) => {
  const model = generateFinancialModel(req.body);
  res.json(model);
});

export default router;
