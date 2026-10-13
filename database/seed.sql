
BEGIN;

INSERT INTO public.usuario (nome, email, senha, ativo)
VALUES (
    'Administrador',
    'admin@marmitaria.com',
    '$2b$10$KBH0zlU0imSXp36GydETO.qTFPi.DM9hxYnUenZuyVn1CU.nuE9te',
    TRUE
)
ON CONFLICT (email) DO NOTHING;

COMMIT;
