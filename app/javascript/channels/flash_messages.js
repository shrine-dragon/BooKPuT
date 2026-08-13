const fadeOutFlash = () => {
  // すべてのフラッシュメッセージを取得（複数出る場合があるため）
  const flashes = document.querySelectorAll('.flash-message');
  flashes.forEach((flash) => {
    setTimeout(() => {
      // 単純な display: none よりも、フェードアウトさせると綺麗
      flash.style.transition = "opacity 0.5s";
      flash.style.opacity = "0";
      setTimeout(() => {
        flash.style.display = 'none';
      }, 500); // アニメーションが終わってから消す
    }, 3000); 
  });
};

// ページ読み込み時に実行
document.addEventListener('turbolinks:load', fadeOutFlash);

// グローバル（window）に登録して、js.erb からも呼べるようにする
window.fadeOutFlash = fadeOutFlash;