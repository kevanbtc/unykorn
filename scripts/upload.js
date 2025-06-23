const pinataSDK = require('@pinata/sdk');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const pinata = new pinataSDK(process.env.PINATA_API_KEY, process.env.PINATA_SECRET);

async function uploadMetadata(filePath) {
  const metadata = JSON.parse(fs.readFileSync(filePath));
  const { IpfsHash } = await pinata.pinJSONToIPFS(metadata);
  console.log('Pinned:', IpfsHash);
}

if (require.main === module) {
  if (!process.argv[2]) throw new Error('Provide metadata file');
  uploadMetadata(path.resolve(process.argv[2]));
}

module.exports = uploadMetadata;
