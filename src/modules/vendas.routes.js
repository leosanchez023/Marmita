import express from 'express';
import * as controller from './vendas.controller.js';

const router = express.Router();
router.get('/nova', controller.telaNovaVenda);
router.post('/', controller.criar);

export default router;
