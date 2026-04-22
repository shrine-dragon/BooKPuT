document.addEventListener('turbolinks:load', () => {
  const commentFormText = document.querySelector('.comment-form-text');
  const commentBtn = document.querySelector('.comment-btn');

  if(!commentFormText) return;

  commentFormText.addEventListener('input', () => {
    const text_count = commentFormText.value.trim().length;
    if (text_count == 0){
      commentBtn.classList.remove('is-show');
    } else {
      commentBtn.classList.add('is-show');
    }
  });
});