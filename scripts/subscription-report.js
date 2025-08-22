const axios = require('axios');
require('dotenv').config();

async function screenAddress(address) {
  const apiKey = process.env.CHAINALYSIS_API_KEY;
  if (!apiKey) {
    throw new Error('Missing CHAINALYSIS_API_KEY');
  }
  try {
    const res = await axios.get(`https://public.chainalysis.com/api/v1/address/${address}`, {
      headers: { 'X-API-Key': apiKey }
    });
    if (res.data?.identifications?.length) {
      console.log(`${address} flagged`, res.data.identifications[0]);
    } else {
      console.log(`${address} clear`);
    }
  } catch (err) {
    console.error(`screening failed for ${address}`, err.response?.data || err.message);
  }
}

const addresses = process.argv.slice(2);
if (addresses.length === 0) {
  console.error('Usage: node scripts/subscription-report.js <address ...>');
  process.exit(1);
}

(async () => {
  for (const addr of addresses) {
    await screenAddress(addr);
  }
})();
