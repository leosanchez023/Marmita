-- Importacao da aba VENDAS do Excel para Supabase/PostgreSQL.
-- GERADO PARA REVISAO: este arquivo NAO foi executado no banco.
-- Preserva registros existentes: nao atualiza nem apaga vendas.
-- Reexecucao segura: nao insere novamente um numero_pedido ja existente.
-- Identificadores PLAN-AAAAMMDD-NNN; o numero original fica documentado nos comentarios.
-- Regras confirmadas: DIN e NAO PG = Dinheiro; CAR e CAR DEB = Cartao de debito;
-- CAR PIX = Cartao de debito (prioriza cartao quando aparece junto com Pix); CAR CRE = Cartao de credito.
-- Em pedidos com pagamento misto, o cartao prevalece quando presente; sem cartao, Pix prevalece sobre dinheiro.
-- Pedido 45 importado como excecao: tamanho UNICO, quantidade 1 e item sem valor (adicional de R$ 6,00).
-- GISLAINE do pedido 29 foi corrigida de Produto para Cliente, conforme confirmacao do usuario.
-- Custos estimados e lucro estimado nao sao importados.

BEGIN;
CREATE TEMP TABLE _stage_vendas (numero_pedido text PRIMARY KEY, numero_original integer, data_venda date, cliente_nome text, forma_pagamento text, subtotal numeric(10,2), adicional numeric(10,2), bebidas numeric(10,2), frete numeric(10,2), desconto numeric(10,2), total numeric(10,2)) ON COMMIT PRESERVE ROWS;
CREATE TEMP TABLE _stage_itens (numero_pedido text, tamanho text, quantidade integer, valor_unitario numeric(10,2), subtotal numeric(10,2)) ON COMMIT PRESERVE ROWS;
CREATE TEMP TABLE _inserted_vendas (numero_pedido text PRIMARY KEY, venda_id bigint) ON COMMIT PRESERVE ROWS;

INSERT INTO _stage_vendas (numero_pedido, numero_original, data_venda, cliente_nome, forma_pagamento, subtotal, adicional, bebidas, frete, desconto, total) VALUES
-- Pedido original 1; data 17/08/2026; linhas Excel 4
  ('PLAN-20260817-001', 1, '2026-08-17', NULL, 'Pix', 40.00, 0.00, 0.00, 0.00, 0.00, 40.00),
-- Pedido original 2; data 17/08/2026; linhas Excel 5
  ('PLAN-20260817-002', 2, '2026-08-17', NULL, 'Dinheiro', 18.00, 0.00, 0.00, 0.00, 0.00, 18.00),
-- Pedido original 3; data 17/08/2026; linhas Excel 6
  ('PLAN-20260817-003', 3, '2026-08-17', NULL, 'Pix', 18.00, 0.00, 0.00, 5.00, 0.00, 23.00),
-- Pedido original 5; data 17/08/2026; linhas Excel 7, 8
  ('PLAN-20260817-005', 5, '2026-08-17', NULL, 'Dinheiro', 38.00, 0.00, 0.00, 0.00, 0.00, 38.00),
-- Pedido original 6; data 17/08/2026; linhas Excel 9
  ('PLAN-20260817-006', 6, '2026-08-17', NULL, 'Pix', 30.00, 0.00, 0.00, 0.00, 0.00, 30.00),
-- Pedido original 7; data 17/08/2026; linhas Excel 10
  ('PLAN-20260817-007', 7, '2026-08-17', NULL, 'Pix', 50.00, 0.00, 0.00, 0.00, 0.00, 50.00),
-- Pedido original 8; data 17/08/2026; linhas Excel 11
  ('PLAN-20260817-008', 8, '2026-08-17', NULL, 'Cartão de débito', 18.00, 0.00, 0.00, 5.00, 0.00, 23.00),
-- Pedido original 9; data 17/08/2026; linhas Excel 12
  ('PLAN-20260817-009', 9, '2026-08-17', NULL, 'Dinheiro', 46.00, 0.00, 0.00, 0.00, 0.00, 46.00),
-- Pedido original 10; data 17/08/2026; linhas Excel 13
  ('PLAN-20260817-010', 10, '2026-08-17', NULL, 'Pix', 23.00, 0.00, 0.00, 5.00, 0.00, 28.00),
-- Pedido original 11; data 17/08/2026; linhas Excel 14, 15
  ('PLAN-20260817-011', 11, '2026-08-17', NULL, 'Dinheiro', 58.00, 0.00, 0.00, 0.00, 0.00, 58.00),
-- Pedido original 12; data 17/08/2026; linhas Excel 16
  ('PLAN-20260817-012', 12, '2026-08-17', NULL, 'Cartão de débito', 18.00, 0.00, 0.00, 5.00, 0.00, 23.00),
-- Pedido original 13; data 17/08/2026; linhas Excel 17
  ('PLAN-20260817-013', 13, '2026-08-17', NULL, 'Pix', 25.00, 0.00, 0.00, 0.00, 0.00, 25.00),
-- Pedido original 14; data 17/08/2026; linhas Excel 18, 19
  ('PLAN-20260817-014', 14, '2026-08-17', NULL, 'Pix', 58.00, 0.00, 0.00, 0.00, 0.00, 58.00),
-- Pedido original 15; data 17/08/2026; linhas Excel 20
  ('PLAN-20260817-015', 15, '2026-08-17', NULL, 'Cartão de débito', 20.00, 0.00, 0.00, 0.00, 0.00, 20.00),
-- Pedido original 16; data 17/08/2026; linhas Excel 21
  ('PLAN-20260817-016', 16, '2026-08-17', NULL, 'Cartão de débito', 18.00, 0.00, 0.00, 5.00, 0.00, 23.00),
-- Pedido original 17; data 17/08/2026; linhas Excel 22
  ('PLAN-20260817-017', 17, '2026-08-17', NULL, 'Dinheiro', 40.00, 0.00, 0.00, 5.00, 0.00, 45.00),
-- Pedido original 18; data 17/08/2026; linhas Excel 23
  ('PLAN-20260817-018', 18, '2026-08-17', NULL, 'Dinheiro', 18.00, 0.00, 0.00, 0.00, 0.00, 18.00),
-- Pedido original 19; data 17/08/2026; linhas Excel 24
  ('PLAN-20260817-019', 19, '2026-08-17', NULL, 'Dinheiro', 20.00, 0.00, 0.00, 0.00, 0.00, 20.00),
-- Pedido original 20; data 17/08/2026; linhas Excel 25, 26
  ('PLAN-20260817-020', 20, '2026-08-17', NULL, 'Dinheiro', 260.00, 0.00, 42.00, 0.00, 0.00, 302.00),
-- Pedido original 21; data 17/08/2026; linhas Excel 27
  ('PLAN-20260817-021', 21, '2026-08-17', NULL, 'Pix', 18.00, 0.00, 14.00, 0.00, 0.00, 32.00),
-- Pedido original 22; data 17/08/2026; linhas Excel 28
  ('PLAN-20260817-022', 22, '2026-08-17', NULL, 'Dinheiro', 18.00, 0.00, 0.00, 0.00, 0.00, 18.00),
