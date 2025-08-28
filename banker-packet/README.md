# Banker Packet CLI

Generates a banker packet PDF from appraisal and proof-of-reserves data.

## Usage

```bash
npm install
npm run build
node dist/index.js --config sample.config.json --out banker-packet.pdf
```

The CLI is also available as a container:

```bash
docker build -t banker-packet banker-packet
docker run --rm -v $(pwd)/banker-packet:/data banker-packet --config /data/sample.config.json --out /data/output.pdf
```

## Entity Configs

Sample configurations for different entities live in the repo's `entities/` directory. Each config includes an `ein` and related appraisal data. The directory currently contains placeholder configs for:

- `holding.json`
- `finance.json`
- `education.json`
- `otc.json`
- `energy.json`
- `ip.json`
- `spv_mfg.json`
- `spv_energy.json`
- `trust.json`
- `foundation.json`

Use any of these files to generate a packet:

```bash
node dist/index.js --config ../entities/holding.json --out holding.pdf
```
