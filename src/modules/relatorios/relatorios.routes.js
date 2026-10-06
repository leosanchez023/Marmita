import express from 'express';
import supabase from '../../config/supabase.js';

const router = express.Router();
const tamanhoPagina = 1000;

async function consultarTodos(consulta) {
  const registros = [];

  for (let inicio = 0; ; inicio += tamanhoPagina) {
    const { data, error } = await consulta.range(inicio, inicio + tamanhoPagina - 1);
    if (error) throw error;
    registros.push(...(data || []));
    if (!data || data.length < tamanhoPagina) return registros;
  }
}

async function consultarPorIds(tabela, colunas, campo, ids) {
  const registros = [];

  for (let inicio = 0; inicio < ids.length; inicio += 100) {
    const lote = ids.slice(inicio, inicio + 100);
    registros.push(...await consultarTodos(supabase.from(tabela).select(colunas).in(campo, lote)));
  }

  return registros;
}

const valorNumero = value => {
  const numero = Number(value);
  return Number.isFinite(numero) ? numero : 0;
};

function dataValida(value) {
  if (typeof value !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(value)) return false;
  const date = new Date(`${value}T00:00:00Z`);
  return !Number.isNaN(date.getTime()) && date.toISOString().slice(0, 10) === value;
}

function idValido(value) {
  return typeof value === 'string' && /^[1-9]\d*$/.test(value) && Number.isSafeInteger(Number(value));
}

router.get('/', (req, res) => res.render('pages/relatorios'));

