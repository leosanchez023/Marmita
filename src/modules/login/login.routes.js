import express from 'express';
import passport from 'passport';
import * as controller from './login.controller.js';

const router = express.Router();

router.get('/', controller.telaLogin);
router.post('/login', passport.authenticate('local', {
  successRedirect: '/vendas/nova',
  failureRedirect: '/',
  failureFlash: true
}));
router.get('/logout', controller.logout);

export default router;
