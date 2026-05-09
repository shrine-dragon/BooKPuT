document.addEventListener('turbolinks:load', () => {
  const STEP = 10; // 1回に出す件数
  const $list = $('#js-comment-list');
  if (!$list.length) return;

  // 現在「何件表示すべきか」を保持する変数
  let currentVisibleCount = STEP;

  function enforceLimit() {
    const $items = $list.find('.js-comment');
    const total = $items.length;
    const $container = $('.view-more-comments-container');
    const $viewMoreBtn = $('#view-more-comments');
    const $hideBtn = $('#hide-comments');

    // 1. 全件数が表示予定数以下なら、ボタンを隠して全部出す
    if (total <= currentVisibleCount) {
      $items.show();
      // もし一度でも「もっと見る」を押して全表示になったなら「折りたたむ」だけ出す
      if (currentVisibleCount > STEP) {
        $viewMoreBtn.hide();
        $hideBtn.show();
      } else {
        $container.hide();
      }
      return;
    }

    // 2. 制限が必要な場合
    $container.show();
    $viewMoreBtn.show();
    $hideBtn.hide();

    // 決まった件数だけ表示し、残りをパッと隠す
    $items.hide().slice(0, currentVisibleCount).show();
  }

  // 監視設定
  const observer = new MutationObserver(() => {
    // 投稿・削除されたときは、表示数を初期（10件）に戻さず、
    // 現在の表示枠を維持したまま再計算する
    enforceLimit();
  });
  observer.observe($list[0], { childList: true });

  // 初期実行
  enforceLimit();

  // 「もっと見る」クリック：表示枠を10増やす
  $(document).off('click', '#view-more-comments').on('click', '#view-more-comments', function() {
    currentVisibleCount += STEP;
    enforceLimit();
  });

  // 「折りたたむ」クリック：表示枠を10（初期値）に戻す
  $(document).off('click', '#hide-comments').on('click', '#hide-comments', function() {
    currentVisibleCount = STEP;
    enforceLimit();
    // 折りたたんだらコメント欄の先頭へスムーズにスクロールさせると親切
    $('html, body').animate({ scrollTop: $list.offset().top - 100 }, 200);
  });
});