const express = require('express');
const app = express();
app.use(express.json());

app.get('/', (_req, res) => {
  res.send('FTH backend placeholder');
});

module.exports = app;

if (require.main === module) {
  const port = process.env.PORT || 3001;
  app.listen(port, () => console.log(`Backend listening on ${port}`));
}
