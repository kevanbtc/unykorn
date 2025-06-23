const express = require('express');
const { create } = require('ipfs-http-client');
const axios = require('axios');
require('dotenv').config();

const app = express();
app.use(express.json());

const ipfs = create({ url: process.env.IPFS_URL || 'https://ipfs.infura.io:5001/api/v0' });

app.post('/report', async (req, res) => {
  try {
    const { data, location } = req.body;
    const { path } = await ipfs.add(JSON.stringify(data));
    // TODO: call AI model to validate
    console.log('Uploaded to IPFS:', path);
    res.json({ ipfsHash: path, location });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'upload failed' });
  }
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Backend listening on port ${port}`);
});
