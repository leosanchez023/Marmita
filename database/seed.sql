-- =========================================================
-- MARMITARIA - SEED INICIAL
-- Compatível com o schema-marmita.sql
-- =========================================================

USE marmita;

-- =========================================================
-- USUÁRIO ADMINISTRADOR
-- Senha: 123456
-- Hash bcrypt correspondente.
-- =========================================================
INSERT INTO usuario (nome, email, senha, ativo)
VALUES (
    'Administrador',
    'admin@marmitaria.com',
    '$2b$10$KBH0zlU0imSXp36GydETO.qTFPi.DM9hxYnUenZuyVn1CU.nuE9te',
    1
)
ON DUPLICATE KEY UPDATE
    nome = VALUES(nome),
    ativo = VALUES(ativo);

-- =========================================================
-- CLIENTES
-- =========================================================
INSERT INTO clientes
    (nome, telefone, email, endereco, numero, bairro, cidade, estado, cep, observacao)
VALUES
    ('João da Silva', '(14) 99999-1111', 'joao@email.com',
     'Rua das Flores', '100', 'Centro', 'Tupã', 'SP', '17600-000', NULL),

    ('Maria Oliveira', '(14) 98888-2222', 'maria@email.com',
     'Rua São Paulo', '250', 'Centro', 'Tupã', 'SP', '17600-000', NULL),

    ('Carlos Santos', '(14) 97777-3333', 'carlos@email.com',
     'Avenida Brasil', '500', 'Jardim Paulista', 'Tupã', 'SP', '17600-000', 'Prefere entrega no almoço'),

    ('Ana Souza', '(14) 96666-4444', 'ana@email.com',
     'Rua Paraná', '75', 'Vila Independência', 'Tupã', 'SP', '17600-000', NULL),

    ('Pedro Lima', '(14) 95555-5555', 'pedro@email.com',
     'Rua Minas Gerais', '320', 'Centro', 'Tupã', 'SP', '17600-000', NULL);

-- =========================================================
-- PRODUTOS
-- Se os produtos do schema já existem, não duplica.
-- =========================================================
INSERT INTO produtos
    (nome, categoria, descricao, preco, controla_estoque, estoque, estoque_minimo, ativo)
SELECT
    'Marmita P', 'MARMITA', 'Marmita pequena', 15.00, 1, 50, 10, 1
WHERE NOT EXISTS (
    SELECT 1 FROM produtos WHERE nome = 'Marmita P'
);

INSERT INTO produtos
    (nome, categoria, descricao, preco, controla_estoque, estoque, estoque_minimo, ativo)
SELECT
    'Marmita M', 'MARMITA', 'Marmita média', 18.00, 1, 50, 10, 1
WHERE NOT EXISTS (
    SELECT 1 FROM produtos WHERE nome = 'Marmita M'
);

INSERT INTO produtos
    (nome, categoria, descricao, preco, controla_estoque, estoque, estoque_minimo, ativo)
SELECT
    'Marmita G', 'MARMITA', 'Marmita grande', 22.00, 1, 50, 10, 1
WHERE NOT EXISTS (
    SELECT 1 FROM produtos WHERE nome = 'Marmita G'
);

INSERT INTO produtos
    (nome, categoria, descricao, preco, controla_estoque, estoque, estoque_minimo, ativo)
SELECT
    'Coca-Cola Lata', 'BEBIDA', 'Refrigerante lata 350ml', 6.00, 1, 30, 5, 1
WHERE NOT EXISTS (
    SELECT 1 FROM produtos WHERE nome = 'Coca-Cola Lata'
);

INSERT INTO produtos
    (nome, categoria, descricao, preco, controla_estoque, estoque, estoque_minimo, ativo)
SELECT
    'Guaraná Lata', 'BEBIDA', 'Refrigerante lata 350ml', 5.00, 1, 30, 5, 1
WHERE NOT EXISTS (
    SELECT 1 FROM produtos WHERE nome = 'Guaraná Lata'
);

INSERT INTO produtos
    (nome, categoria, descricao, preco, controla_estoque, estoque, estoque_minimo, ativo)
SELECT
    'Feijão extra', 'ADICIONAL', 'Porção extra de feijão', 3.00, 1, 40, 5, 1
WHERE NOT EXISTS (
    SELECT 1 FROM produtos WHERE nome = 'Feijão extra'
);

INSERT INTO produtos
    (nome, categoria, descricao, preco, controla_estoque, estoque, estoque_minimo, ativo)
