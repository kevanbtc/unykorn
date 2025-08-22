const axios = require('axios');
require('dotenv').config();

async function screenAddress(address) {
  const apiKey = process.env.CHAINALYSIS_API_KEY;
  const apiUrl = process.env.CHAINALYSIS_API_URL || 'https://public.chainalysis.com/api/v1/address';

  if (process.env.MOCK_KYT === 'true' || !apiKey) {
    console.log(`\u{1F512} MOCK KYT screening for ${address} \u2192 low risk`);
    return { risk: 'low' };
  }

  try {
    const res = await axios.get(`${apiUrl}/${address}`, {
      headers: { 'X-API-Key': apiKey }
    });
    if (res.data?.identifications?.length) {
      console.log(`${address} flagged`, res.data.identifications[0]);
    } else {
      console.log(`${address} clear`);
    }
    return res.data;
  } catch (err) {
    console.error(`screening failed for ${address}`, err.response?.data || err.message);
    return { risk: 'unknown' };
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
