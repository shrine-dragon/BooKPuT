document.addEventListener('turbolinks:load', () => {
  const fileInput = document.querySelector('.upload-image');
  const previewContainer = document.getElementById('preview-image-container');

  console.log('Input:', fileInput);
  console.log('Container:', previewContainer);

  if (!fileInput || !previewContainer) return;

  fileInput.addEventListener('change', (e) => {
    console.log('画像のプレビュー')
    const file = e.target.files[0];
    
    // 選択されたら、Railsが出した「再選択メッセージ」をJSで消すとより親切
    const msg = document.querySelector('.image-re-select-message');
    if (msg) msg.style.display = 'none';

    if (file) {
      const reader = new FileReader();
      reader.onload = (event) => {
        previewContainer.innerHTML = `
          <div class="preview-image-wrapper">
            <img src="${event.target.result}" class="preview-image">
            <span class="delete-image-btn">削除</span>
          </div>`;
      };
      reader.readAsDataURL(file);
    }
  });

  previewContainer.addEventListener('click', (e) => {
    console.log('画像のプレビュー')
    if (e.target.classList.contains('delete-image-btn')) {
      previewContainer.innerHTML = "";
      fileInput.value = "";
      
      // もし削除フラグ（hidden_field）がある場合はここもリセット
      const deleteFlag = document.getElementById('delete-image-flag');
      if (deleteFlag) deleteFlag.value = '1'; 
    }
  });
});