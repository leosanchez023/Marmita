export function telaLogin(req, res) {
  if (req.isAuthenticated && req.isAuthenticated()) return res.redirect('/vendas/nova');
  const mensagem = req.flash('error')[0] || req.flash('error_msg')[0] || null;
  res.render('pages/login', { layout: false, mensagem });
}

export function logout(req, res, next) {
  req.logout(error => {
    if (error) return next(error);
    req.session.destroy(() => res.redirect('/'));
  });
}
