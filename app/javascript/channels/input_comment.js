document.addEventListener('turbolinks:load', () => {
  $(document).on('input', '.comment-form-text', function() {
    // comment-form-textの要素を取得(val)
    // →不要な空白（スペース、タブ、改行など）を取り除く(trim)
    // →文字列の数をtext_countに収める
    const text_count = $(this).val().trim().length;
    const commentBtn = $(this).closest('.post-comment-field').find('.comment-btn');

    if(!commentBtn) return;

    if (text_count === 0) {
      commentBtn.removeClass('is-show');
    } else {
      commentBtn.addClass('is-show');
    }
  });
});