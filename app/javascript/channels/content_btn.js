document.addEventListener('turbolinks:load', () => {
  const remainingText = document.getElementById('remaining-count');

  const container = document.getElementById('contents-container');
  const addButton = document.getElementById('add-content-btn');

  if (!container || !addButton) return;

  const maxFields = 7;

  const updateRemainingCount = () => {
    const currentFields = container.querySelectorAll('.content-field').length;
    const remaining = maxFields - currentFields;
    
    if (remainingText) {
      remainingText.textContent = `(残り${remaining}項目)`;
    }

    // ついでに、残り0ならボタンを非表示にするなどの制御も可能です
    if (remaining <= 0) {
      addButton.style.display = 'none';
    } else {
      addButton.style.display = 'inline-flex';
    }
  };

  // ボタンの状態（表示・非表示）を更新する共通関数
  const updateButtonStates = () => {
    const fields = container.querySelectorAll('.content-field');
    
    // 1つしかなければマイナスボタンを隠す
    fields.forEach(field => {
      const removeBtn = field.querySelector('.remove-content-btn');
      if (removeBtn) {
        removeBtn.style.display = (fields.length > 1) ? 'inline-block' : 'none';
      }
    });
  };

  // 起動時（エラー戻り時含む）に実行
  updateButtonStates();

  // プラスボタンの処理
  addButton.addEventListener('click', () => {
    const fields = container.querySelectorAll('.content-field');
    if (fields.length < maxFields) {
      // 最初の要素ではなく、常に最新の要素をコピー元にすると構造が安定する
      const lastField = fields[fields.length - 1];
      const newField = lastField.cloneNode(true);

      const nextIndex = fields.length;
      
      newField.querySelectorAll('input').forEach(input => {
        input.value = '';
        // id と name を連番に置換
        // id: book_content_0 -> book_content_1
        input.id = input.id.replace(/\d+$/, nextIndex); 
        // name: book[book_contents_attributes][0][content] -> ...[1][content]
        input.name = input.name.replace(/\[\d+\]/g, `[${nextIndex}]`);
      });

      // エラー表示をクリア
      const errorWrapper = newField.querySelector('.error-wrapper');
      if (errorWrapper) errorWrapper.innerHTML = '';

      container.appendChild(newField);
      updateButtonStates();
    }
    setTimeout(updateRemainingCount, 0);
  });

  // マイナスボタンの処理（イベントデリゲート）
  container.addEventListener('click', (e) => {
    if (e.target.classList.contains('remove-content-btn')) {
      e.target.closest('.content-field').remove();
      updateButtonStates();
      setTimeout(updateRemainingCount, 0);
    }
  });
  updateRemainingCount();
});