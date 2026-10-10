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
