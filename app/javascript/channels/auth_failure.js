document.addEventListener('turbolinks:load', () => {
  // data-auth-trigger="true" が設定された要素を探す
  const authTrigger = document.querySelector('[data-auth-trigger="true"]');
  
  if (authTrigger) {
    const loginModal = document.querySelector('.modal.log-in');
    const overlay = document.getElementById('modal-overlay');

    if (loginModal && overlay) {
      loginModal.classList.add('is-center');
      loginModal.style.setProperty('display', 'flex', 'important');
      overlay.style.display = 'block';
    }
  }
});