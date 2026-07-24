$(document).on('turbolinks:load', function() {
  const $slider = $('.book-cards');
  let hoverTimer = null;

  // タッチデバイスかどうかを判定（スマホ・タブレットは true）
  const isTouchDevice = 'ontouchstart' in window || navigator.maxTouchPoints > 0;

  // スライド前後の状態管理
  $slider.on('beforeChange', function() {
    $slider.addClass('is-sliding');
    clearTimeout(hoverTimer);
    $('.book-card').removeClass('is-hovered');
  });

  $slider.on('afterChange', function() {
    $slider.removeClass('is-sliding');
  });

  // イベント委譲をリセット
  $(document).off('mouseenter mouseleave', '.book-card');

  // タッチデバイス以外（PC）のみ、ホバーアクションを登録する
  if (!isTouchDevice) {
    $(document).on('mouseenter', '.book-card', function() {
      // スライド中なら無視
      if ($slider.hasClass('is-sliding')) return;

      const $card = $(this);
      
      // Amazonのような「溜め」を作る
      hoverTimer = setTimeout(() => {
        // 待機中にスライドが始まっていないか最終チェック
        if (!$slider.hasClass('is-sliding')) {
          $card.addClass('is-hovered');
        }
      }, 150); // 150msホバーで拡大
    });

    $(document).on('mouseleave', '.book-card', function() {
      const $card = $(this);
      clearTimeout(hoverTimer);
      $card.removeClass('is-hovered');
    });
  }
});