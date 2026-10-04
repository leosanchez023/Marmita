const brl = n => Number(n || 0).toLocaleString('pt-BR', { style:'currency', currency:'BRL' });
const esc = value => String(value ?? '').replace(/[&<>'"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;',"'":'&#39;','"':'&quot;'}[c]));

async function carregarOpcoes() {
  const res = await fetch('/relatorios/opcoes');
  const data = await res.json();
  const select = document.getElementById('produto');
  data.produtos.forEach(p => select.insertAdjacentHTML('beforeend', `<option value="${p.id}">${esc(p.nome)}</option>`));

  const pagamento = document.getElementById('pagamento');
  pagamento.innerHTML = '<option value="">Todos</option>';
  (data.pagamentos || []).forEach(p => {
    pagamento.insertAdjacentHTML('beforeend', `<option value="${p.id}">${esc(p.nome)}</option>`);
  });
}

function render(data) {
  const r = data.resumo || {};
  document.getElementById('totalVendido').textContent = brl(r.total_vendido);
  document.getElementById('totalPedidos').textContent = Number(r.total_pedidos || 0);
  document.getElementById('qtdMarmitas').textContent = Number(r.qtd_marmitas || 0);
  document.getElementById('totalFretes').textContent = brl(r.total_fretes);
  document.getElementById('totalBebidas').textContent = brl(r.total_bebidas);
  document.getElementById('totalDescontos').textContent = brl(r.total_descontos);

  const day = document.getElementById('vendasDia');
  if (!data.vendasPorDia?.length) day.innerHTML = '<div class="empty">Sem dados no período.</div>';
  else {
    const max = Math.max(...data.vendasPorDia.map(x => Number(x.total)), 1);
    day.innerHTML = data.vendasPorDia.map(x => `<div class="bar-item"><div class="bar-value">${brl(x.total)}</div><div class="bar" style="height:${Math.max(8, Number(x.total)/max*180)}px"></div><small>${new Date(`${x.data}T12:00:00`).toLocaleDateString('pt-BR',{day:'2-digit',month:'2-digit'})}</small></div>`).join('');
  }

  document.getElementById('pagamentosBody').innerHTML = data.pagamentos.length ? data.pagamentos.map(x => `<tr><td>${esc(x.forma_pagamento)}</td><td>${x.pedidos}</td><td>${brl(x.total)}</td></tr>`).join('') : '<tr><td colspan="3" class="empty">Sem dados.</td></tr>';
  document.getElementById('produtosBody').innerHTML = data.produtos.length ? data.produtos.map(x => `<tr><td>${esc(x.nome)}</td><td>${x.quantidade}</td><td>${brl(x.total)}</td></tr>`).join('') : '<tr><td colspan="3" class="empty">Sem dados.</td></tr>';
  document.getElementById('vendasBody').innerHTML = data.vendas.length ? data.vendas.map(x => `<tr><td>#${esc(x.numero_pedido)}</td><td>${esc(x.cliente)}</td><td>${x.data}</td><td>${brl(x.total)}</td><td>${esc(x.forma_pagamento)}</td></tr>`).join('') : '<tr><td colspan="5" class="empty">Sem dados.</td></tr>';
  document.getElementById('vendasCount').textContent = `${data.vendas.length} venda(s)`;
}

async function gerarRelatorios() {
  const qs = new URLSearchParams();
  ['inicio','fim','pagamento','produto'].forEach(id => { const v = document.getElementById(id).value; if (v) qs.set(id, v); });
  const res = await fetch(`/relatorios/dados?${qs}`);
  const data = await res.json();
  if (data.success) render(data);
}

document.getElementById('filtrar')?.addEventListener('click', gerarRelatorios);
carregarOpcoes().then(gerarRelatorios);
