document.addEventListener('turbolinks:load', () => {
  const flash = document.querySelector('.flash-message');
  if (flash) {
    setTimeout(() => {
      flash.style.display = 'none';
    }, 3000); // 3000ミリ秒 = 3秒
  }
});