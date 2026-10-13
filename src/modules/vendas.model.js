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
      .select('venda_id, quantidade')
      .in('venda_id', ids))
    : [];
  const quantidadePorVenda = new Map();

  for (const item of itens) {
    quantidadePorVenda.set(
      item.venda_id,
      (quantidadePorVenda.get(item.venda_id) || 0) + Number(item.quantidade || 0)
    );
  }

  return vendas.map(venda => ({
    ...venda,
    data_venda: dataBr(venda.data_venda),
    cliente: venda.cliente || 'Consumidor',
    forma_pagamento: venda.forma_pagamento || 'Não informado',
    quantidade_itens: quantidadePorVenda.get(venda.id) || 0
  }));
}

function dataBr(value) {
  if (!value) return '';
  const [ano, mes, dia] = value.slice(0, 10).split('-');
  return `${dia}/${mes}/${ano}`;
}

function valorNumero(value) {
  if (value === undefined || value === null || value === '') return 0;
  const n = Number(value);
  if (!Number.isFinite(n) || n > 99999999.99) {
    throw new Error('Informe um valor válido para os campos da venda.');
  }
  return Math.round(n * 100) / 100;
}

export async function obterVenda(id) {
  const { data: venda, error: vendaError } = await supabase
    .from('vendas')
    .select('id, numero_pedido, data_venda, cliente_id, forma_pagamento_id, adicional, bebidas, frete, desconto, observacao')
    .eq('id', id)
    .maybeSingle();
  if (vendaError) throw vendaError;
  if (!venda) return null;

  const { data: itens, error: itensError } = await supabase
    .from('venda_itens')
    .select('tamanho, quantidade, valor_unitario')
    .eq('venda_id', id)
    .order('id');
  if (itensError) throw itensError;

  const [clienteResult, pagamentoResult] = await Promise.all([
    venda.cliente_id
      ? supabase.from('clientes').select('nome').eq('id', venda.cliente_id).maybeSingle()
      : Promise.resolve({ data: null, error: null }),
    venda.forma_pagamento_id
      ? supabase.from('formas_pagamento').select('nome').eq('id', venda.forma_pagamento_id).maybeSingle()
      : Promise.resolve({ data: null, error: null })
  ]);
  if (clienteResult.error) throw clienteResult.error;
  if (pagamentoResult.error) throw pagamentoResult.error;

  return {
    ...venda,
    cliente_nome: clienteResult.data?.nome || null,
    forma_pagamento_nome: pagamentoResult.data?.nome || null,
    itens: itens || []
  };
}

export async function atualizarVenda(id, payload) {
  let itens = payload.itens;
  if (typeof itens === 'string') {
    try {
      itens = JSON.parse(itens);
    } catch {
      throw new Error('A lista de itens da venda é inválida.');
    }
  }
  if (!Array.isArray(itens) || itens.length === 0) {
    throw new Error('Adicione pelo menos um item à venda.');
  }

  const tamanhosPermitidos = new Set(['P', 'M', 'G', 'E', 'S', 'UNICO']);
  const itensValidos = itens.map(item => {
    if (!item || typeof item !== 'object') throw new Error('Um dos itens da venda é inválido.');
    const quantidade = Number(item.quantidade);
    const valorUnitario = Number(item.valor_unitario);
    if (!tamanhosPermitidos.has(item.tamanho)) throw new Error('Selecione um tamanho válido para cada item.');
    if (!Number.isSafeInteger(quantidade) || quantidade < 1 || quantidade > 4294967295) {
      throw new Error('A quantidade de cada item deve ser um inteiro maior que zero.');
    }
    if (!Number.isFinite(valorUnitario) || valorUnitario < 0 || valorUnitario > 99999999.99) {
      throw new Error('O preço de cada item deve ser um valor válido e não negativo.');
    }
    const precoArredondado = Math.round(valorUnitario * 100) / 100;
    const subtotal = Math.round(quantidade * precoArredondado * 100) / 100;
    if (!Number.isFinite(subtotal) || subtotal > 99999999.99) {
      throw new Error('O subtotal de cada item excede o limite permitido.');
    }
    return { tamanho: item.tamanho, quantidade, valor_unitario: precoArredondado, subtotal };
  });
  const subtotal = Math.round(itensValidos.reduce((soma, item) => soma + item.subtotal, 0) * 100) / 100;
  if (subtotal > 99999999.99) throw new Error('O subtotal da venda excede o limite permitido.');

  const adicional = Math.max(0, valorNumero(payload.adicional));
  const bebidas = Math.max(0, valorNumero(payload.bebidas));
  const frete = Math.max(0, valorNumero(payload.frete));
  const desconto = Math.max(0, valorNumero(payload.desconto));
  const total = Math.round(Math.max(0, subtotal + adicional + bebidas + frete - desconto) * 100) / 100;
  if (total > 99999999.99) throw new Error('O total da venda excede o limite permitido.');

  const valoresVenda = {
    data_venda: payload.data_venda,
    cliente_id: payload.cliente_id ? Number(payload.cliente_id) : null,
    forma_pagamento_id: payload.forma_pagamento_id ? Number(payload.forma_pagamento_id) : null,
    adicional,
    bebidas,
    frete,
    desconto,
    subtotal,
    total,
    observacao: payload.observacao || null
  };
  const { data: vendaOriginal, error: vendaOriginalError } = await supabase
    .from('vendas')
    .select('id, data_venda, cliente_id, forma_pagamento_id, adicional, bebidas, frete, desconto, subtotal, total, observacao')
    .eq('id', id)
    .maybeSingle();
  if (vendaOriginalError) throw vendaOriginalError;
  if (!vendaOriginal) return null;

  const { data: itensOriginais, error: itensOriginaisError } = await supabase
    .from('venda_itens')
    .select('tamanho, quantidade, valor_unitario, subtotal')
    .eq('venda_id', id);
  if (itensOriginaisError) throw itensOriginaisError;

  const { error: apagarItensError } = await supabase.from('venda_itens').delete().eq('venda_id', id);
  if (apagarItensError) throw apagarItensError;

  const novosItens = itensValidos.map(item => ({ ...item, venda_id: id }));
  const { error: inserirItensError } = await supabase.from('venda_itens').insert(novosItens);
  if (inserirItensError) {
    const { error: restaurarItensError } = await supabase
      .from('venda_itens')
      .insert((itensOriginais || []).map(item => ({ ...item, venda_id: id })));
    if (restaurarItensError) console.error('Não foi possível restaurar os itens da venda:', restaurarItensError);
    throw inserirItensError;
  }

  const { error: atualizarVendaError } = await supabase.from('vendas').update(valoresVenda).eq('id', id);
  if (atualizarVendaError) {
    const { error: apagarNovosError } = await supabase.from('venda_itens').delete().eq('venda_id', id);
    if (apagarNovosError) console.error('Não foi possível desfazer os novos itens da venda:', apagarNovosError);
    const { error: restaurarItensError } = await supabase
      .from('venda_itens')
      .insert((itensOriginais || []).map(item => ({ ...item, venda_id: id })));
    if (restaurarItensError) console.error('Não foi possível restaurar os itens da venda:', restaurarItensError);
    throw atualizarVendaError;
  }

  return { id, total };
}

