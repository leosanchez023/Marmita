import * as model from './vendas.model.js';

export async function telaNovaVenda(req, res) {
  try {
    const [clientes, vendas, formasPagamento] = await Promise.all([
      model.listarClientes(),
      model.listarVendasRecentes(),
      model.listarFormasPagamento()
    ]);
    res.render('pages/vendas', { clientes, vendas, formasPagamento });
  } catch (error) {
    console.error(error);
    res.status(500).render('pages/vendas', { clientes: [], vendas: [], formasPagamento: [], error: 'Não foi possível carregar a página.' });
  }
}

export async function criar(req, res) {
  try {
    const venda = await model.criarVenda(req.body, req.user.id);
    res.status(201).json({ success: true, venda });
  } catch (error) {
    console.error(error);
    res.status(400).json({ success: false, message: error.message || 'Não foi possível salvar a venda.' });
  }
}

function idVendaValido(value) {
  return typeof value === 'string'
    && /^[1-9]\d*$/.test(value)
    && Number.isSafeInteger(Number(value));
}

export async function obter(req, res) {
  if (!idVendaValido(req.params.id)) {
    return res.status(400).json({ success: false, message: 'Número de venda inválido.' });
  }
  try {
    const venda = await model.obterVenda(req.params.id);
    if (!venda) return res.status(404).json({ success: false, message: 'Venda não encontrada.' });
    res.json({ success: true, venda });
  } catch (error) {
    console.error('Falha ao carregar venda para edição:', error);
    res.status(500).json({ success: false, message: 'Não foi possível carregar a venda.' });
  }
}

export async function atualizar(req, res) {
  if (!idVendaValido(req.params.id)) {
    return res.status(400).json({ success: false, message: 'Número de venda inválido.' });
  }
  try {
    const venda = await model.atualizarVenda(req.params.id, req.body);
    if (!venda) return res.status(404).json({ success: false, message: 'Venda não encontrada.' });
    res.json({ success: true, venda });
  } catch (error) {
    console.error('Falha ao atualizar venda:', error);
    res.status(400).json({ success: false, message: error.message || 'Não foi possível atualizar a venda.' });
  }
}

export async function excluir(req, res) {
  if (!idVendaValido(req.params.id)) {
    return res.status(400).json({ success: false, message: 'Número de venda inválido.' });
  }
  try {
    const excluida = await model.excluirVenda(req.params.id);
    if (!excluida) return res.status(404).json({ success: false, message: 'Venda não encontrada.' });
    res.json({ success: true });
  } catch (error) {
    console.error('Falha ao excluir venda:', error);
    res.status(500).json({ success: false, message: 'Não foi possível excluir a venda.' });
  }
}
