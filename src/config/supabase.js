import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl) {
    throw new Error('SUPABASE_URL não configurado.');
}

if (!supabaseKey) {
    throw new Error(
        'SUPABASE_SERVICE_ROLE_KEY não configurada. A chave anon não pode gravar vendas protegidas por RLS.'
    );
}

const keyParts = supabaseKey.split('.');
let isServiceRoleKey = supabaseKey.startsWith('sb_secret_');
if (keyParts.length === 3) {
    let payload;
    try {
        payload = JSON.parse(Buffer.from(keyParts[1], 'base64url').toString('utf8'));
    } catch {
        throw new Error('SUPABASE_SERVICE_ROLE_KEY tem um formato JWT inválido.');
    }
    isServiceRoleKey = payload.role === 'service_role';
}

if (!isServiceRoleKey) {
    throw new Error(
        'SUPABASE_SERVICE_ROLE_KEY deve ser a chave secreta service_role; a chave anon não pode gravar vendas protegidas por RLS.'
    );
}

const supabase = createClient(supabaseUrl, supabaseKey);

export default supabase;
