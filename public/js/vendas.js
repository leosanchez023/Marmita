const form = document.getElementById('vendaForm');
const data = document.getElementById('data_venda');
const tamanho = document.getElementById('tamanho');
const quantidade = document.getElementById('quantidade');
const valorUnitario = document.getElementById('valor_unitario');
const itensBody = document.getElementById('itensBody');
const itensMensagem = document.getElementById('itensMensagem');
const itensCount = document.getElementById('itensCount');
const fields = ['adicional', 'bebidas', 'frete', 'desconto']
  .map(id => document.getElementById(id));
const itens = [];

const money = value => Number(value || 0).toLocaleString('pt-BR', {
  style: 'currency',
  currency: 'BRL'
});

if (data) data.value = new Date().toISOString().slice(0, 10);

function recalcular() {
  const subtotal = itens.reduce((sum, item) => sum + item.subtotal, 0);
  const adicional = fields[0]?.valueAsNumber || 0;
  const bebidas = fields[1]?.valueAsNumber || 0;
  const frete = fields[2]?.valueAsNumber || 0;
  const desconto = fields[3]?.valueAsNumber || 0;
  const total = Math.max(0, subtotal + adicional + bebidas + frete - desconto);

  document.getElementById('subtotalTotal').textContent = money(subtotal);
  document.getElementById('totalPedido').textContent = money(total);
}

function renderItens() {
  if (!itens.length) {
    itensBody.innerHTML = '<tr><td colspan="5" class="empty">Nenhum item adicionado.</td></tr>';
    itensMensagem.textContent = 'Nenhum item adicionado.';
    itensCount.textContent = '0 item(s)';
    recalcular();
    return;
  }

  itensBody.innerHTML = itens.map((item, index) => `
    <tr>
      <td>${item.tamanho}</td>
      <td>${item.quantidade}</td>
      <td>${money(item.valor_unitario)}</td>
      <td>${money(item.subtotal)}</td>
      <td><button type="button" class="btn-remove-item" data-index="${index}" title="Remover">
        <i class="fa-solid fa-trash"></i>
      </button></td>
    </tr>
  `).join('');
  itensMensagem.textContent = `${itens.length} item(s) adicionado(s).`;
  itensCount.textContent = `${itens.length} item(s)`;

  itensBody.querySelectorAll('.btn-remove-item').forEach(button => {
    button.addEventListener('click', () => {
      itens.splice(Number(button.dataset.index), 1);
      renderItens();
    });
  });

  recalcular();
}

document.getElementById('adicionarItem')?.addEventListener('click', () => {
  const quantidadeValor = Number(quantidade.value);
  const preco = Number(valorUnitario.value);
  if (!Number.isSafeInteger(quantidadeValor) || quantidadeValor < 1) {
    quantidade.setCustomValidity('Informe uma quantidade inteira maior que zero.');
    quantidade.reportValidity();
    quantidade.setCustomValidity('');
    quantidade.focus();
    return;
  }
  if (!Number.isFinite(preco) || preco < 0) {
    valorUnitario.reportValidity();
    valorUnitario.focus();
    return;
  }

  const subtotal = Math.round(quantidadeValor * preco * 100) / 100;
  itens.push({
    tamanho: tamanho.value,
    quantidade: quantidadeValor,
    valor_unitario: Math.round(preco * 100) / 100,
    subtotal
  });
  quantidade.value = '1';
  valorUnitario.value = '0.00';
  renderItens();
});

fields.forEach(field => field?.addEventListener('input', recalcular));

form?.addEventListener('submit', async event => {
  event.preventDefault();

  const message = document.getElementById('formMessage');
  if (!itens.length) {
    message.textContent = 'Adicione pelo menos um item à venda.';
    message.className = 'form-message error';
    return;
  }

  message.textContent = 'Salvando...';
  message.className = 'form-message';

  const payload = {
    data_venda: data.value,
    cliente_id: document.getElementById('cliente_id').value || null,
    forma_pagamento_id: document.getElementById('forma_pagamento_id').value || null,
    adicional: document.getElementById('adicional').value,
    bebidas: document.getElementById('bebidas').value,
    frete: document.getElementById('frete').value,
    desconto: document.getElementById('desconto').value,
    observacao: document.getElementById('observacao').value,
    itens
  };

  try {
    const response = await fetch('/vendas', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });

    const result = await response.json();

    if (!result.success) {
      message.textContent = result.message || 'Erro ao salvar.';
      message.className = 'form-message error';
      return;
    }

    message.textContent = `Venda #${result.venda.numeroPedido} salva com sucesso.`;
    message.className = 'form-message success';

    setTimeout(() => window.location.reload(), 700);
  } catch (error) {
    console.error(error);
    message.textContent = 'Não foi possível conectar ao servidor.';
    message.className = 'form-message error';
  }
});

document.getElementById('limparBtn')?.addEventListener('click', () => {
  form.reset();
  data.value = new Date().toISOString().slice(0, 10);
  itens.length = 0;
  renderItens();
});

renderItens();
