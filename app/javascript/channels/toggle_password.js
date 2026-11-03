const initPasswordToggle = () => {
  const toggleIcons = document.querySelectorAll('.toggle-password');

  toggleIcons.forEach(icon => {
    // 既存のリスナーがある場合、一度削除（二重発火防止）してから登録
    icon.removeEventListener('click', togglePasswordHandler);
    icon.addEventListener('click', togglePasswordHandler);
  });
};

// クリック時の処理を関数として独立させる
const togglePasswordHandler = function() {
  // パスワード入力の対象となる兄要素をまとめて取得
  const passwordField = this.parentElement.querySelector('.input-text, .input-password');

  if (passwordField) {
    const type = passwordField.getAttribute('type') === 'password' ? 'text' : 'password';
    passwordField.setAttribute('type', type);

    this.classList.toggle('fa-eye');
    this.classList.toggle('fa-eye-slash');
  }
};

// Railsの画面遷移（Turbo/Turbolinks）と通常読み込みの両方に対応
document.addEventListener('turbo:load', initPasswordToggle);
document.addEventListener('turbolinks:load', initPasswordToggle);
document.addEventListener('DOMContentLoaded', initPasswordToggle);