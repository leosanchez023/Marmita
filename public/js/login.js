const toggle = document.getElementById('toggleSenha');
const senha = document.getElementById('senha');
if (toggle && senha) toggle.addEventListener('click', () => {
  senha.type = senha.type === 'password' ? 'text' : 'password';
  toggle.innerHTML = senha.type === 'password' ? '<i class="fa-regular fa-eye"></i>' : '<i class="fa-regular fa-eye-slash"></i>';
});
