document.addEventListener('turbolinks:load', () => {
  const STEP = 10; // 1回に出す件数
  const $list = $('#js-comment-list');
  if (!$list.length) return;

  // 現在「何件表示すべきか」を保持する変数
  let currentVisibleCount = STEP;

  function enforceLimit() {
    const $items = $list.find('.js-comment');
    const total = $items.length;
    const $numberLabel = $('.posted-comment-number');
    const $container = $('.view-more-comments-container');
    const $viewMoreBtn = $('#view-more-comments');
    const $hideBtn = $('#hide-comments');

    if (total > 0) {
      // 1件以上ある場合
      $list.find('.none-comment').remove(); // 「なし」メッセージを消す
      $numberLabel.text('コメント ' + total).show(); // ★ここでテキストを最新件数に更新して表示
    } else {
      // 0件の場合
      $numberLabel.hide();
      if ($list.find('.none-comment').length === 0) {
        $list.append('<div class="empty-message none-comment"><p>コメントはありません</p></div>');
      }
      $container.hide();
      return;
    }
    // ------------------------------------------

    // 1. 全件数が表示予定数以下なら、ボタンを隠して全部出す
    if (total <= currentVisibleCount) {
      $items.show();
      // 表示件数がSTEP(10)以下のときはコンテナごと隠す
      if (total <= STEP) {
        $container.hide();
      } else {
        // 11件以上あるが全表示されているときは「折りたたむ」だけ出す
        $container.show();
        $viewMoreBtn.hide();
        $hideBtn.show();
      }
    } else {
      // 制限が必要な場合（total > currentVisibleCount）
      $container.show();
      $viewMoreBtn.show();
      $hideBtn.hide();
      $items.hide().slice(0, currentVisibleCount).show();
    }
  }

  // 監視設定
  const observer = new MutationObserver(() => {
    enforceLimit();
  });
  
  // subtree: true にし、ターゲットの中身がどう変わっても検知するようにします
  observer.observe($list[0], { 
    childList: true, 
    subtree: true, 
    characterData: true 
  });

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
    // 折りたたんだらコメント欄の先頭へスムーズにスクロールさせると親切です
    $('html, body').animate({ scrollTop: $list.offset().top - 100 }, 200);
  });
});