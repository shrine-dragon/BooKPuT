document.addEventListener('turbolinks:load', () => {
  const fileInput = document.querySelector('#book-image');
  const previewContainer = document.getElementById('image-preview-container');

  if (!fileInput || !previewContainer) return;

  fileInput.addEventListener('change', (e) => {
    const file = e.target.files[0];
    
    // 選択されたら、Railsが出した「再選択メッセージ」をJSで消すとより親切
    const msg = document.querySelector('.image-re-select-message');
    if (msg) msg.style.display = 'none';

    if (file) {
      const reader = new FileReader();
      reader.onload = (event) => {
        previewContainer.innerHTML = `
          <div class="image-preview-wrapper">
            <img src="${event.target.result}" class="preview-image">
            <span class="image-delete-btn">削除</span>
          </div>`;
      };
      reader.readAsDataURL(file);
    }
  });

  previewContainer.addEventListener('click', (e) => {
    if (e.target.classList.contains('image-delete-btn')) {
      previewContainer.innerHTML = "";
      fileInput.value = "";
    }
  });
});