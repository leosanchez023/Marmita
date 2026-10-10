import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const projectRoot = path.resolve(__dirname, '../..');
const seedFile = path.join(projectRoot, 'database', 'seed.sql');

const sql = readFileSync(seedFile, 'utf8');
if (!sql || !sql.trim()) {
  throw new Error('database/seed.sql está vazio.');
}

console.log('Arquivo de seed localizado em database/seed.sql.');
console.log('Execute esse arquivo no SQL Editor do Supabase depois de database/schema.sql.');
