import supabase from '../config/supabase.js';

async function consultarTodos(consulta) {
  const registros = [];
  const tamanhoPagina = 1000;

  for (let inicio = 0; ; inicio += tamanhoPagina) {
    const { data, error } = await consulta.range(inicio, inicio + tamanhoPagina - 1);
    if (error) throw error;
    registros.push(...(data || []));
    if (!data || data.length < tamanhoPagina) return registros;
  }
}

export async function listarProdutos() {
  return consultarTodos(supabase
    .from('produtos')
    .select('id, nome, categoria, preco')
    .eq('ativo', true)
    .order('categoria')
    .order('nome'));
}


export async function listarFormasPagamento() {
  return consultarTodos(supabase
    .from('formas_pagamento')
    .select('id, nome')
    .eq('ativo', true)
    .order('id'));
}

export async function listarClientes() {
  return consultarTodos(supabase
    .from('clientes')
    .select('id, nome, telefone')
    .eq('ativo', true)
    .order('nome'));
}

export async function listarVendasRecentes() {
  const vendas = await consultarTodos(supabase
    .from('vw_vendas_relatorio')
    .select('id, numero_pedido, data_venda, cliente, forma_pagamento, total')
    .order('data_venda', { ascending: false })
    .order('id', { ascending: false })
    .limit(15));
  const ids = vendas.map(venda => venda.id);
  const itens = ids.length
    ? await consultarTodos(supabase
      .from('venda_itens')
      .select('venda_id, quantidade, produto_id')
      .in('venda_id', ids))
    : [];
  const produtoIds = [...new Set(itens.map(item => item.produto_id))];
  const produtos = produtoIds.length
    ? await consultarTodos(supabase.from('produtos').select('id, nome').in('id', produtoIds))
    : [];
  const nomes = new Map(produtos.map(produto => [produto.id, produto.nome]));
  const itensPorVenda = new Map();

  for (const item of itens) {
    const lista = itensPorVenda.get(item.venda_id) || [];
    lista.push(`${nomes.get(item.produto_id) || 'Produto'} x${item.quantidade}`);
    itensPorVenda.set(item.venda_id, lista);
  }

  return vendas.map(venda => ({
    ...venda,
    data_venda: dataBr(venda.data_venda),
    cliente: venda.cliente || 'Consumidor',
    forma_pagamento: venda.forma_pagamento || 'Não informado',
    itens: (itensPorVenda.get(venda.id) || []).join(', ')
  }));
}

function dataBr(value) {
  if (!value) return '';
  const [ano, mes, dia] = value.slice(0, 10).split('-');
  return `${dia}/${mes}/${ano}`;
}

function valorNumero(value) {
  const n = Number(value);
  return Number.isFinite(n) ? n : 0;
}

export async function criarVenda(payload, usuarioId) {
  let vendaId;

  try {
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

      const { data: produto, error: produtoError } = await supabase
        .from('produtos')
        .select('id, nome, preco')
        .eq('id', produtoId)
        .eq('ativo', true)
        .maybeSingle();

      if (produtoError) throw produtoError;
      if (!produto) {
        throw new Error(`Produto ${produtoId} não encontrado.`);
      }

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
      const { data: formaPagamento, error: pagamentoError } = await supabase
        .from('formas_pagamento')
        .select('id')
        .eq('nome', nome)
        .maybeSingle();
      if (pagamentoError) throw pagamentoError;
      formaPagamentoId = formaPagamento?.id || null;
    }

    const { data: venda, error: vendaError } = await supabase
      .from('vendas')
      .insert({
        data_venda: dataVenda,
        cliente_id: payload.cliente_id ? Number(payload.cliente_id) : null,
        usuario_id: usuarioId || null,
        forma_pagamento_id: formaPagamentoId,
        adicional,
        bebidas,
        frete,
        desconto,
        subtotal,
        total,
        observacao: payload.observacao || null
      })
      .select('id')
      .single();
    if (vendaError) throw vendaError;
    vendaId = venda.id;
    const numeroPedido = String(vendaId).padStart(4, '0');

    const { error: numeroError } = await supabase
      .from('vendas')
      .update({ numero_pedido: numeroPedido })
      .eq('id', vendaId);
    if (numeroError) throw numeroError;

    const itensVenda = itensValidos.map(item => ({
      venda_id: vendaId,
      produto_id: item.produtoId,
      tamanho: item.tamanho,
      quantidade: item.quantidade,
      valor_unitario: item.valorUnitario,
      subtotal: item.subtotal
    }));
    const { error: itensError } = await supabase.from('venda_itens').insert(itensVenda);
    if (itensError) throw itensError;

    return { id: vendaId, numeroPedido, total };
  } catch (error) {
    if (vendaId) {
      const { error: rollbackError } = await supabase.from('vendas').delete().eq('id', vendaId);
      if (rollbackError) console.error('Não foi possível desfazer a venda incompleta:', rollbackError);
    }
    throw error;
  }
}
