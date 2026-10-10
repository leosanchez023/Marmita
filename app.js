import 'dotenv/config';

import express from 'express';
import { engine } from 'express-handlebars';
import path from 'path';
import { fileURLToPath } from 'url';
import session from 'express-session';
import flash from 'connect-flash';
import passport from 'passport';
import auth from './src/config/auth.js';
import { protegerAplicacao } from './src/config/access.js';
import supabase from './src/config/supabase.js';

import loginRoutes from './src/modules/login/login.routes.js';
import vendasRoutes from './src/modules/vendas.routes.js';
import relatoriosRoutes from './src/modules/relatorios/relatorios.routes.js';

const app = express();
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const sessionSecret = process.env.SESSION_SECRET;
if (!sessionSecret) throw new Error('SESSION_SECRET não configurado.');

app.use(session({
  secret: sessionSecret,
  resave: false,
  saveUninitialized: false,
  cookie: {
    httpOnly: true,
    sameSite: 'lax',
    secure: process.env.NODE_ENV === 'production',
    maxAge: 1000 * 60 * 60 * 8
  }
}));

auth(passport);
app.use(passport.initialize());
app.use(passport.session());
app.use(flash());

app.use((req, res, next) => {
  res.locals.user = req.user || null;
  res.locals.success_msg = req.flash('success_msg');
  res.locals.error_msg = req.flash('error_msg');
  next();
});

app.use(protegerAplicacao);
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

app.engine('handlebars', engine({
  defaultLayout: 'main',
  layoutsDir: path.join(__dirname, 'views/layouts'),
  partialsDir: path.join(__dirname, 'views/partials'),
  helpers: {
    moeda: valor => Number(valor || 0).toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' }),
    eq: (a, b) => a === b
  }
}));
app.set('view engine', 'handlebars');
app.set('views', path.join(__dirname, 'views'));
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', loginRoutes);
app.use('/vendas', vendasRoutes);
app.use('/relatorios', relatoriosRoutes);

app.use((error, req, res, next) => {
  console.error(error);
  if (res.headersSent) return next(error);
  res.status(500).send('Erro interno do servidor.');
});

const PORT = Number(process.env.PORT) || 3000;
app.listen(PORT, async () => {
  console.log(`Servidor rodando na porta ${PORT}`);

  try {
    for (const tabela of ['usuario', 'vendas', 'venda_itens']) {
      const { error } = await supabase.from(tabela).select('id').limit(1);
      if (error) {
        console.error(`Supabase acessível, mas a tabela ${tabela} não está disponível:`, error.message);
        return;
      }
    }

    console.log('Supabase conectado; tabelas de vendas acessíveis.');
  } catch (error) {
    console.error('Erro ao conectar ao Supabase:', error);
  }
});
