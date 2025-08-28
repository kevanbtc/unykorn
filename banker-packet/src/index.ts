import fs from 'fs';
import PDFDocument from 'pdfkit';
import yargs from 'yargs';
import { hideBin } from 'yargs/helpers';

interface Config {
  title: string;
  ein: string;
  appraisalValue: number;
  proofOfReservesCid: string;
  glacierCid: string;
  creditScore: string;
}

const argv = yargs(hideBin(process.argv))
  .option('config', { type: 'string', demandOption: true })
  .option('out', { type: 'string', default: 'banker-packet.pdf' })
  .parseSync();

const cfg: Config = JSON.parse(fs.readFileSync(argv.config, 'utf8'));

const doc = new PDFDocument();
const outStream = fs.createWriteStream(argv.out);
doc.pipe(outStream);

doc.fontSize(20).text(cfg.title, { align: 'center' });
doc.moveDown();
doc.fontSize(12).text(`EIN: ${cfg.ein}`);
doc.moveDown();
doc.fontSize(12).text(`Appraisal Value: $${cfg.appraisalValue.toLocaleString()}`);
doc.text(`Proof of Reserves CID: ${cfg.proofOfReservesCid}`);
doc.text(`Glacier CID: ${cfg.glacierCid}`);
doc.text(`Credit Score: ${cfg.creditScore}`);

doc.end();

outStream.on('finish', () => {
  console.log(`Generated ${argv.out}`);
});