-- Pedido original 23; data 17/08/2026; linhas Excel 29
  ('PLAN-20260817-023', 23, '2026-08-17', NULL, 'Pix', 18.00, 0.00, 0.00, 0.00, 0.00, 18.00),
-- Pedido original 24; data 17/08/2026; linhas Excel 30
  ('PLAN-20260817-024', 24, '2026-08-17', NULL, 'Pix', 25.00, 0.00, 0.00, 5.00, 0.00, 30.00),
-- Pedido original 25; data 18/08/2026; linhas Excel 32
  ('PLAN-20260818-025', 25, '2026-08-18', NULL, 'Dinheiro', 20.00, 0.00, 0.00, 5.00, 0.00, 25.00),
-- Pedido original 26; data 18/08/2026; linhas Excel 33
  ('PLAN-20260818-026', 26, '2026-08-18', NULL, 'Dinheiro', 20.00, 0.00, 0.00, 0.00, 0.00, 20.00),
-- Pedido original 27; data 18/08/2026; linhas Excel 34
  ('PLAN-20260818-027', 27, '2026-08-18', NULL, 'Cartão de débito', 20.00, 0.00, 0.00, 0.00, 0.00, 20.00),
-- Pedido original 28; data 18/08/2026; linhas Excel 35
  ('PLAN-20260818-028', 28, '2026-08-18', NULL, 'Cartão de débito', 18.00, 0.00, 0.00, 5.00, 0.00, 23.00),
-- Pedido original 29; data 18/08/2026; linhas Excel 36 (GISLAINE corrigida da coluna Produto para Cliente)
  ('PLAN-20260818-029', 29, '2026-08-18', 'GISLAINE', 'Cartão de débito', 27.00, 0.00, 0.00, 0.00, 0.00, 27.00),
-- Pedido original 30; data 18/08/2026; linhas Excel 38, 39
  ('PLAN-20260818-030', 30, '2026-08-18', NULL, 'Cartão de crédito', 120.00, 0.00, 12.00, 5.00, 0.00, 137.00),
-- Pedido original 31; data 18/08/2026; linhas Excel 40
  ('PLAN-20260818-031', 31, '2026-08-18', NULL, 'Cartão de débito', 40.00, 0.00, 0.00, 0.00, 0.00, 40.00),
-- Pedido original 32; data 18/08/2026; linhas Excel 41
  ('PLAN-20260818-032', 32, '2026-08-18', NULL, 'Cartão de crédito', 20.00, 0.00, 0.00, 0.00, 0.00, 20.00),
-- Pedido original 33; data 18/08/2026; linhas Excel 42
  ('PLAN-20260818-033', 33, '2026-08-18', NULL, 'Pix', 20.00, 0.00, 6.50, 0.00, 0.00, 26.50),
-- Pedido original 34; data 18/08/2026; linhas Excel 43
  ('PLAN-20260818-034', 34, '2026-08-18', NULL, 'Cartão de crédito', 18.00, 0.00, 0.00, 5.00, 0.00, 23.00),
-- Pedido original 35; data 18/08/2026; linhas Excel 44
  ('PLAN-20260818-035', 35, '2026-08-18', NULL, 'Cartão de débito', 46.00, 0.00, 10.00, 5.00, 0.00, 61.00),
-- Pedido original 36; data 18/08/2026; linhas Excel 45
  ('PLAN-20260818-036', 36, '2026-08-18', NULL, 'Dinheiro', 20.00, 0.00, 0.00, 5.00, 0.00, 25.00),
-- Pedido original 37; data 18/08/2026; linhas Excel 46
  ('PLAN-20260818-037', 37, '2026-08-18', NULL, 'Dinheiro', 46.00, 0.00, 0.00, 5.00, 0.00, 51.00),
-- Pedido original 38; data 18/08/2026; linhas Excel 47
  ('PLAN-20260818-038', 38, '2026-08-18', NULL, 'Cartão de débito', 20.00, 0.00, 0.00, 5.00, 0.00, 25.00),
-- Pedido original 39; data 18/08/2026; linhas Excel 48
  ('PLAN-20260818-039', 39, '2026-08-18', NULL, 'Dinheiro', 18.00, 0.00, 0.00, 0.00, 0.00, 18.00),
-- Pedido original 40; data 18/08/2026; linhas Excel 49
  ('PLAN-20260818-040', 40, '2026-08-18', NULL, 'Dinheiro', 18.00, 0.00, 0.00, 5.00, 0.00, 23.00),
-- Pedido original 41; data 18/08/2026; linhas Excel 50
  ('PLAN-20260818-041', 41, '2026-08-18', NULL, 'Cartão de crédito', 20.00, 0.00, 0.00, 0.00, 0.00, 20.00),
-- Pedido original 42; data 18/08/2026; linhas Excel 51
  ('PLAN-20260818-042', 42, '2026-08-18', NULL, 'Cartão de débito', 40.00, 0.00, 6.50, 5.00, 0.00, 51.50),
-- Pedido original 43; data 18/08/2026; linhas Excel 52
  ('PLAN-20260818-043', 43, '2026-08-18', NULL, 'Dinheiro', 20.00, 0.00, 0.00, 5.00, 0.00, 25.00),
-- Pedido original 44; data 18/08/2026; linhas Excel 53
  ('PLAN-20260818-044', 44, '2026-08-18', NULL, 'Pix', 18.00, 0.00, 2.50, 5.00, 0.00, 25.50),
-- Pedido original 46; data 19/08/2026; linhas Excel 55
  ('PLAN-20260819-046', 46, '2026-08-19', NULL, 'Cartão de débito', 18.00, 0.00, 0.00, 0.00, 0.00, 18.00),
-- Pedido original 47; data 19/08/2026; linhas Excel 56
  ('PLAN-20260819-047', 47, '2026-08-19', NULL, 'Pix', 18.00, 0.00, 0.00, 0.00, 0.00, 18.00),
-- Pedido original 48; data 19/08/2026; linhas Excel 57
  ('PLAN-20260819-048', 48, '2026-08-19', NULL, 'Cartão de débito', 36.00, 0.00, 0.00, 5.00, 0.00, 41.00),
-- Pedido original 49; data 19/08/2026; linhas Excel 58
  ('PLAN-20260819-049', 49, '2026-08-19', NULL, 'Dinheiro', 18.00, 0.00, 0.00, 5.00, 0.00, 23.00),
-- Pedido original 50; data 19/08/2026; linhas Excel 59
  ('PLAN-20260819-050', 50, '2026-08-19', NULL, 'Pix', 20.00, 7.00, 0.00, 0.00, 0.00, 27.00),
-- Pedido original 51; data 19/08/2026; linhas Excel 60, 61
  ('PLAN-20260819-051', 51, '2026-08-19', NULL, 'Dinheiro', 60.00, 0.00, 10.00, 5.00, 0.00, 75.00),
-- Pedido original 52; data 19/08/2026; linhas Excel 62
  ('PLAN-20260819-052', 52, '2026-08-19', NULL, 'Dinheiro', 20.00, 0.00, 0.00, 0.00, 0.00, 20.00),
