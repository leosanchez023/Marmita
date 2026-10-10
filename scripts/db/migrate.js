import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const projectRoot = path.resolve(__dirname, '../..');
const schemaFile = 'schema.sql';

const schemaPath = path.join(projectRoot, 'database', schemaFile);
const sql = readFileSync(schemaPath, 'utf8');
if (!sql.trim()) {
  throw new Error(`Arquivo de schema vazio: ${schemaFile}`);
}

console.log(`Schema Supabase/PostgreSQL: ${path.relative(projectRoot, schemaPath)}`);
console.log('Execute esse arquivo no SQL Editor do Supabase para criar/atualizar a estrutura.');
