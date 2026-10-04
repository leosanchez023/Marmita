import express from 'express';
import db from '../../../database/connection.js';

const router = express.Router();

router.get('/', (req, res) => res.render('pages/relatorios'));

router.get('/dados', async (req, res) => {
  try {
    const { inicio, fim, pagamento, produto } = req.query;
    const params = [];
    const where = [];

    if (inicio) { where.push('v.data_venda >= ?'); params.push(inicio); }
    if (fim) { where.push('v.data_venda <= ?'); params.push(fim); }
    if (pagamento) { where.push('v.forma_pagamento_id = ?'); params.push(Number(pagamento)); }
    if (produto) { where.push('vi.produto_id = ?'); params.push(Number(produto)); }

    const condition = where.length ? `WHERE ${where.join(' AND ')}` : '';

    const [resumo] = await db.query(`
      SELECT
        COALESCE(SUM(v.total), 0) total_vendido,
        COUNT(DISTINCT v.id) total_pedidos,
        COALESCE(SUM(vi.quantidade), 0) qtd_marmitas,
        COALESCE(SUM(v.frete), 0) total_fretes,
        COALESCE(SUM(v.bebidas), 0) total_bebidas,
        COALESCE(SUM(v.desconto), 0) total_descontos
      FROM vendas v
      JOIN venda_itens vi ON vi.venda_id = v.id
      ${condition}
    `, params);

    const [vendasPorDia] = await db.query(`
      SELECT DATE_FORMAT(v.data_venda, '%Y-%m-%d') data, SUM(v.total) total
      FROM vendas v
      JOIN venda_itens vi ON vi.venda_id = v.id
      ${condition}
      GROUP BY v.data_venda ORDER BY v.data_venda
    `, params);

    const [pagamentos] = await db.query(`
      SELECT COALESCE(fp.nome, 'Não informado') AS forma_pagamento, COUNT(DISTINCT v.id) pedidos, SUM(v.total) total
      FROM vendas v
      LEFT JOIN formas_pagamento fp ON fp.id = v.forma_pagamento_id
      JOIN venda_itens vi ON vi.venda_id = v.id
      ${condition}
      GROUP BY v.forma_pagamento ORDER BY total DESC
    `, params);

    const [produtos] = await db.query(`
      SELECT p.nome, SUM(vi.quantidade) quantidade, SUM(vi.subtotal) total
      FROM vendas v
      JOIN venda_itens vi ON vi.venda_id = v.id
      JOIN produtos p ON p.id = vi.produto_id
      ${condition}
      GROUP BY p.id, p.nome ORDER BY quantidade DESC, total DESC
      LIMIT 10
    `, params);

    const [vendas] = await db.query(`
      SELECT v.numero_pedido, DATE_FORMAT(v.data_venda, '%d/%m/%Y') data, COALESCE(c.nome, 'Consumidor') cliente,
             v.total, COALESCE(fp.nome, 'Não informado') AS forma_pagamento
      FROM vendas v
      LEFT JOIN clientes c ON c.id = v.cliente_id
      LEFT JOIN formas_pagamento fp ON fp.id = v.forma_pagamento_id
      JOIN venda_itens vi ON vi.venda_id = v.id
      ${condition}
      GROUP BY v.id ORDER BY v.data_venda DESC, v.id DESC
    `, params);

    res.json({ success: true, resumo: resumo[0], vendasPorDia, pagamentos, produtos, vendas });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Erro ao gerar relatório.' });
  }
});

router.get('/opcoes', async (req, res) => {
  const [produtos] = await db.query(`SELECT id, nome FROM produtos WHERE ativo = 1 ORDER BY nome`);
  const [pagamentos] = await db.query(`SELECT id, nome FROM formas_pagamento WHERE ativo = 1 ORDER BY id`);
  res.json({ produtos, pagamentos });
});

export default router;