-- Pedido original 53; data 19/08/2026; linhas Excel 63
  ('PLAN-20260819-053', 53, '2026-08-19', NULL, 'Pix', 40.00, 0.00, 0.00, 0.00, 0.00, 40.00),
-- Pedido original 54; data 19/08/2026; linhas Excel 64
  ('PLAN-20260819-054', 54, '2026-08-19', NULL, 'Dinheiro', 20.00, 0.00, 0.00, 0.00, 0.00, 20.00),
-- Pedido original 55; data 19/08/2026; linhas Excel 65
  ('PLAN-20260819-055', 55, '2026-08-19', NULL, 'Cartão de débito', 36.00, 0.00, 0.00, 5.00, 0.00, 41.00),
-- Pedido original 56; data 19/08/2026; linhas Excel 66
  ('PLAN-20260819-056', 56, '2026-08-19', NULL, 'Cartão de débito', 18.00, 0.00, 0.00, 0.00, 0.00, 18.00),
-- Pedido original 57; data 19/08/2026; linhas Excel 67
  ('PLAN-20260819-057', 57, '2026-08-19', NULL, 'Cartão de crédito', 20.00, 0.00, 0.00, 5.00, 0.00, 25.00),
-- Pedido original 58; data 19/08/2026; linhas Excel 68
  ('PLAN-20260819-058', 58, '2026-08-19', NULL, 'Dinheiro', 40.00, 0.00, 0.00, 5.00, 0.00, 45.00),
-- Pedido original 59; data 19/08/2026; linhas Excel 69, 70
  ('PLAN-20260819-059', 59, '2026-08-19', NULL, 'Cartão de débito', 59.00, 0.00, 0.00, 0.00, 0.00, 59.00),
-- Pedido original 60; data 19/08/2026; linhas Excel 71
  ('PLAN-20260819-060', 60, '2026-08-19', NULL, 'Cartão de débito', 23.00, 0.00, 0.00, 0.00, 0.00, 23.00),
-- Pedido original 61; data 19/08/2026; linhas Excel 72
  ('PLAN-20260819-061', 61, '2026-08-19', NULL, 'Pix', 20.00, 0.00, 0.00, 0.00, 0.00, 20.00),
-- Pedido original 62; data 19/08/2026; linhas Excel 73
  ('PLAN-20260819-062', 62, '2026-08-19', NULL, 'Cartão de débito', 20.00, 0.00, 0.00, 0.00, 0.00, 20.00),
-- Pedido original 63; data 19/08/2026; linhas Excel 74
  ('PLAN-20260819-063', 63, '2026-08-19', NULL, 'Pix', 18.00, 0.00, 0.00, 0.00, 0.00, 18.00),
-- Pedido original 64; data 19/08/2026; linhas Excel 75
  ('PLAN-20260819-064', 64, '2026-08-19', NULL, 'Dinheiro', 18.00, 0.00, 0.00, 0.00, 0.00, 18.00),
-- Pedido original 65; data 19/08/2026; linhas Excel 76
  ('PLAN-20260819-065', 65, '2026-08-19', NULL, 'Dinheiro', 18.00, 0.00, 0.00, 0.00, 0.00, 18.00),
-- Pedido original 66; data 19/08/2026; linhas Excel 77
  ('PLAN-20260819-066', 66, '2026-08-19', NULL, 'Dinheiro', 18.00, 0.00, 2.00, 0.00, 0.00, 20.00),
-- Pedido original 67; data 19/08/2026; linhas Excel 78
  ('PLAN-20260819-067', 67, '2026-08-19', NULL, 'Cartão de crédito', 18.00, 0.00, 0.00, 5.00, 0.00, 23.00),
-- Pedido original 68; data 19/08/2026; linhas Excel 79
  ('PLAN-20260819-068', 68, '2026-08-19', NULL, 'Dinheiro', 18.00, 0.00, 0.00, 0.00, 0.00, 18.00),
-- Pedido original 69; data 19/08/2026; linhas Excel 80
  ('PLAN-20260819-069', 69, '2026-08-19', NULL, 'Pix', 40.00, 0.00, 0.00, 0.00, 0.00, 40.00),
-- Pedido original 70; data 19/08/2026; linhas Excel 81
  ('PLAN-20260819-070', 70, '2026-08-19', NULL, 'Dinheiro', 18.00, 0.00, 0.00, 5.00, 0.00, 23.00),
-- Pedido original 72; data 19/08/2026; linhas Excel 82
  ('PLAN-20260819-072', 72, '2026-08-19', NULL, 'Dinheiro', 20.00, 0.00, 96.00, 0.00, 0.00, 116.00),
-- Pedido original 159; data 19/08/2026; linhas Excel 83
  ('PLAN-20260819-159', 159, '2026-08-19', 'GISLAINE', 'Dinheiro', 27.00, 0.00, 0.00, 0.00, 0.00, 27.00),
-- Pedido original 73; data 20/08/2026; linhas Excel 85
  ('PLAN-20260820-073', 73, '2026-08-20', NULL, 'Cartão de débito', 23.00, 0.00, 0.00, 0.00, 0.00, 23.00),
-- Pedido original 74; data 20/08/2026; linhas Excel 86
  ('PLAN-20260820-074', 74, '2026-08-20', NULL, 'Cartão de débito', 23.00, 0.00, 0.00, 5.00, 0.00, 28.00),
-- Pedido original 75; data 20/08/2026; linhas Excel 87
  ('PLAN-20260820-075', 75, '2026-08-20', NULL, 'Dinheiro', 18.00, 0.00, 0.00, 0.00, 0.00, 18.00),
-- Pedido original 76; data 20/08/2026; linhas Excel 88
  ('PLAN-20260820-076', 76, '2026-08-20', NULL, 'Pix', 18.00, 0.00, 0.00, 0.00, 0.00, 18.00),
-- Pedido original 77; data 20/08/2026; linhas Excel 89
  ('PLAN-20260820-077', 77, '2026-08-20', NULL, 'Pix', 23.00, 0.00, 0.00, 5.00, 0.00, 28.00),
-- Pedido original 78; data 20/08/2026; linhas Excel 90
  ('PLAN-20260820-078', 78, '2026-08-20', NULL, 'Pix', 20.00, 0.00, 6.00, 0.00, 0.00, 26.00),
-- Pedido original 79; data 20/08/2026; linhas Excel 91
  ('PLAN-20260820-079', 79, '2026-08-20', NULL, 'Cartão de débito', 23.00, 0.00, 0.00, 0.00, 0.00, 23.00),
-- Pedido original 80; data 20/08/2026; linhas Excel 92
  ('PLAN-20260820-080', 80, '2026-08-20', NULL, 'Dinheiro', 20.00, 0.00, 6.00, 0.00, 0.00, 26.00),
-- Pedido original 81; data 20/08/2026; linhas Excel 93
  ('PLAN-20260820-081', 81, '2026-08-20', NULL, 'Cartão de crédito', 20.00, 0.00, 0.00, 0.00, 0.00, 20.00),
-- Pedido original 82; data 20/08/2026; linhas Excel 94, 95
  ('PLAN-20260820-082', 82, '2026-08-20', NULL, 'Dinheiro', 38.00, 0.00, 0.00, 0.00, 0.00, 38.00),