router.get('/dados', async (req, res) => {
  const { inicio, fim, pagamento, produto } = req.query;

  if ((inicio && !dataValida(inicio)) || (fim && !dataValida(fim))) {
    return res.status(400).json({ success: false, message: 'Informe datas válidas no formato AAAA-MM-DD.' });
  }
  if (inicio && fim && inicio > fim) {
    return res.status(400).json({ success: false, message: 'A data inicial não pode ser posterior à data final.' });
  }
  if ((pagamento && !idValido(pagamento)) || (produto && !idValido(produto))) {
    return res.status(400).json({ success: false, message: 'Filtro inválido.' });
  }

  try {
    let consultaVendas = supabase
      .from('vw_vendas_relatorio')
      .select('id, numero_pedido, data_venda, cliente, forma_pagamento, subtotal, adicional, bebidas, frete, desconto, total, status')
      .eq('status', 'FINALIZADA');
    if (inicio) consultaVendas = consultaVendas.gte('data_venda', inicio);
    if (fim) consultaVendas = consultaVendas.lte('data_venda', fim);

    const vendasView = await consultarTodos(consultaVendas
      .order('data_venda', { ascending: false })
      .order('id', { ascending: false }));
    const idsVendas = vendasView.map(venda => venda.id);
    const [vendasBase, itensBase] = idsVendas.length
      ? await Promise.all([
        consultarPorIds('vendas', 'id, usuario_id, forma_pagamento_id', 'id', idsVendas),
        consultarPorIds('venda_itens', 'id, venda_id, produto_id, quantidade, subtotal', 'venda_id', idsVendas)
      ])
      : [[], []];

    const pagamentoPorId = new Map(vendasBase.map(venda => [venda.id, venda.forma_pagamento_id]));
    const itemPorVenda = new Map();
    for (const item of itensBase) {
      const lista = itemPorVenda.get(item.venda_id) || [];
      lista.push(item);
      itemPorVenda.set(item.venda_id, lista);
    }

    let vendasSelecionadas = vendasView.filter(venda => {
      const vendaBase = vendasBase.find(item => item.id === venda.id);
      if (pagamento && Number(vendaBase?.forma_pagamento_id) !== Number(pagamento)) return false;
      if (produto && !(itemPorVenda.get(venda.id) || []).some(item => Number(item.produto_id) === Number(produto))) return false;
      return true;
    });

    const idsSelecionados = new Set(vendasSelecionadas.map(venda => venda.id));
    const itensSelecionados = itensBase.filter(item =>
      idsSelecionados.has(item.venda_id) && (!produto || Number(item.produto_id) === Number(produto))
    );
    const idsProdutos = [...new Set(itensSelecionados.map(item => item.produto_id))];
    const idsUsuarios = [...new Set(vendasBase
      .filter(venda => idsSelecionados.has(venda.id) && venda.usuario_id)
      .map(venda => venda.usuario_id))];
    const [produtosBase, usuarios] = await Promise.all([
      idsProdutos.length ? consultarPorIds('produtos', 'id, nome', 'id', idsProdutos) : [],
      idsUsuarios.length ? consultarPorIds('usuario', 'id, nome', 'id', idsUsuarios) : []
    ]);
    const nomeProduto = new Map(produtosBase.map(item => [item.id, item.nome]));
    const nomeUsuario = new Map(usuarios.map(item => [item.id, item.nome]));
    const usuarioPorVenda = new Map(vendasBase.map(venda => [venda.id, venda.usuario_id]));

    const totalVendido = vendasSelecionadas.reduce((soma, venda) => soma + valorNumero(venda.total), 0);
    const resumo = {
      total_vendido: totalVendido,
      total_pedidos: vendasSelecionadas.length,
      ticket_medio: vendasSelecionadas.length ? totalVendido / vendasSelecionadas.length : 0,
      total_fretes: vendasSelecionadas.reduce((soma, venda) => soma + valorNumero(venda.frete), 0),
      total_bebidas: vendasSelecionadas.reduce((soma, venda) => soma + valorNumero(venda.bebidas), 0),
      total_descontos: vendasSelecionadas.reduce((soma, venda) => soma + valorNumero(venda.desconto), 0),
      qtd_produtos_vendidos: itensSelecionados.reduce((soma, item) => soma + valorNumero(item.quantidade), 0)
    };

    const vendasPorDiaMapa = new Map();
    const pagamentosMapa = new Map();
    for (const venda of vendasSelecionadas) {
      const dia = String(venda.data_venda).slice(0, 10);
      vendasPorDiaMapa.set(dia, (vendasPorDiaMapa.get(dia) || 0) + valorNumero(venda.total));
      const forma = venda.forma_pagamento || 'Não informado';
      const pagamentoAtual = pagamentosMapa.get(forma) || { forma_pagamento: forma, pedidos: 0, total: 0 };
      pagamentoAtual.pedidos++;
      pagamentoAtual.total += valorNumero(venda.total);
      pagamentosMapa.set(forma, pagamentoAtual);
    }
    const vendasPorDia = [...vendasPorDiaMapa]
      .map(([data, total]) => ({ data, total }))
      .sort((a, b) => a.data.localeCompare(b.data));
    const pagamentos = [...pagamentosMapa.values()].sort((a, b) => b.total - a.total);

    const produtosMapa = new Map();
    for (const item of itensSelecionados) {
      const nome = nomeProduto.get(item.produto_id) || 'Produto';
      const produtoAtual = produtosMapa.get(item.produto_id) || { nome, quantidade: 0, total: 0 };
      produtoAtual.quantidade += valorNumero(item.quantidade);
      produtoAtual.total += valorNumero(item.subtotal);
      produtosMapa.set(item.produto_id, produtoAtual);
    }
    const produtos = [...produtosMapa.values()]
      .sort((a, b) => b.quantidade - a.quantidade || b.total - a.total)
      .slice(0, 10);

    const vendas = vendasSelecionadas.map(venda => {
      const itens = itemPorVenda.get(venda.id) || [];
      return {
        numero_pedido: venda.numero_pedido,
        data: dataBr(venda.data_venda),
        cliente: venda.cliente || 'Consumidor',
        responsavel: nomeUsuario.get(usuarioPorVenda.get(venda.id)) || 'Não informado',
        quantidade_itens: itens.reduce((soma, item) => soma + valorNumero(item.quantidade), 0),
        total: venda.total,
        forma_pagamento: venda.forma_pagamento || 'Não informado',
        status: venda.status
      };
    });

    res.json({
      success: true,
      resumo,
      vendasPorDia,
      pagamentos,
      produtos,
      vendas
    });
  } catch (error) {
    console.error('Falha ao gerar relatório:', error);
    res.status(500).json({ success: false, message: 'Erro ao gerar relatório.' });
  }
});

function dataBr(value) {
  if (!value) return '';
  const [ano, mes, dia] = String(value).slice(0, 10).split('-');
  return `${dia}/${mes}/${ano}`;
}

router.get('/opcoes', async (req, res) => {
  try {
    const [produtos, pagamentos] = await Promise.all([
      consultarTodos(supabase.from('produtos').select('id, nome').eq('ativo', true).order('nome')),
      consultarTodos(supabase.from('formas_pagamento').select('id, nome').eq('ativo', true).order('id'))
    ]);
    res.json({ produtos, pagamentos });
  } catch (error) {
    console.error('Falha ao carregar filtros do relatório:', error);
    res.status(500).json({ success: false, message: 'Não foi possível carregar os filtros.' });
  }
});

export default router;
