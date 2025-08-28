import fs from 'fs';
import path from 'path';

const file = process.argv[2];
if (!file) {
  console.error('Usage: node scripts/publish-to-pinata.mjs <file>');
  process.exit(1);
}

const jwt = process.env.PINATA_JWT;
if (!jwt) {
  console.error('PINATA_JWT env var required');
  process.exit(1);
}

const form = new FormData();
form.append('file', fs.createReadStream(file), path.basename(file));

const res = await fetch('https://api.pinata.cloud/pinning/pinFileToIPFS', {
  method: 'POST',
  headers: { Authorization: `Bearer ${jwt}` },
  body: form,
});

if (!res.ok) {
  console.error('Upload failed', await res.text());
  process.exit(1);
}

const json = await res.json();
console.log(json);

