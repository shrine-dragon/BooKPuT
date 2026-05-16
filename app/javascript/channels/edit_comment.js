$(document).on('click', '.js-edit-comment-trigger', function() {
  // 1. 他で開いている編集フォームをすべてキャンセル（1つだけに制限）
  $('.edit-comment-form').each(function() {
    // フォームを消して、元のテキストを表示（必要ならここで元のテキストに戻す処理を入れる）
    $(this).closest('.posted-comment-center').find('.posted-comment-text').show();
    $(this).remove();
  });

  const url = $(this).data('url');
  $.ajax({
    url: url,
    type: 'GET',
    dataType: 'script'
  });
});

// 入力判定（確実にボタンを show/hide する）
$(document).on('input', '.edit-input', function() {
  const form = $(this).closest('.edit-comment-form');
  const submitBtn = form.find('.edit-submit-btn');
  
  if ($(this).val().trim().length > 0) {
    submitBtn.attr('style', 'display: flex !important;'); // 強力に表示
  } else {
    submitBtn.attr('style', 'display: none !important;'); // 強力に非表示
  }
});