-- Pedido original 83; data 20/08/2026; linhas Excel 96, 97
  ('PLAN-20260820-083', 83, '2026-08-20', NULL, 'Dinheiro', 36.00, 0.00, 0.00, 0.00, 0.00, 36.00),
-- Pedido original 84; data 20/08/2026; linhas Excel 98
  ('PLAN-20260820-084', 84, '2026-08-20', NULL, 'Dinheiro', 23.00, 0.00, 0.00, 0.00, 0.00, 23.00),
-- Pedido original 85; data 20/08/2026; linhas Excel 99
  ('PLAN-20260820-085', 85, '2026-08-20', NULL, 'Pix', 25.00, 0.00, 0.00, 5.00, 0.00, 30.00),
-- Pedido original 86; data 20/08/2026; linhas Excel 100
  ('PLAN-20260820-086', 86, '2026-08-20', NULL, 'Dinheiro', 20.00, 0.00, 0.00, 0.00, 0.00, 20.00),
-- Pedido original 87; data 20/08/2026; linhas Excel 101
  ('PLAN-20260820-087', 87, '2026-08-20', NULL, 'Dinheiro', 43.80, 0.00, 0.00, 0.00, 0.00, 43.80),
-- Pedido original 88; data 20/08/2026; linhas Excel 102
  ('PLAN-20260820-088', 88, '2026-08-20', NULL, 'Pix', 20.00, 0.00, 0.00, 5.00, 0.00, 25.00),
-- Pedido original 89; data 20/08/2026; linhas Excel 103
  ('PLAN-20260820-089', 89, '2026-08-20', NULL, 'Pix', 18.00, 0.00, 0.00, 5.00, 0.00, 23.00),
-- Pedido original 90; data 20/08/2026; linhas Excel 104
  ('PLAN-20260820-090', 90, '2026-08-20', NULL, 'Dinheiro', 18.00, 0.00, 0.00, 0.00, 0.00, 18.00),
-- Pedido original 91; data 20/08/2026; linhas Excel 105
  ('PLAN-20260820-091', 91, '2026-08-20', NULL, 'Dinheiro', 20.00, 0.00, 0.00, 0.00, 0.00, 20.00),
-- Pedido original 92; data 20/08/2026; linhas Excel 106
  ('PLAN-20260820-092', 92, '2026-08-20', 'GISLAINE', 'Cartão de débito', 27.00, 0.00, 0.00, 0.00, 0.00, 27.00),
-- Pedido original 93; data 21/08/2026; linhas Excel 108
  ('PLAN-20260821-093', 93, '2026-08-21', NULL, 'Dinheiro', 18.00, 0.00, 0.00, 0.00, 0.00, 18.00),
-- Pedido original 94; data 21/08/2026; linhas Excel 109
  ('PLAN-20260821-094', 94, '2026-08-21', NULL, 'Dinheiro', 18.00, 0.00, 0.00, 0.00, 0.00, 18.00),
-- Pedido original 95; data 21/08/2026; linhas Excel 110
  ('PLAN-20260821-095', 95, '2026-08-21', NULL, 'Dinheiro', 10.00, 0.00, 0.00, 0.00, 0.00, 10.00),
-- Pedido original 96; data 21/08/2026; linhas Excel 111, 112
  ('PLAN-20260821-096', 96, '2026-08-21', NULL, 'Cartão de débito', 38.00, 0.00, 0.00, 0.00, 0.00, 38.00),
-- Pedido original 97; data 21/08/2026; linhas Excel 113
  ('PLAN-20260821-097', 97, '2026-08-21', NULL, 'Cartão de débito', 20.00, 0.00, 0.00, 0.00, 0.00, 20.00),
-- Pedido original 98; data 21/08/2026; linhas Excel 114, 115
  ('PLAN-20260821-098', 98, '2026-08-21', NULL, 'Cartão de débito', 64.00, 0.00, 0.00, 10.00, 0.00, 74.00),
-- Pedido original 99; data 21/08/2026; linhas Excel 116
  ('PLAN-20260821-099', 99, '2026-08-21', NULL, 'Pix', 23.00, 0.00, 0.00, 5.00, 0.00, 28.00),
-- Pedido original 100; data 21/08/2026; linhas Excel 117
  ('PLAN-20260821-100', 100, '2026-08-21', NULL, 'Pix', 36.00, 0.00, 0.00, 0.00, 0.00, 36.00),
-- Pedido original 101; data 21/08/2026; linhas Excel 118
  ('PLAN-20260821-101', 101, '2026-08-21', NULL, 'Cartão de débito', 23.00, 0.00, 0.00, 5.00, 0.00, 28.00),
-- Pedido original 102; data 21/08/2026; linhas Excel 119
  ('PLAN-20260821-102', 102, '2026-08-21', NULL, 'Dinheiro', 18.00, 0.00, 0.00, 0.00, 0.00, 18.00),
-- Pedido original 103; data 21/08/2026; linhas Excel 120
  ('PLAN-20260821-103', 103, '2026-08-21', NULL, 'Dinheiro', 40.00, 0.00, 0.00, 0.00, 0.00, 40.00),
-- Pedido original 106; data 21/08/2026; linhas Excel 121
  ('PLAN-20260821-106', 106, '2026-08-21', NULL, 'Cartão de débito', 20.00, 2.00, 7.00, 0.00, 0.00, 29.00),
-- Pedido original 107; data 21/08/2026; linhas Excel 122
  ('PLAN-20260821-107', 107, '2026-08-21', NULL, 'Cartão de débito', 23.00, 12.00, 0.00, 0.00, 0.00, 35.00),
-- Pedido original 108; data 21/08/2026; linhas Excel 123
  ('PLAN-20260821-108', 108, '2026-08-21', NULL, 'Cartão de débito', 20.00, 0.00, 0.00, 0.00, 0.00, 20.00),
-- Pedido original 109; data 21/08/2026; linhas Excel 124
  ('PLAN-20260821-109', 109, '2026-08-21', NULL, 'Cartão de crédito', 20.00, 0.00, 0.00, 0.00, 0.00, 20.00),
-- Pedido original 110; data 21/08/2026; linhas Excel 125
  ('PLAN-20260821-110', 110, '2026-08-21', NULL, 'Pix', 20.00, 0.00, 0.00, 0.00, 0.00, 20.00),
-- Pedido original 111; data 21/08/2026; linhas Excel 126
  ('PLAN-20260821-111', 111, '2026-08-21', NULL, 'Pix', 20.00, 0.00, 0.00, 0.00, 0.00, 20.00),
-- Pedido original 112; data 21/08/2026; linhas Excel 127
  ('PLAN-20260821-112', 112, '2026-08-21', NULL, 'Dinheiro', 40.00, 0.00, 0.00, 0.00, 0.00, 40.00),
-- Pedido original 113; data 21/08/2026; linhas Excel 128
  ('PLAN-20260821-113', 113, '2026-08-21', NULL, 'Cartão de débito', 23.00, 0.00, 0.00, 0.00, 0.00, 23.00),
