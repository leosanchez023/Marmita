import express from 'express';
import * as controller from './vendas.controller.js';

const router = express.Router();
router.get('/nova', controller.telaNovaVenda);
router.post('/', controller.criar);
router.get('/:id', controller.obter);
router.put('/:id', controller.atualizar);
router.delete('/:id', controller.excluir);

export default router;
