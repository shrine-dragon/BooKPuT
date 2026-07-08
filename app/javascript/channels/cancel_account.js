document.addEventListener('turbolinks:load', () => {
  const triggerBtn = document.getElementById('first-cancel-btn');
  const confirmArea = document.getElementById('final-confirm-area');

  if (!triggerBtn || !confirmArea) return;

  triggerBtn.addEventListener('click', () => {
    // 確認エリアを表示
    confirmArea.style.display = 'block';

    // 最初のボタンを非表示にする（二重クリック防止とUI整理のため）
    triggerBtn.parentElement.style.display = 'none';

    // もしページが長くなって確認エリアが画面外に行く可能性があるならスクロール
    confirmArea.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
  });
});