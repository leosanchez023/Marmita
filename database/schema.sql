-- =========================================================
-- MARMITARIA - SCHEMA DO BANCO DE DADOS
-- Node.js + Express + Handlebars + MySQL
-- =========================================================

CREATE DATABASE IF NOT EXISTS marmita
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE marmita;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS venda_itens;
DROP TABLE IF EXISTS vendas;
DROP TABLE IF EXISTS formas_pagamento;
DROP TABLE IF EXISTS produtos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS usuario;

SET FOREIGN_KEY_CHECKS = 1;

-- =========================================================
-- USUÁRIOS / LOGIN
-- A senha deve ser armazenada com bcrypt.
-- =========================================================
CREATE TABLE usuario (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    senha VARCHAR(255) NOT NULL,
    ativo TINYINT(1) NOT NULL DEFAULT 1,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_usuario_email (email),
    KEY idx_usuario_ativo (ativo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- CLIENTES
-- =========================================================
CREATE TABLE clientes (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome VARCHAR(150) NOT NULL,
    telefone VARCHAR(30) DEFAULT NULL,
    email VARCHAR(150) DEFAULT NULL,
    cpf VARCHAR(20) DEFAULT NULL,
    endereco VARCHAR(255) DEFAULT NULL,
    numero VARCHAR(20) DEFAULT NULL,
    complemento VARCHAR(100) DEFAULT NULL,
    bairro VARCHAR(100) DEFAULT NULL,
    cidade VARCHAR(100) DEFAULT NULL,
    estado VARCHAR(2) DEFAULT NULL,
    cep VARCHAR(15) DEFAULT NULL,
    observacao TEXT DEFAULT NULL,
    ativo TINYINT(1) NOT NULL DEFAULT 1,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_clientes_nome (nome),
    KEY idx_clientes_telefone (telefone),
    KEY idx_clientes_ativo (ativo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- PRODUTOS / MARMITAS / BEBIDAS / ADICIONAIS
-- =========================================================
CREATE TABLE produtos (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome VARCHAR(150) NOT NULL,
    categoria ENUM(
        'MARMITA',
        'BEBIDA',
        'ADICIONAL',
        'OUTRO'
    ) NOT NULL DEFAULT 'MARMITA',
    descricao TEXT DEFAULT NULL,

    -- Preço padrão. O preço efetivamente vendido fica
    -- registrado em venda_itens.
    preco DECIMAL(10,2) NOT NULL DEFAULT 0.00,

    -- Estoque é opcional para produtos que não utilizam controle.
    controla_estoque TINYINT(1) NOT NULL DEFAULT 1,
    estoque INT NOT NULL DEFAULT 0,
    estoque_minimo INT NOT NULL DEFAULT 0,

    ativo TINYINT(1) NOT NULL DEFAULT 1,

    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    KEY idx_produtos_nome (nome),
    KEY idx_produtos_categoria (categoria),
    KEY idx_produtos_ativo (ativo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- FORMAS DE PAGAMENTO
-- =========================================================
CREATE TABLE formas_pagamento (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome VARCHAR(50) NOT NULL,
    ativo TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (id),
    UNIQUE KEY uk_forma_pagamento_nome (nome)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO formas_pagamento (nome) VALUES
('Pix'),
('Dinheiro'),
('Cartão de débito'),
('Cartão de crédito'),
('Transferência');

-- =========================================================
-- VENDAS
-- Representa a "Nova venda" da tela de referência.
-- =========================================================
CREATE TABLE vendas (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,

    numero_pedido VARCHAR(30) DEFAULT NULL,

    data_venda DATE NOT NULL,

    cliente_id INT UNSIGNED DEFAULT NULL,
    usuario_id INT UNSIGNED DEFAULT NULL,
    forma_pagamento_id INT UNSIGNED DEFAULT NULL,

    -- Valores adicionais da venda.
    adicional DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    bebidas DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    frete DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    desconto DECIMAL(10,2) NOT NULL DEFAULT 0.00,

    subtotal DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(10,2) NOT NULL DEFAULT 0.00,

    observacao TEXT DEFAULT NULL,

    status ENUM(
        'ABERTA',
        'FINALIZADA',
        'CANCELADA'
    ) NOT NULL DEFAULT 'FINALIZADA',

    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),

    UNIQUE KEY uk_vendas_numero_pedido (numero_pedido),

    KEY idx_vendas_data (data_venda),
    KEY idx_vendas_cliente (cliente_id),
    KEY idx_vendas_usuario (usuario_id),
    KEY idx_vendas_pagamento (forma_pagamento_id),
    KEY idx_vendas_status (status),

    CONSTRAINT fk_venda_cliente
        FOREIGN KEY (cliente_id)
        REFERENCES clientes(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_venda_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES usuario(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_venda_pagamento
        FOREIGN KEY (forma_pagamento_id)
        REFERENCES formas_pagamento(id)
        ON DELETE SET NULL

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- ITENS DA VENDA
-- Permite uma venda com uma ou várias marmitas/produtos.
-- =========================================================
CREATE TABLE venda_itens (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,

    venda_id INT UNSIGNED NOT NULL,
    produto_id INT UNSIGNED NOT NULL,

    tamanho ENUM(
        'P',
        'M',
        'G',
        'GG',
        'UNICO'
    ) NOT NULL DEFAULT 'UNICO',

    quantidade INT UNSIGNED NOT NULL DEFAULT 1,

    valor_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    subtotal DECIMAL(10,2) NOT NULL DEFAULT 0.00,

    PRIMARY KEY (id),

    KEY idx_venda_itens_venda (venda_id),
    KEY idx_venda_itens_produto (produto_id),

    CONSTRAINT fk_venda_item_venda
        FOREIGN KEY (venda_id)
        REFERENCES vendas(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_venda_item_produto
        FOREIGN KEY (produto_id)
        REFERENCES produtos(id)
        ON DELETE RESTRICT

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- VIEW PARA RELATÓRIOS
-- Facilita consultas de vendas com cliente e pagamento.
-- =========================================================
CREATE OR REPLACE VIEW vw_vendas_relatorio AS
SELECT
    v.id,
    v.numero_pedido,
    v.data_venda,
    c.nome AS cliente,
    fp.nome AS forma_pagamento,
    v.subtotal,
    v.adicional,
    v.bebidas,
    v.frete,
    v.desconto,
    v.total,
    v.status
FROM vendas v
LEFT JOIN clientes c
    ON c.id = v.cliente_id
LEFT JOIN formas_pagamento fp
    ON fp.id = v.forma_pagamento_id;

-- =========================================================
-- VIEW DE PRODUTOS MAIS VENDIDOS
-- =========================================================
CREATE OR REPLACE VIEW vw_produtos_mais_vendidos AS
SELECT
    p.id AS produto_id,
    p.nome AS produto,
    p.categoria,
    SUM(vi.quantidade) AS quantidade_vendida,
    SUM(vi.subtotal) AS valor_total
FROM venda_itens vi
INNER JOIN vendas v
    ON v.id = vi.venda_id
INNER JOIN produtos p
    ON p.id = vi.produto_id
WHERE v.status = 'FINALIZADA'
GROUP BY
    p.id,
    p.nome,
    p.categoria;

-- =========================================================
-- DADOS INICIAIS DE PRODUTOS
-- Podem ser removidos caso você queira cadastrar tudo pela tela.
-- =========================================================
INSERT INTO produtos (nome, categoria, preco) VALUES
('Marmita P', 'MARMITA', 15.00),
('Marmita M', 'MARMITA', 18.00),
('Marmita G', 'MARMITA', 22.00),
('Coca-Cola Lata', 'BEBIDA', 6.00),
('Guaraná Lata', 'BEBIDA', 5.00),
('Feijão extra', 'ADICIONAL', 3.00);

-- =========================================================
-- OBSERVAÇÃO SOBRE O LOGIN
-- =========================================================
-- Gere o hash da senha com bcrypt no Node.js.
-- Exemplo de usuário depois de gerar o hash:
--
-- INSERT INTO usuario (nome, email, senha)
-- VALUES ('Administrador', 'admin@marmitaria.com', 'HASH_BCRYPT');
--
-- Não coloque senha em texto puro no banco.
-- =========================================================
