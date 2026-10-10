-- Dados iniciais para Supabase/PostgreSQL.
-- Execute depois de database/schema.sql.

INSERT INTO public.usuario (nome, email, senha, ativo)
VALUES (
    'Administrador',
    'admin@marmitaria.com',
    '$2b$10$KBH0zlU0imSXp36GydETO.qTFPi.DM9hxYnUenZuyVn1CU.nuE9te',
    TRUE
)
ON CONFLICT (email) DO NOTHING;

INSERT INTO public.clientes
    (nome, telefone, email, endereco, numero, bairro, cidade, estado, cep, observacao)
SELECT dados.*
FROM (VALUES
    ('João da Silva', '(14) 99999-1111', 'joao@email.com',
     'Rua das Flores', '100', 'Centro', 'Tupã', 'SP', '17600-000', NULL),
    ('Maria Oliveira', '(14) 98888-2222', 'maria@email.com',
     'Rua São Paulo', '250', 'Centro', 'Tupã', 'SP', '17600-000', NULL),
    ('Carlos Santos', '(14) 97777-3333', 'carlos@email.com',
     'Avenida Brasil', '500', 'Jardim Paulista', 'Tupã', 'SP', '17600-000',
     'Prefere entrega no almoço'),
    ('Ana Souza', '(14) 96666-4444', 'ana@email.com',
     'Rua Paraná', '75', 'Vila Independência', 'Tupã', 'SP', '17600-000', NULL),
    ('Pedro Lima', '(14) 95555-5555', 'pedro@email.com',
     'Rua Minas Gerais', '320', 'Centro', 'Tupã', 'SP', '17600-000', NULL)
) AS dados(nome, telefone, email, endereco, numero, bairro, cidade, estado, cep, observacao)
WHERE NOT EXISTS (
    SELECT 1 FROM public.clientes AS cliente WHERE cliente.email = dados.email
);

INSERT INTO public.vendas
    (numero_pedido, data_venda, cliente_id, usuario_id, forma_pagamento_id,
     adicional, bebidas, frete, desconto, subtotal, total, observacao, status)
SELECT
    exemplo.numero_pedido,
    exemplo.data_venda,
    cliente.id,
    usuario.id,
    pagamento.id,
    exemplo.adicional,
    exemplo.bebidas,
    exemplo.frete,
    exemplo.desconto,
    exemplo.subtotal,
    exemplo.total,
    exemplo.observacao,
    'FINALIZADA'
FROM (VALUES
    ('000001', CURRENT_DATE, 'joao@email.com', 'Pix',
     3.00, 6.00, 0.00, 0.00, 18.00, 27.00, 'Pedido para retirada'),
    ('000002', CURRENT_DATE - 1, 'maria@email.com', 'Dinheiro',
     0.00, 5.00, 5.00, 2.00, 22.00, 30.00, 'Entregar no endereço cadastrado'),
    ('000003', CURRENT_DATE - 2, 'carlos@email.com', 'Cartão de crédito',
     7.00, 11.00, 0.00, 0.00, 40.00, 58.00, NULL)
) AS exemplo(
    numero_pedido, data_venda, cliente_email, forma_pagamento,
    adicional, bebidas, frete, desconto, subtotal, total, observacao
)
LEFT JOIN public.clientes AS cliente ON cliente.email = exemplo.cliente_email
LEFT JOIN public.usuario AS usuario ON usuario.email = 'admin@marmitaria.com'
LEFT JOIN public.formas_pagamento AS pagamento ON pagamento.nome = exemplo.forma_pagamento
ON CONFLICT (numero_pedido) DO NOTHING;

INSERT INTO public.venda_itens
    (venda_id, tamanho, quantidade, valor_unitario, subtotal)
SELECT venda.id, exemplo.tamanho, exemplo.quantidade, exemplo.preco, exemplo.subtotal
FROM (VALUES
    ('000001', 'M', 1, 18.00, 18.00),
    ('000002', 'G', 1, 22.00, 22.00),
    ('000003', 'P', 2, 20.00, 40.00)
) AS exemplo(numero_pedido, tamanho, quantidade, preco, subtotal)
JOIN public.vendas AS venda ON venda.numero_pedido = exemplo.numero_pedido
WHERE NOT EXISTS (
    SELECT 1
    FROM public.venda_itens AS item
    WHERE item.venda_id = venda.id
      AND item.tamanho = exemplo.tamanho
      AND item.quantidade = exemplo.quantidade
      AND item.valor_unitario = exemplo.preco
      AND item.subtotal = exemplo.subtotal
);
