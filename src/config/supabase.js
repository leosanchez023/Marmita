import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_KEY;

if (!supabaseUrl) {
    throw new Error('SUPABASE_URL não configurado.');
}

if (!supabaseKey) {
    throw new Error('SUPABASE_SERVICE_ROLE_KEY ou SUPABASE_KEY não configurada.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

export default supabase;