export async function excluirVenda(id) {
  const { data, error } = await supabase
    .from('vendas')
    .delete()
    .eq('id', id)
    .select('id')
    .maybeSingle();
  if (error) throw error;
  return Boolean(data);
}

export async function criarVenda(payload, usuarioId) {
  let vendaId;

  try {
    let itens = payload.itens;
    if (typeof itens === 'string') {
      try {
        itens = JSON.parse(itens);
      } catch {
        throw new Error('A lista de itens da venda é inválida.');
      }
    }
    if (!Array.isArray(itens) || itens.length === 0) {
      throw new Error('Adicione pelo menos um item à venda.');
    }

    const tamanhosPermitidos = new Set(['P', 'M', 'G', 'E', 'S', 'UNICO']);
    const itensValidos = itens.map(item => {
      if (!item || typeof item !== 'object') {
        throw new Error('Um dos itens da venda é inválido.');
      }
      const quantidade = Number(item.quantidade);
      const valorUnitario = Number(item.valor_unitario);
      if (!tamanhosPermitidos.has(item.tamanho)) {
        throw new Error('Selecione um tamanho válido para cada item.');
      }
      if (!Number.isSafeInteger(quantidade) || quantidade < 1 || quantidade > 4294967295) {
        throw new Error('A quantidade de cada item deve ser um inteiro maior que zero.');
      }
      if (!Number.isFinite(valorUnitario) || valorUnitario < 0 || valorUnitario > 99999999.99) {
        throw new Error('O preço de cada item deve ser um valor válido e não negativo.');
      }
      const precoArredondado = Math.round(valorUnitario * 100) / 100;
      const subtotalItem = Math.round(quantidade * precoArredondado * 100) / 100;
      if (!Number.isFinite(subtotalItem) || subtotalItem > 99999999.99) {
        throw new Error('O subtotal de cada item excede o limite permitido.');
      }
      return {
        tamanho: item.tamanho,
        quantidade,
        valorUnitario: precoArredondado,
        subtotal: subtotalItem
      };
    });
    const subtotal = Math.round(itensValidos.reduce((soma, item) => soma + item.subtotal, 0) * 100) / 100;
    if (subtotal > 99999999.99) {
      throw new Error('O subtotal da venda excede o limite permitido.');
    }
    const adicional = Math.max(0, valorNumero(payload.adicional));
    const bebidas = Math.max(0, valorNumero(payload.bebidas));
    const frete = Math.max(0, valorNumero(payload.frete));
    const desconto = Math.max(0, valorNumero(payload.desconto));
    const total = Math.round(Math.max(0, subtotal + adicional + bebidas + frete - desconto) * 100) / 100;
    if (total > 99999999.99) {
      throw new Error('O total da venda excede o limite permitido.');
    }
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

    const { error: itensError } = await supabase.from('venda_itens').insert(
      itensValidos.map(item => ({
        venda_id: vendaId,
        tamanho: item.tamanho,
        quantidade: item.quantidade,
        valor_unitario: item.valorUnitario,
        subtotal: item.subtotal
      }))
    );
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