-- Pedido original 114; data 21/08/2026; linhas Excel 129
  ('PLAN-20260821-114', 114, '2026-08-21', NULL, 'Cartão de débito', 23.00, 0.00, 6.00, 0.00, 0.00, 29.00),
-- Pedido original 115; data 21/08/2026; linhas Excel 130
  ('PLAN-20260821-115', 115, '2026-08-21', NULL, 'Cartão de débito', 23.00, 0.00, 0.00, 0.00, 0.00, 23.00),
-- Pedido original 116; data 21/08/2026; linhas Excel 131
  ('PLAN-20260821-116', 116, '2026-08-21', NULL, 'Dinheiro', 23.00, 0.00, 0.00, 5.00, 0.00, 28.00),
-- Pedido original 117; data 21/08/2026; linhas Excel 132
  ('PLAN-20260821-117', 117, '2026-08-21', NULL, 'Pix', 20.00, 0.00, 6.00, 5.00, 0.00, 31.00),
-- Pedido original 118; data 21/08/2026; linhas Excel 133
  ('PLAN-20260821-118', 118, '2026-08-21', NULL, 'Dinheiro', 18.00, 0.00, 0.00, 0.00, 0.00, 18.00),
-- Pedido original 119; data 21/08/2026; linhas Excel 134
  ('PLAN-20260821-119', 119, '2026-08-21', NULL, 'Cartão de crédito', 20.00, 0.00, 0.00, 0.00, 0.00, 20.00),
-- Pedido original 120; data 21/08/2026; linhas Excel 135
  ('PLAN-20260821-120', 120, '2026-08-21', NULL, 'Dinheiro', 20.00, 0.00, 14.00, 0.00, 0.00, 34.00),
-- Pedido original 121; data 21/08/2026; linhas Excel 136
  ('PLAN-20260821-121', 121, '2026-08-21', NULL, 'Dinheiro', 25.00, 0.00, 0.00, 0.00, 0.00, 25.00),
-- Pedido original 122; data 21/08/2026; linhas Excel 137
  ('PLAN-20260821-122', 122, '2026-08-21', NULL, 'Pix', 20.00, 0.00, 0.00, 0.00, 0.00, 20.00),
-- Pedido original 123; data 21/08/2026; linhas Excel 138
  ('PLAN-20260821-123', 123, '2026-08-21', NULL, 'Cartão de crédito', 18.00, 0.00, 0.00, 5.00, 0.00, 23.00),
-- Pedido original 124; data 21/08/2026; linhas Excel 139
  ('PLAN-20260821-124', 124, '2026-08-21', NULL, 'Cartão de débito', 18.00, 0.00, 0.00, 5.00, 0.00, 23.00),
-- Pedido original 125; data 21/08/2026; linhas Excel 140
  ('PLAN-20260821-125', 125, '2026-08-21', NULL, 'Cartão de débito', 18.00, 0.00, 0.00, 0.00, 0.00, 18.00),
-- Pedido original 160; data 21/08/2026; linhas Excel 141
  ('PLAN-20260821-160', 160, '2026-08-21', 'GISLAINE', 'Dinheiro', 27.00, 0.00, 0.00, 0.00, 0.00, 27.00),
-- Pedido original 126; data 22/08/2026; linhas Excel 143
  ('PLAN-20260822-126', 126, '2026-08-22', NULL, 'Dinheiro', 20.00, 0.00, 0.00, 5.00, 0.00, 25.00),
-- Pedido original 127; data 22/08/2026; linhas Excel 144
  ('PLAN-20260822-127', 127, '2026-08-22', NULL, 'Cartão de débito', 25.00, 0.00, 0.00, 0.00, 0.00, 25.00),
-- Pedido original 128; data 22/08/2026; linhas Excel 145
  ('PLAN-20260822-128', 128, '2026-08-22', NULL, 'Dinheiro', 72.00, 0.00, 0.00, 0.00, 0.00, 72.00),
-- Pedido original 129; data 22/08/2026; linhas Excel 146
  ('PLAN-20260822-129', 129, '2026-08-22', NULL, 'Dinheiro', 36.00, 0.00, 0.00, 5.00, 0.00, 41.00),
-- Pedido original 130; data 22/08/2026; linhas Excel 147
  ('PLAN-20260822-130', 130, '2026-08-22', NULL, 'Dinheiro', 23.00, 0.00, 0.00, 5.00, 0.00, 28.00),
-- Pedido original 131; data 22/08/2026; linhas Excel 148
  ('PLAN-20260822-131', 131, '2026-08-22', NULL, 'Pix', 40.00, 0.00, 0.00, 5.00, 0.00, 45.00),
-- Pedido original 132; data 22/08/2026; linhas Excel 149
  ('PLAN-20260822-132', 132, '2026-08-22', NULL, 'Dinheiro', 20.00, 0.00, 0.00, 0.00, 0.00, 20.00),
-- Pedido original 133; data 22/08/2026; linhas Excel 150
  ('PLAN-20260822-133', 133, '2026-08-22', NULL, 'Pix', 23.00, 0.00, 0.00, 5.00, 0.00, 28.00),
-- Pedido original 134; data 22/08/2026; linhas Excel 151
  ('PLAN-20260822-134', 134, '2026-08-22', NULL, 'Dinheiro', 18.00, 0.00, 0.00, 5.00, 0.00, 23.00),
-- Pedido original 135; data 22/08/2026; linhas Excel 152
  ('PLAN-20260822-135', 135, '2026-08-22', NULL, 'Pix', 23.00, 15.00, 0.00, 5.00, 0.00, 43.00),
-- Pedido original 136; data 22/08/2026; linhas Excel 153
  ('PLAN-20260822-136', 136, '2026-08-22', NULL, 'Pix', 46.00, 0.00, 0.00, 0.00, 0.00, 46.00),
-- Pedido original 137; data 22/08/2026; linhas Excel 154
  ('PLAN-20260822-137', 137, '2026-08-22', NULL, 'Pix', 23.00, 0.00, 0.00, 5.00, 0.00, 28.00),
-- Pedido original 138; data 22/08/2026; linhas Excel 155
  ('PLAN-20260822-138', 138, '2026-08-22', NULL, 'Dinheiro', 23.00, 0.00, 0.00, 0.00, 0.00, 23.00),
-- Pedido original 139; data 22/08/2026; linhas Excel 156
  ('PLAN-20260822-139', 139, '2026-08-22', NULL, 'Dinheiro', 40.00, 0.00, 0.00, 5.00, 0.00, 45.00),
-- Pedido original 140; data 22/08/2026; linhas Excel 157
  ('PLAN-20260822-140', 140, '2026-08-22', NULL, 'Pix', 18.00, 0.00, 0.00, 0.00, 0.00, 18.00),
-- Pedido original 141; data 22/08/2026; linhas Excel 158
  ('PLAN-20260822-141', 141, '2026-08-22', NULL, 'Dinheiro', 36.00, 0.00, 0.00, 0.00, 0.00, 36.00),
-- Pedido original 142; data 22/08/2026; linhas Excel 159
  ('PLAN-20260822-142', 142, '2026-08-22', NULL, 'Cartão de débito', 18.00, 0.00, 0.00, 0.00, 0.00, 18.00),
