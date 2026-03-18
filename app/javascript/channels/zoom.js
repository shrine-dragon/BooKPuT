$(document).on('turbolinks:load', function() {
  const $slider = $('.book-post-images');
  let isScrolling = false;

  // スライド中の暴発を完全に防ぐ
  $slider.on('beforeChange', () => { isScrolling = true; $('.is-zoomed').remove(); });
  $slider.on('afterChange', () => { isScrolling = false; });

  $(document).off('mouseenter', '.museum-card');
  $(document).on('mouseenter', '.museum-card', function() {
    const $card = $(this);

    // ★ 判定を簡略化：スクロール中 or 既に拡大中 でなければ実行
    if (isScrolling || $('.is-zoomed').length > 0) return;

    // 追加：要素がほとんど見えていない場合は無視する（安全策）
    const rect = $card[0].getBoundingClientRect();
    if (rect.right < 0 || rect.left > window.innerWidth) return;

    const offset = $card.offset();
    const width = $card.outerWidth();
    const height = $card.outerHeight();

    // 1. クローン作成
    const $clone = $card.clone()
      .addClass('is-zoomed')
      .appendTo('body');

    // 2. 初期位置を元のカードに完全一致させる
    $clone.css({
      position: 'absolute',
      top: offset.top,
      left: offset.left,
      width: width + 'px',
      height: height + 'px',
      zIndex: 100000,
      pointerEvents: 'none',
      transition: 'all 0.3s cubic-bezier(0.25, 1, 0.5, 1)', // 滑らかな動き
      background: '#fff',
      transform: 'scale(1)', // 最初は等倍
      boxShadow: '0 4px 15px rgba(0,0,0,0.1)',
      margin: 0 // クローン側のマージンをリセットして位置ズレ防止
    });

    // 3. 拡大実行（1.3倍）
    requestAnimationFrame(() => {
      $clone.css({
        transform: 'scale(1.3)',
        boxShadow: '0 20px 40px rgba(0,0,0,0.4)',
        zIndex: 100001
      });
      $clone.find('.hover-details').css({ 
        opacity: 1, 
        visibility: 'visible',
        display: 'block'
      });
    });

    // 離れたら即座に消去
    $card.one('mouseleave', () => $clone.remove());
  });
});