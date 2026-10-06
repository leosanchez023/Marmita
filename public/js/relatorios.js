const numero = value => Number.isFinite(Number(value)) ? Number(value) : 0;
const brl = value => numero(value).toLocaleString('pt-BR', { style:'currency', currency:'BRL' });
const esc = value => String(value ?? '').replace(/[&<>'"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;',"'":'&#39;','"':'&quot;'}[c]));

const dataLocal = date => `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;

function definirPeriodo(periodo) {
  const hoje = new Date();
  const inicio = new Date(hoje.getFullYear(), hoje.getMonth(), hoje.getDate());
  const fim = new Date(inicio);

  if (periodo === 'ontem') {
    inicio.setDate(inicio.getDate() - 1);
    fim.setDate(fim.getDate() - 1);
  } else if (periodo === '7dias') {
    inicio.setDate(inicio.getDate() - 6);
  } else if (periodo === '30dias') {
    inicio.setDate(inicio.getDate() - 29);
  } else if (periodo === 'mes') {
    inicio.setDate(1);
  } else if (periodo === 'mesAnterior') {
    inicio.setFullYear(inicio.getFullYear(), inicio.getMonth() - 1, 1);
    fim.setDate(0);
  }

  document.getElementById('inicio').value = dataLocal(inicio);
  document.getElementById('fim').value = dataLocal(fim);
}

function mostrarMensagem(texto, erro = false) {
  const mensagem = document.getElementById('relatorioMensagem');
  mensagem.textContent = texto;
  mensagem.hidden = !texto;
  mensagem.classList.toggle('error', erro);
}

async function carregarOpcoes() {
  const res = await fetch('/relatorios/opcoes');
  const data = await res.json();
  if (!res.ok || data.success === false) throw new Error(data.message || 'Não foi possível carregar os filtros.');
  const select = document.getElementById('produto');
  (data.produtos || []).forEach(p => select.insertAdjacentHTML('beforeend', `<option value="${p.id}">${esc(p.nome)}</option>`));

  const pagamento = document.getElementById('pagamento');
  pagamento.innerHTML = '<option value="">Todos</option>';
  (data.pagamentos || []).forEach(p => {
    pagamento.insertAdjacentHTML('beforeend', `<option value="${p.id}">${esc(p.nome)}</option>`);
  });
}

function render(data) {
  const r = data.resumo || {};
  document.getElementById('totalVendido').textContent = brl(r.total_vendido);
  document.getElementById('totalPedidos').textContent = numero(r.total_pedidos);
  document.getElementById('qtdMarmitas').textContent = numero(r.qtd_produtos_vendidos);
  document.getElementById('ticketMedio').textContent = brl(r.ticket_medio);
  document.getElementById('totalFretes').textContent = brl(r.total_fretes);
  document.getElementById('totalBebidas').textContent = brl(r.total_bebidas);
  document.getElementById('totalDescontos').textContent = brl(r.total_descontos);

  const day = document.getElementById('vendasDia');
  const vendasPorDia = Array.isArray(data.vendasPorDia) ? data.vendasPorDia : [];
  if (!vendasPorDia.length) day.innerHTML = '<div class="empty">Sem dados no período.</div>';
  else {
    const max = Math.max(...vendasPorDia.map(x => numero(x.total)), 1);
    day.innerHTML = vendasPorDia.map(x => `<div class="bar-item"><div class="bar-value">${brl(x.total)}</div><div class="bar" style="height:${Math.max(8, numero(x.total) / max * 180)}px"></div><small>${new Date(`${x.data}T12:00:00`).toLocaleDateString('pt-BR',{day:'2-digit',month:'2-digit'})}</small></div>`).join('');
  }

  const pagamentos = Array.isArray(data.pagamentos) ? data.pagamentos : [];
  const produtos = Array.isArray(data.produtos) ? data.produtos : [];
  const vendas = Array.isArray(data.vendas) ? data.vendas : [];
  document.getElementById('pagamentosBody').innerHTML = pagamentos.length ? pagamentos.map(x => `<tr><td>${esc(x.forma_pagamento)}</td><td>${numero(x.pedidos)}</td><td>${brl(x.total)}</td></tr>`).join('') : '<tr><td colspan="3" class="empty">Sem dados.</td></tr>';
  document.getElementById('produtosBody').innerHTML = produtos.length ? produtos.map(x => `<tr><td>${esc(x.nome)}</td><td>${numero(x.quantidade)}</td><td>${brl(x.total)}</td></tr>`).join('') : '<tr><td colspan="3" class="empty">Sem dados.</td></tr>';
  document.getElementById('vendasBody').innerHTML = vendas.length ? vendas.map(x => `<tr><td>#${esc(x.numero_pedido || '')}</td><td>${esc(x.data || '')}</td><td>${esc(x.cliente)}</td><td>${esc(x.responsavel)}</td><td>${esc(x.forma_pagamento)}</td><td>${numero(x.quantidade_itens)}</td><td>${brl(x.total)}</td><td>${esc(x.status)}</td></tr>`).join('') : '<tr><td colspan="8" class="empty">Sem dados.</td></tr>';
  document.getElementById('vendasCount').textContent = `${vendas.length} venda(s)`;

  const semVendas = numero(r.total_pedidos) === 0;
  mostrarMensagem(semVendas ? 'Nenhuma venda encontrada para o período selecionado.' : '');
}

async function gerarRelatorios() {
  const periodo = document.getElementById('periodo').value;
  if (periodo === 'personalizado' && (!document.getElementById('inicio').value || !document.getElementById('fim').value)) {
    mostrarMensagem('Informe a data inicial e a data final do período personalizado.', true);
    return;
  }

  const qs = new URLSearchParams();
  ['inicio','fim','pagamento','produto'].forEach(id => { const v = document.getElementById(id).value; if (v) qs.set(id, v); });
  const botao = document.getElementById('filtrar');
  botao.disabled = true;
  try {
    const res = await fetch(`/relatorios/dados?${qs}`);
    const data = await res.json();
    if (!res.ok || !data.success) throw new Error(data.message || 'Não foi possível gerar o relatório.');
    render(data);
  } catch (error) {
    mostrarMensagem(error.message || 'Não foi possível gerar o relatório.', true);
  } finally {
    botao.disabled = false;
  }
}

document.getElementById('filtrar')?.addEventListener('click', gerarRelatorios);
document.getElementById('periodo')?.addEventListener('change', event => {
  if (event.target.value === 'personalizado') return;
  definirPeriodo(event.target.value);
  gerarRelatorios();
});
['inicio', 'fim'].forEach(id => document.getElementById(id)?.addEventListener('change', () => {
  document.getElementById('periodo').value = 'personalizado';
}));

definirPeriodo(document.getElementById('periodo').value);
carregarOpcoes().then(gerarRelatorios).catch(error => mostrarMensagem(error.message || 'Não foi possível carregar os filtros.', true));