-- Pedido original 143; data 22/08/2026; linhas Excel 160
  ('PLAN-20260822-143', 143, '2026-08-22', NULL, 'Dinheiro', 25.00, 0.00, 0.00, 5.00, 0.00, 30.00),
-- Pedido original 144; data 22/08/2026; linhas Excel 161
  ('PLAN-20260822-144', 144, '2026-08-22', NULL, 'Dinheiro', 23.00, 0.00, 0.00, 0.00, 0.00, 23.00),
-- Pedido original 145; data 22/08/2026; linhas Excel 162
  ('PLAN-20260822-145', 145, '2026-08-22', NULL, 'Dinheiro', 20.00, 0.00, 0.00, 0.00, 0.00, 20.00),
-- Pedido original 146; data 22/08/2026; linhas Excel 163
  ('PLAN-20260822-146', 146, '2026-08-22', NULL, 'Dinheiro', 20.00, 0.00, 0.00, 5.00, 0.00, 25.00),
-- Pedido original 147; data 22/08/2026; linhas Excel 164, 165
  ('PLAN-20260822-147', 147, '2026-08-22', NULL, 'Dinheiro', 38.00, 0.00, 0.00, 0.00, 0.00, 38.00),
-- Pedido original 148; data 22/08/2026; linhas Excel 166
  ('PLAN-20260822-148', 148, '2026-08-22', NULL, 'Cartão de débito', 18.00, 0.00, 0.00, 5.00, 0.00, 23.00),
-- Pedido original 149; data 22/08/2026; linhas Excel 167
  ('PLAN-20260822-149', 149, '2026-08-22', NULL, 'Dinheiro', 23.00, 0.00, 0.00, 0.00, 0.00, 23.00),
-- Pedido original 150; data 22/08/2026; linhas Excel 168
  ('PLAN-20260822-150', 150, '2026-08-22', NULL, 'Pix', 20.00, 0.00, 0.00, 0.00, 0.00, 20.00),
-- Pedido original 151; data 22/08/2026; linhas Excel 169
  ('PLAN-20260822-151', 151, '2026-08-22', NULL, 'Cartão de débito', 20.00, 0.00, 0.00, 0.00, 0.00, 20.00),
-- Pedido original 152; data 22/08/2026; linhas Excel 170
  ('PLAN-20260822-152', 152, '2026-08-22', NULL, 'Dinheiro', 18.00, 0.00, 0.00, 5.00, 0.00, 23.00),
-- Pedido original 153; data 22/08/2026; linhas Excel 171
  ('PLAN-20260822-153', 153, '2026-08-22', NULL, 'Pix', 36.00, 0.00, 0.00, 5.00, 0.00, 41.00),
-- Pedido original 154; data 22/08/2026; linhas Excel 172
  ('PLAN-20260822-154', 154, '2026-08-22', NULL, 'Cartão de débito', 23.00, 0.00, 0.00, 0.00, 0.00, 23.00),
-- Pedido original 155; data 22/08/2026; linhas Excel 173, 174
  ('PLAN-20260822-155', 155, '2026-08-22', NULL, 'Cartão de débito', 41.00, 12.00, 0.00, 0.00, 0.00, 53.00),
-- Pedido original 156; data 22/08/2026; linhas Excel 175, 176
  ('PLAN-20260822-156', 156, '2026-08-22', NULL, 'Cartão de débito', 38.00, 0.00, 0.00, 0.00, 0.00, 38.00),
-- Pedido original 157; data 22/08/2026; linhas Excel 177
  ('PLAN-20260822-157', 157, '2026-08-22', NULL, 'Dinheiro', 20.00, 0.00, 0.00, 5.00, 0.00, 25.00),
-- Pedido original 158; data 22/08/2026; linhas Excel 178
  ('PLAN-20260822-158', 158, '2026-08-22', NULL, 'Pix', 23.00, 0.00, 0.00, 0.00, 0.00, 23.00),
-- Pedido original 161; data 22/08/2026; linhas Excel 179
  ('PLAN-20260822-161', 161, '2026-08-22', NULL, 'Pix', 20.00, 0.00, 0.00, 0.00, 0.00, 20.00),
-- Pedido original 162; data 22/08/2026; linhas Excel 180
  ('PLAN-20260822-162', 162, '2026-08-22', NULL, 'Pix', 23.00, 0.00, 0.00, 5.00, 0.00, 28.00),
-- Excecao confirmada pelo usuario: pedido sem tamanho/quantidade usa tamanho UNICO.
-- Pedido original 45; data 18/08/2026; linha Excel 37; adicional R$ 6,00.
  ('PLAN-20260818-045', 45, '2026-08-18', NULL, 'Dinheiro', 0.00, 6.00, 0.00, 0.00, 0.00, 6.00),
-- Pedido original 163; data 22/08/2026; linhas Excel 181, 182; Pix prevalece sobre dinheiro.
  ('PLAN-20260822-163', 163, '2026-08-22', 'GISLAINE', 'Pix', 42.00, 0.00, 0.00, 0.00, 0.00, 42.00);

