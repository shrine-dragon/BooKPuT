document.addEventListener('turbolinks:load', () => {
  const container = document.getElementById('contents-container');
  const addBtn = document.getElementById('add-content-btn');
  if (!addBtn) return;

  addBtn.addEventListener('click', () => {
    const fields = container.querySelectorAll('.content-field');
    if (fields.length < 7) {
      const newIndex = new Date().getTime(); // 重複しないインデックス
      const newField = `
        <div class="content-field">
          <input class="input-text" placeholder="20〜50文字以内" 
                 type="text" name="book[book_contents_attributes][${newIndex}][content]">
        </div>`;
      container.insertAdjacentHTML('beforeend', newField);
      
      if (fields.length + 1 >= 7) addBtn.style.display = 'none';
    }
  });
});