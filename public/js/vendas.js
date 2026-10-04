const form = document.getElementById('vendaForm');
const produto = document.getElementById('produto_id');
const quantidade = document.getElementById('quantidade');
const valor = document.getElementById('valor_unitario');
const tamanho = document.getElementById('tamanho');
const data = document.getElementById('data_venda');
const itensBody = document.getElementById('itensBody');
const itensMensagem = document.getElementById('itensMensagem');
const itensCount = document.getElementById('itensCount');
const fields = ['adicional', 'bebidas', 'frete', 'desconto']
  .map(id => document.getElementById(id));

const itens = [];
const money = n => Number(n || 0).toLocaleString('pt-BR', {
  style: 'currency',
  currency: 'BRL'
});
const num = el => Number(el?.value || 0);

if (data) data.value = new Date().toISOString().slice(0, 10);

function renderItens() {
  if (!itensBody) return;

  if (!itens.length) {
    itensBody.innerHTML = '<tr><td colspan="6" class="empty">Nenhum item adicionado.</td></tr>';
    itensMensagem.textContent = 'Nenhum item adicionado.';
    itensCount.textContent = '0 item(s)';
    recalcular();
    return;
  }

  itensBody.innerHTML = itens.map((item, index) => `
    <tr>
      <td>${item.nome}</td>
      <td>${item.tamanho}</td>
      <td>${item.quantidade}</td>
      <td>${money(item.valor_unitario)}</td>
      <td>${money(item.subtotal)}</td>
      <td>
        <button type="button" class="btn-remove-item" data-index="${index}" title="Remover">
          <i class="fa-solid fa-trash"></i>
        </button>
      </td>
    </tr>
  `).join('');

  itensMensagem.textContent = `${itens.length} item(s) adicionado(s).`;
  itensCount.textContent = `${itens.length} item(s)`;

  document.querySelectorAll('.btn-remove-item').forEach(button => {
    button.addEventListener('click', () => {
      itens.splice(Number(button.dataset.index), 1);
      renderItens();
    });
  });

  recalcular();
}

function recalcular() {
  const subtotal = itens.reduce((sum, item) => sum + Number(item.subtotal || 0), 0);
  const adicional = fields[0]?.valueAsNumber || 0;
  const bebidas = fields[1]?.valueAsNumber || 0;
  const frete = fields[2]?.valueAsNumber || 0;
  const desconto = fields[3]?.valueAsNumber || 0;
  const total = Math.max(0, subtotal + adicional + bebidas + frete - desconto);

  const subtotalInput = document.getElementById('subtotal');
  if (subtotalInput) subtotalInput.value = money(subtotal);

  document.getElementById('subtotalTotal').textContent = money(subtotal);
  document.getElementById('totalPedido').textContent = money(total);
}

produto?.addEventListener('change', () => {
  const option = produto.selectedOptions[0];
  if (!option?.value) return;

  valor.value = Number(option.dataset.preco || 0).toFixed(2);

  const categoria = option.dataset.categoria;
  tamanho.value = categoria === 'MARMITA' ? 'M' : 'UNICO';
});

document.getElementById('adicionarItem')?.addEventListener('click', () => {
  const option = produto?.selectedOptions[0];

  if (!option?.value) {
    alert('Selecione um produto antes de adicionar.');
    produto?.focus();
    return;
  }

  const quantidadeValor = Math.max(1, Number(quantidade.value || 1));
  const valorUnitario = Math.max(0, Number(valor.value || 0));

  itens.push({
    produto_id: Number(option.value),
    nome: option.textContent.split(' — ')[0].trim(),
    tamanho: tamanho.value || 'UNICO',
    quantidade: quantidadeValor,
    valor_unitario: valorUnitario,
    subtotal: quantidadeValor * valorUnitario
  });

  produto.value = '';
  quantidade.value = '1';
  valor.value = '0.00';
  tamanho.value = 'UNICO';

  renderItens();
});

[quantidade, valor, ...fields].forEach(el => {
  el?.addEventListener('input', recalcular);
});

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
