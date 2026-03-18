$(document).on('turbolinks:load', function() {
  const $slider = $('.book-post-images');
  let hoverTimer = null;

  // 1. スライド前後の状態管理
  $slider.on('beforeChange', function() {
    $slider.addClass('is-sliding');
    clearTimeout(hoverTimer);
    $('.museum-card').removeClass('is-hovered'); // 拡大をリセット
  });

  $slider.on('afterChange', function() {
    $slider.removeClass('is-sliding');
  });

  // 2. イベント委譲（$(document).on）を使い、Slickが生成したすべての要素に対応
  $(document).off('mouseenter mouseleave', '.museum-card');

  $(document).on('mouseenter', '.museum-card', function() {
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

  $(document).on('mouseleave', '.museum-card', function() {
    const $card = $(this);
    clearTimeout(hoverTimer);
    $card.removeClass('is-hovered');
  });
});