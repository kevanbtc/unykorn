import express from 'express';
import funding from '../../funding.json';

const app = express();

app.get('/api/funding', (_req, res) => {
  res.json(funding);
});

export default app;

if (require.main === module) {
  const port = process.env.PORT || 3001;
  app.listen(port, () => {
    console.log(`Backend running on port ${port}`);
  });
}