INSERT INTO _stage_itens (numero_pedido, tamanho, quantidade, valor_unitario, subtotal) VALUES
  ('PLAN-20260817-001', 'M', 2, 20.00, 40.00),
  ('PLAN-20260817-002', 'P', 1, 18.00, 18.00),
  ('PLAN-20260817-003', 'P', 1, 18.00, 18.00),
  ('PLAN-20260817-005', 'M', 1, 20.00, 20.00),
  ('PLAN-20260817-005', 'P', 1, 18.00, 18.00),
  ('PLAN-20260817-006', 'S', 1, 30.00, 30.00),
  ('PLAN-20260817-007', 'E', 2, 25.00, 50.00),
  ('PLAN-20260817-008', 'P', 1, 18.00, 18.00),
  ('PLAN-20260817-009', 'G', 2, 23.00, 46.00),
  ('PLAN-20260817-010', 'G', 1, 23.00, 23.00),
  ('PLAN-20260817-011', 'M', 2, 20.00, 40.00),
  ('PLAN-20260817-011', 'P', 1, 18.00, 18.00),
  ('PLAN-20260817-012', 'P', 1, 18.00, 18.00),
  ('PLAN-20260817-013', 'E', 1, 25.00, 25.00),
  ('PLAN-20260817-014', 'M', 2, 20.00, 40.00),
  ('PLAN-20260817-014', 'P', 1, 18.00, 18.00),
  ('PLAN-20260817-015', 'M', 1, 20.00, 20.00),
  ('PLAN-20260817-016', 'P', 1, 18.00, 18.00),
  ('PLAN-20260817-017', 'M', 2, 20.00, 40.00),
  ('PLAN-20260817-018', 'P', 1, 18.00, 18.00),
  ('PLAN-20260817-019', 'M', 1, 20.00, 20.00),
  ('PLAN-20260817-020', 'M', 13, 20.00, 260.00),
  ('PLAN-20260817-021', 'P', 1, 18.00, 18.00),
  ('PLAN-20260817-022', 'P', 1, 18.00, 18.00),
  ('PLAN-20260817-023', 'P', 1, 18.00, 18.00),
  ('PLAN-20260817-024', 'G', 1, 25.00, 25.00),
  ('PLAN-20260818-025', 'M', 1, 20.00, 20.00),
  ('PLAN-20260818-026', 'M', 1, 20.00, 20.00),
  ('PLAN-20260818-027', 'M', 1, 20.00, 20.00),
  ('PLAN-20260818-028', 'P', 1, 18.00, 18.00),
  ('PLAN-20260818-029', 'E', 1, 27.00, 27.00),
  ('PLAN-20260818-030', 'M', 6, 20.00, 120.00),
  ('PLAN-20260818-031', 'M', 2, 20.00, 40.00),
  ('PLAN-20260818-032', 'M', 1, 20.00, 20.00),
  ('PLAN-20260818-033', 'M', 1, 20.00, 20.00),
  ('PLAN-20260818-034', 'P', 1, 18.00, 18.00),
  ('PLAN-20260818-035', 'G', 2, 23.00, 46.00),
  ('PLAN-20260818-036', 'M', 1, 20.00, 20.00),
  ('PLAN-20260818-037', 'G', 2, 23.00, 46.00),
  ('PLAN-20260818-038', 'M', 1, 20.00, 20.00),
  ('PLAN-20260818-039', 'P', 1, 18.00, 18.00),
  ('PLAN-20260818-040', 'P', 1, 18.00, 18.00),
  ('PLAN-20260818-041', 'M', 1, 20.00, 20.00),
  ('PLAN-20260818-042', 'M', 2, 20.00, 40.00),
  ('PLAN-20260818-043', 'M', 1, 20.00, 20.00),
  ('PLAN-20260818-044', 'P', 1, 18.00, 18.00),
  ('PLAN-20260819-046', 'P', 1, 18.00, 18.00),
  ('PLAN-20260819-047', 'P', 1, 18.00, 18.00),
  ('PLAN-20260819-048', 'P', 2, 18.00, 36.00),
  ('PLAN-20260819-049', 'P', 1, 18.00, 18.00),
  ('PLAN-20260819-050', 'M', 1, 20.00, 20.00),
  ('PLAN-20260819-051', 'M', 3, 20.00, 60.00),
  ('PLAN-20260819-052', 'M', 1, 20.00, 20.00),
  ('PLAN-20260819-053', 'M', 2, 20.00, 40.00),
  ('PLAN-20260819-054', 'M', 1, 20.00, 20.00),
  ('PLAN-20260819-055', 'P', 2, 18.00, 36.00),
  ('PLAN-20260819-056', 'P', 1, 18.00, 18.00),
  ('PLAN-20260819-057', 'M', 1, 20.00, 20.00),
  ('PLAN-20260819-058', 'M', 2, 20.00, 40.00),
  ('PLAN-20260819-059', 'G', 1, 23.00, 23.00),
  ('PLAN-20260819-059', 'P', 2, 18.00, 36.00),
  ('PLAN-20260819-060', 'G', 1, 23.00, 23.00),
  ('PLAN-20260819-061', 'M', 1, 20.00, 20.00),
  ('PLAN-20260819-062', 'M', 1, 20.00, 20.00),
  ('PLAN-20260819-063', 'P', 1, 18.00, 18.00),
  ('PLAN-20260819-064', 'P', 1, 18.00, 18.00),
  ('PLAN-20260819-065', 'P', 1, 18.00, 18.00),
  ('PLAN-20260819-066', 'P', 1, 18.00, 18.00),
  ('PLAN-20260819-067', 'P', 1, 18.00, 18.00),
  ('PLAN-20260819-068', 'P', 1, 18.00, 18.00),
  ('PLAN-20260819-069', 'M', 2, 20.00, 40.00),
  ('PLAN-20260819-070', 'P', 1, 18.00, 18.00),
  ('PLAN-20260819-072', 'M', 1, 20.00, 20.00),
  ('PLAN-20260819-159', 'E', 1, 27.00, 27.00),
  ('PLAN-20260820-073', 'G', 1, 23.00, 23.00),
  ('PLAN-20260820-074', 'G', 1, 23.00, 23.00),
  ('PLAN-20260820-075', 'P', 1, 18.00, 18.00),
  ('PLAN-20260820-076', 'P', 1, 18.00, 18.00),
  ('PLAN-20260820-077', 'G', 1, 23.00, 23.00),
  ('PLAN-20260820-078', 'M', 1, 20.00, 20.00),
  ('PLAN-20260820-079', 'G', 1, 23.00, 23.00),
  ('PLAN-20260820-080', 'M', 1, 20.00, 20.00),
  ('PLAN-20260820-081', 'M', 1, 20.00, 20.00),
  ('PLAN-20260820-082', 'M', 1, 20.00, 20.00),
  ('PLAN-20260820-082', 'P', 1, 18.00, 18.00),
  ('PLAN-20260820-083', 'P', 2, 18.00, 36.00),
  ('PLAN-20260820-084', 'G', 1, 23.00, 23.00),
  ('PLAN-20260820-085', 'E', 1, 25.00, 25.00),
  ('PLAN-20260820-086', 'M', 1, 20.00, 20.00),
  ('PLAN-20260820-087', 'M', 2, 21.90, 43.80),
  ('PLAN-20260820-088', 'M', 1, 20.00, 20.00),
  ('PLAN-20260820-089', 'P', 1, 18.00, 18.00),
  ('PLAN-20260820-090', 'P', 1, 18.00, 18.00),
  ('PLAN-20260820-091', 'M', 1, 20.00, 20.00),
  ('PLAN-20260820-092', 'E', 1, 27.00, 27.00),
  ('PLAN-20260821-093', 'P', 1, 18.00, 18.00),
  ('PLAN-20260821-094', 'P', 1, 18.00, 18.00),
  ('PLAN-20260821-095', 'P', 1, 10.00, 10.00),
  ('PLAN-20260821-096', 'M', 1, 20.00, 20.00),
  ('PLAN-20260821-096', 'P', 1, 18.00, 18.00),
  ('PLAN-20260821-097', 'M', 1, 20.00, 20.00),
  ('PLAN-20260821-098', 'G', 2, 23.00, 46.00),
  ('PLAN-20260821-098', 'P', 1, 18.00, 18.00),
  ('PLAN-20260821-099', 'G', 1, 23.00, 23.00),
  ('PLAN-20260821-100', 'P', 2, 18.00, 36.00),
  ('PLAN-20260821-101', 'G', 1, 23.00, 23.00),
  ('PLAN-20260821-102', 'M', 1, 18.00, 18.00),
  ('PLAN-20260821-103', 'M', 2, 20.00, 40.00),
  ('PLAN-20260821-106', 'M', 1, 20.00, 20.00),
  ('PLAN-20260821-107', 'G', 1, 23.00, 23.00),
  ('PLAN-20260821-108', 'M', 1, 20.00, 20.00),
  ('PLAN-20260821-109', 'M', 1, 20.00, 20.00),
  ('PLAN-20260821-110', 'M', 1, 20.00, 20.00),
  ('PLAN-20260821-111', 'M', 1, 20.00, 20.00),
  ('PLAN-20260821-112', 'M', 2, 20.00, 40.00),
  ('PLAN-20260821-113', 'G', 1, 23.00, 23.00),
  ('PLAN-20260821-114', 'G', 1, 23.00, 23.00),
  ('PLAN-20260821-115', 'G', 1, 23.00, 23.00),
  ('PLAN-20260821-116', 'M', 1, 23.00, 23.00),
  ('PLAN-20260821-117', 'M', 1, 20.00, 20.00),
  ('PLAN-20260821-118', 'P', 1, 18.00, 18.00),
  ('PLAN-20260821-119', 'M', 1, 20.00, 20.00),
  ('PLAN-20260821-120', 'M', 1, 20.00, 20.00),
  ('PLAN-20260821-121', 'E', 1, 25.00, 25.00),
  ('PLAN-20260821-122', 'M', 1, 20.00, 20.00),
  ('PLAN-20260821-123', 'P', 1, 18.00, 18.00),
  ('PLAN-20260821-124', 'P', 1, 18.00, 18.00),
  ('PLAN-20260821-125', 'P', 1, 18.00, 18.00),
  ('PLAN-20260821-160', 'E', 1, 27.00, 27.00),
  ('PLAN-20260822-126', 'M', 1, 20.00, 20.00),
  ('PLAN-20260822-127', 'E', 1, 25.00, 25.00),
  ('PLAN-20260822-128', 'P', 4, 18.00, 72.00),
  ('PLAN-20260822-129', 'P', 2, 18.00, 36.00),
  ('PLAN-20260822-130', 'G', 1, 23.00, 23.00),
  ('PLAN-20260822-131', 'M', 2, 20.00, 40.00),
  ('PLAN-20260822-132', 'M', 1, 20.00, 20.00),
  ('PLAN-20260822-133', 'G', 1, 23.00, 23.00),
  ('PLAN-20260822-134', 'P', 1, 18.00, 18.00),
  ('PLAN-20260822-135', 'G', 1, 23.00, 23.00),
  ('PLAN-20260822-136', 'G', 2, 23.00, 46.00),
  ('PLAN-20260822-137', 'G', 1, 23.00, 23.00),
  ('PLAN-20260822-138', 'G', 1, 23.00, 23.00),
  ('PLAN-20260822-139', 'M', 2, 20.00, 40.00),
  ('PLAN-20260822-140', 'P', 1, 18.00, 18.00),
  ('PLAN-20260822-141', 'P', 2, 18.00, 36.00),
  ('PLAN-20260822-142', 'P', 1, 18.00, 18.00),
  ('PLAN-20260822-143', 'E', 1, 25.00, 25.00),
  ('PLAN-20260822-144', 'G', 1, 23.00, 23.00),
  ('PLAN-20260822-145', 'M', 1, 20.00, 20.00),
  ('PLAN-20260822-146', 'M', 1, 20.00, 20.00),
  ('PLAN-20260822-147', 'M', 1, 20.00, 20.00),
  ('PLAN-20260822-147', 'P', 1, 18.00, 18.00),
  ('PLAN-20260822-148', 'P', 1, 18.00, 18.00),
  ('PLAN-20260822-149', 'G', 1, 23.00, 23.00),
  ('PLAN-20260822-150', 'M', 1, 20.00, 20.00),
  ('PLAN-20260822-151', 'M', 1, 20.00, 20.00),
  ('PLAN-20260822-152', 'P', 1, 18.00, 18.00),
  ('PLAN-20260822-153', 'P', 2, 18.00, 36.00),
  ('PLAN-20260822-154', 'G', 1, 23.00, 23.00),
  ('PLAN-20260822-155', 'G', 1, 23.00, 23.00),
  ('PLAN-20260822-155', 'P', 1, 18.00, 18.00),
  ('PLAN-20260822-156', 'M', 1, 20.00, 20.00),
  ('PLAN-20260822-156', 'P', 1, 18.00, 18.00),
  ('PLAN-20260822-157', 'M', 1, 20.00, 20.00),
  ('PLAN-20260822-158', 'G', 1, 23.00, 23.00),
  ('PLAN-20260822-161', 'M', 1, 20.00, 20.00),
  ('PLAN-20260822-162', 'G', 1, 23.00, 23.00),
