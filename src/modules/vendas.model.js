import db from '../../database/connection.js';

export async function listarProdutos() {
  const [rows] = await db.query(`
    SELECT id, nome, categoria, preco
    FROM produtos
    WHERE ativo = 1
    ORDER BY categoria, nome
  `);
  return rows;
}


export async function listarFormasPagamento() {
  const [rows] = await db.query(`
    SELECT id, nome
    FROM formas_pagamento
    WHERE ativo = 1
    ORDER BY id
  `);
  return rows;
}

export async function listarClientes() {
  const [rows] = await db.query(`
    SELECT id, nome, telefone
    FROM clientes
    WHERE ativo = 1
    ORDER BY nome
  `);
  return rows;
}

export async function listarVendasRecentes() {
  const [rows] = await db.query(`
    SELECT
      v.id,
      v.numero_pedido,
      DATE_FORMAT(v.data_venda, '%d/%m/%Y') AS data_venda,
      COALESCE(c.nome, 'Consumidor') AS cliente,
      v.total,
      COALESCE(fp.nome, 'Não informado') AS forma_pagamento,
      GROUP_CONCAT(
        CONCAT(p.nome, ' x', vi.quantidade)
        SEPARATOR ', '
      ) AS itens
    FROM vendas v
    LEFT JOIN clientes c ON c.id = v.cliente_id
    LEFT JOIN formas_pagamento fp ON fp.id = v.forma_pagamento_id
    JOIN venda_itens vi ON vi.venda_id = v.id
    JOIN produtos p ON p.id = vi.produto_id
    GROUP BY v.id, v.numero_pedido, v.data_venda, c.nome, v.total, fp.nome
    ORDER BY v.data_venda DESC, v.id DESC
    LIMIT 15
  `);
  return rows;
}

function valorNumero(value) {
  const n = Number(value);
  return Number.isFinite(n) ? n : 0;
}

export async function criarVenda(payload, usuarioId) {
  const conn = await db.getConnection();

  try {
    await conn.beginTransaction();

    let itens = payload.itens;

    if (typeof itens === 'string') {
      try {
        itens = JSON.parse(itens);
      } catch {
        itens = [];
      }
    }

    if (!Array.isArray(itens) || itens.length === 0) {
      // Compatibilidade com o formulário antigo de item único.
      if (payload.produto_id) {
        itens = [{
          produto_id: payload.produto_id,
          tamanho: payload.tamanho || 'UNICO',
          quantidade: payload.quantidade || 1,
          valor_unitario: payload.valor_unitario
        }];
      }
    }

    if (!itens.length) {
      throw new Error('Adicione pelo menos um item à venda.');
    }

    const adicional = Math.max(0, valorNumero(payload.adicional));
    const bebidas = Math.max(0, valorNumero(payload.bebidas));
    const frete = Math.max(0, valorNumero(payload.frete));
    const desconto = Math.max(0, valorNumero(payload.desconto));

    let subtotal = 0;
    const itensValidos = [];

    for (const item of itens) {
      const produtoId = Number(item.produto_id);
      const quantidade = Math.max(1, Number(item.quantidade || 1));

      const [produtoRows] = await conn.query(
        `SELECT id, nome, preco FROM produtos WHERE id = ? AND ativo = 1`,
        [produtoId]
      );

      if (!produtoRows.length) {
        throw new Error(`Produto ${produtoId} não encontrado.`);
      }

      const produto = produtoRows[0];
      const valorUnitario = Math.max(
        0,
        valorNumero(item.valor_unitario) || Number(produto.preco)
      );
      const itemSubtotal = quantidade * valorUnitario;

      subtotal += itemSubtotal;
      itensValidos.push({
        produtoId,
        tamanho: item.tamanho || 'UNICO',
        quantidade,
        valorUnitario,
        subtotal: itemSubtotal
      });
    }

    const total = Math.max(0, subtotal + adicional + bebidas + frete - desconto);
    const dataVenda = payload.data_venda || new Date().toISOString().slice(0, 10);

    let formaPagamentoId = payload.forma_pagamento_id
      ? Number(payload.forma_pagamento_id)
      : null;

    if (!formaPagamentoId && payload.forma_pagamento) {
      const mapa = {
        PIX: 'Pix',
        DINHEIRO: 'Dinheiro',
        CARTAO_DEBITO: 'Cartão de débito',
        CARTAO_CREDITO: 'Cartão de crédito',
        TRANSFERENCIA: 'Transferência'
      };
      const nome = mapa[payload.forma_pagamento] || payload.forma_pagamento;
      const [fp] = await conn.query(
        `SELECT id FROM formas_pagamento WHERE nome = ? LIMIT 1`,
        [nome]
      );
      formaPagamentoId = fp[0]?.id || null;
    }

    const [result] = await conn.query(`
      INSERT INTO vendas
        (data_venda, cliente_id, usuario_id, forma_pagamento_id,
         adicional, bebidas, frete, desconto, subtotal, total, observacao)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `, [
      dataVenda,
      payload.cliente_id ? Number(payload.cliente_id) : null,
      usuarioId || null,
      formaPagamentoId,
      adicional,
      bebidas,
      frete,
      desconto,
      subtotal,
      total,
      payload.observacao || null
    ]);

    const vendaId = result.insertId;
    const numeroPedido = String(vendaId).padStart(4, '0');

    await conn.query(
      `UPDATE vendas SET numero_pedido = ? WHERE id = ?`,
      [numeroPedido, vendaId]
    );

    for (const item of itensValidos) {
      await conn.query(`
        INSERT INTO venda_itens
          (venda_id, produto_id, tamanho, quantidade, valor_unitario, subtotal)
        VALUES (?, ?, ?, ?, ?, ?)
      `, [
        vendaId,
        item.produtoId,
        item.tamanho,
        item.quantidade,
        item.valorUnitario,
        item.subtotal
      ]);
    }

    await conn.commit();

    return { id: vendaId, numeroPedido, total };
  } catch (error) {
    await conn.rollback();
    throw error;
  } finally {
    conn.release();
  }
}
