document.addEventListener('turbolinks:load', () => {
  const LIMIT = 10;

  function refreshComments() {
    const $list = $('#js-comment-list');
    const $items = $list.find('.js-comment');
    const total = $items.length;
    const $container = $('.view-more-comments-container');
    const $viewMoreBtn = $('#view-more-comments');
    const $hideBtn = $('#hide-comments');

    // 件数による基本表示
    if (total <= LIMIT) {
      $container.hide();
      $items.show();
      return;
    }

    $container.show();

    // 「折りたたむ」が見えている（全表示モード）かどうかの判定
    if ($hideBtn.is(':visible')) {
      // 展開状態を維持（パッと表示）
      $items.show();
      $viewMoreBtn.hide();
      $hideBtn.show();
    } else {
      // 制限状態を維持（11件目以降をパッと隠す）
      $items.hide().slice(0, LIMIT).show();
      $viewMoreBtn.show();
      $hideBtn.hide();
    }
  }

  // ボタンクリックイベント
  $(document).off('click', '#view-more-comments').on('click', '#view-more-comments', function() {
    $(this).hide();
    $('#hide-comments').show();
    $('#js-comment-list .js-comment').show(); // 全件パッと表示
  });

  // 「折りたたむ」クリック：アニメーションなしでパッと隠す
  $(document).off('click', '#hide-comments').on('click', '#hide-comments', function() {
    $(this).hide();
    $('#view-more-comments').show();
    // 11件目以降をパッと隠す
    $('#js-comment-list .js-comment').hide().slice(0, LIMIT).show();
  });

  // Railsからの合図（投稿・削除）を受けて実行
  $(document).on('comment:updated', function() {
    refreshComments();
  });

  // 初回実行
  refreshComments();
});