-- Excecao confirmada: tamanho UNICO, quantidade 1; o valor de R$ 6,00 fica em adicional.
  ('PLAN-20260818-045', 'UNICO', 1, 0.00, 0.00),
-- Pedido 163 contém dois tamanhos; mantidos como itens distintos.
  ('PLAN-20260822-163', 'P', 1, 22.00, 22.00),
  ('PLAN-20260822-163', 'M', 1, 20.00, 20.00);

-- Criar vendas somente quando o identificador ainda nao existir.
WITH inserted AS (
  INSERT INTO public.vendas (numero_pedido, data_venda, cliente_id, forma_pagamento_id, adicional, bebidas, frete, desconto, subtotal, total, status)
  SELECT s.numero_pedido, s.data_venda,
         (SELECT MIN(c.id) FROM public.clientes c
          WHERE lower(trim(c.nome)) = lower(trim(s.cliente_nome))
            AND (SELECT COUNT(*) FROM public.clientes c2 WHERE lower(trim(c2.nome)) = lower(trim(s.cliente_nome))) = 1),
         (SELECT fp.id FROM public.formas_pagamento fp WHERE fp.nome = s.forma_pagamento AND fp.ativo = TRUE LIMIT 1),
         s.adicional, s.bebidas, s.frete, s.desconto, s.subtotal, s.total, 'FINALIZADA'
  FROM _stage_vendas s
  WHERE NOT EXISTS (SELECT 1 FROM public.vendas v WHERE v.numero_pedido = s.numero_pedido)
  RETURNING id, numero_pedido
)
INSERT INTO _inserted_vendas (numero_pedido, venda_id)
SELECT numero_pedido, id FROM inserted;

-- Inserir itens apenas nas vendas criadas nesta execucao.
INSERT INTO public.venda_itens (venda_id, tamanho, quantidade, valor_unitario, subtotal)
SELECT iv.venda_id, si.tamanho, si.quantidade, si.valor_unitario, si.subtotal
FROM _stage_itens si
JOIN _inserted_vendas iv ON iv.numero_pedido = si.numero_pedido;

-- Conferir identificadores que ja existiam; eles foram ignorados sem alteracao. Os pedidos 45 e 163 agora estao incluidos.
SELECT s.numero_pedido, s.numero_original, s.data_venda, v.id AS id_existente
FROM _stage_vendas s
JOIN public.vendas v ON v.numero_pedido = s.numero_pedido
WHERE NOT EXISTS (SELECT 1 FROM _inserted_vendas i WHERE i.numero_pedido = s.numero_pedido)
ORDER BY s.data_venda, s.numero_original;

-- Resumo desta execucao.
SELECT COUNT(*) AS vendas_inseridas FROM _inserted_vendas;
SELECT COUNT(*) AS itens_inseridos FROM public.venda_itens vi JOIN _inserted_vendas iv ON iv.venda_id = vi.venda_id;
COMMIT;