SELECT
    'Batata frita', 'ADICIONAL', 'Porção de batata frita', 7.00, 1, 30, 5, 1
WHERE NOT EXISTS (
    SELECT 1 FROM produtos WHERE nome = 'Batata frita'
);

-- =========================================================
-- VENDAS DE EXEMPLO
-- Servem para testar a tela de Relatórios.
-- =========================================================

INSERT INTO vendas
    (numero_pedido, data_venda, cliente_id, usuario_id, forma_pagamento_id,
     adicional, bebidas, frete, desconto, subtotal, total, observacao, status)
VALUES
    (
        '000001',
        CURDATE(),
        (SELECT id FROM clientes WHERE email = 'joao@email.com' LIMIT 1),
        (SELECT id FROM usuario WHERE email = 'admin@marmitaria.com' LIMIT 1),
        (SELECT id FROM formas_pagamento WHERE nome = 'Pix' LIMIT 1),
        3.00, 6.00, 0.00, 0.00, 18.00, 27.00,
        'Pedido para retirada',
        'FINALIZADA'
    ),
    (
        '000002',
        DATE_SUB(CURDATE(), INTERVAL 1 DAY),
        (SELECT id FROM clientes WHERE email = 'maria@email.com' LIMIT 1),
        (SELECT id FROM usuario WHERE email = 'admin@marmitaria.com' LIMIT 1),
        (SELECT id FROM formas_pagamento WHERE nome = 'Dinheiro' LIMIT 1),
        0.00, 5.00, 5.00, 2.00, 22.00, 30.00,
        'Entregar no endereço cadastrado',
        'FINALIZADA'
    ),
    (
        '000003',
        DATE_SUB(CURDATE(), INTERVAL 2 DAY),
        (SELECT id FROM clientes WHERE email = 'carlos@email.com' LIMIT 1),
        (SELECT id FROM usuario WHERE email = 'admin@marmitaria.com' LIMIT 1),
        (SELECT id FROM formas_pagamento WHERE nome = 'Cartão de crédito' LIMIT 1),
        7.00, 11.00, 0.00, 0.00, 40.00, 58.00,
        NULL,
        'FINALIZADA'
    );

-- =========================================================
-- ITENS DAS VENDAS
-- =========================================================

INSERT INTO venda_itens
    (venda_id, produto_id, tamanho, quantidade, valor_unitario, subtotal)
VALUES
(
    (SELECT id FROM vendas WHERE numero_pedido = '000001'),
    (SELECT id FROM produtos WHERE nome = 'Marmita M' LIMIT 1),
    'M',
    1,
    18.00,
    18.00
),
(
    (SELECT id FROM vendas WHERE numero_pedido = '000001'),
    (SELECT id FROM produtos WHERE nome = 'Coca-Cola Lata' LIMIT 1),
    'UNICO',
    1,
    6.00,
    6.00
),
(
    (SELECT id FROM vendas WHERE numero_pedido = '000002'),
    (SELECT id FROM produtos WHERE nome = 'Marmita G' LIMIT 1),
    'G',
    1,
    22.00,
    22.00
),
(
    (SELECT id FROM vendas WHERE numero_pedido = '000002'),
    (SELECT id FROM produtos WHERE nome = 'Guaraná Lata' LIMIT 1),
    'UNICO',
    1,
    5.00,
    5.00
),
(
    (SELECT id FROM vendas WHERE numero_pedido = '000003'),
    (SELECT id FROM produtos WHERE nome = 'Marmita P' LIMIT 1),
    'P',
    2,
    15.00,
    30.00
),
(
    (SELECT id FROM vendas WHERE numero_pedido = '000003'),
    (SELECT id FROM produtos WHERE nome = 'Coca-Cola Lata' LIMIT 1),
    'UNICO',
    1,
    6.00,
    6.00
);

-- =========================================================
-- CONSULTAS DE CONFERÊNCIA
-- =========================================================

SELECT 'USUÁRIO' AS tabela, COUNT(*) AS quantidade FROM usuario
UNION ALL
SELECT 'CLIENTES', COUNT(*) FROM clientes
UNION ALL
SELECT 'PRODUTOS', COUNT(*) FROM produtos
UNION ALL
SELECT 'FORMAS DE PAGAMENTO', COUNT(*) FROM formas_pagamento
UNION ALL
SELECT 'VENDAS', COUNT(*) FROM vendas
UNION ALL
SELECT 'ITENS DE VENDA', COUNT(*) FROM venda_itens;
