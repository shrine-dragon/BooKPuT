// 共通処理: 現在開いているすべての編集フォームを閉じ、元のテキストを再表示する
function closeAllEditForms() {
  $('.edit-comment-form').each(function() {
    var $form = $(this);
    var $container = $form.closest('.posted-comment-center');
    
    // 隠されていた元のテキストを表示
    $container.find('.posted-comment-text').show();
    // フォームを削除
    $form.remove();
  });
}

// 編集ボタンクリック時の制御
$(document).on('click', '.js-edit-comment-trigger', function(e) {
  e.stopPropagation(); // 外側クリック処理との干渉を防ぐ
  
  var $li = $(this);
  var url = $li.data('url');
  
  // クリックされたコメントのコンテナを特定
  var $commentBox = $li.closest('.js-comment');
  var $form = $commentBox.find('.edit-comment-form');
  
  // すでに自分が編集フォームを開いている場合は、2回押し判定として閉じる
  if ($form.length > 0) {
    closeAllEditForms();
    return;
  }
  
  // 別のフォームが開いていれば先にすべて元に戻す
  closeAllEditForms();

  // Railsへ編集フォームをリクエスト
  $.ajax({
    url: url,
    type: 'GET',
    dataType: 'script'
  });
});

// フォームや送信ボタン以外の場所（document）をクリックしたらキャンセル
$(document).on('click', function(e) {
  // クリックされた場所が編集フォーム内、または編集トリガーでなければすべて閉じる
  if (!$(e.target).closest('.edit-comment-form, .js-edit-comment-trigger').length) {
    closeAllEditForms();
  }
});

// リアルタイム入力判定（コメントの紙飛行機ボタン制御）
$(document).on('input', '.comment-form-text', function() {
  const text_count = $(this).val().trim().length;
  const commentBtn = $(this).closest('.post-comment-field').find('.comment-btn');

  if (text_count === 0) {
    commentBtn.removeClass('is-show');
  } else {
    commentBtn.addClass('is-show');
  }
});