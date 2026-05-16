document.addEventListener('turbolinks:load', () => {
  $(document).on('input', '.comment-form-text', function() {
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