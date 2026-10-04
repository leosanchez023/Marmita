export function protegerAplicacao(req, res, next) {
  const publicPaths = new Set(['/','/login']);
  const publicPrefixes = ['/css/','/js/','/img/','/favicon.ico'];

  if (publicPaths.has(req.path) || publicPrefixes.some(prefix => req.path.startsWith(prefix))) {
    return next();
  }

  if (!req.isAuthenticated || !req.isAuthenticated()) {
    if (req.accepts('html')) return res.redirect('/');
    return res.status(401).json({ success: false, message: 'Autenticação necessária.' });
  }

  return next();
}
