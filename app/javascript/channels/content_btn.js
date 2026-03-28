document.addEventListener('turbolinks:load', () => {
  const remainingText = document.getElementById('remaining-count');
  const container = document.getElementById('contents-container');
  const addButton = document.getElementById('add-content-btn');

  if (!container || !addButton) return;

  const maxFields = 7;

  // 「現在表示されている」フィールドのみを取得する関数
  const getVisibleFields = () => {
    return Array.from(container.querySelectorAll('.content-field')).filter(field => field.style.display !== 'none');
  };

  const updateRemainingCount = () => {
    const visibleFields = getVisibleFields();
    const remaining = maxFields - visibleFields.length;
    
    if (remainingText) {
      remainingText.textContent = `(残り${remaining}項目)`;
    }

    addButton.style.display = (remaining <= 0) ? 'none' : 'inline-flex';
  };

  const updateButtonStates = () => {
    const visibleFields = getVisibleFields();
    
    visibleFields.forEach(field => {
      const removeBtn = field.querySelector('.remove-content-btn');
      if (removeBtn) {
        // 表示されているのが1つだけならマイナスボタンを隠す
        removeBtn.style.display = (visibleFields.length > 1) ? 'inline-block' : 'none';
      }
    });
  };

  updateButtonStates();

  // プラスボタンの処理
  addButton.addEventListener('click', () => {
    const allFields = container.querySelectorAll('.content-field');
    const visibleFields = getVisibleFields();

    // 1. まず非表示になっているフィールド（以前消したフィールド）があれば、それを再表示する
    const hiddenField = Array.from(allFields).find(field => field.style.display === 'none');

    if (hiddenField) {
      hiddenField.style.display = 'flex'; // 元の表示形式に合わせる（flexやblockなど）
    } else if (allFields.length < maxFields) {
      // 2. 非表示のものがなく、かつ最大数に達していなければ新規作成（クローン）
      const lastField = allFields[allFields.length - 1];
      const newField = lastField.cloneNode(true);
      newField.style.display = 'flex'; 

      const nextIndex = allFields.length;
      
      newField.querySelectorAll('input').forEach(input => {
        input.value = '';
        input.id = input.id.replace(/\d+$/, nextIndex); 
        input.name = input.name.replace(/\[\d+\]/g, `[${nextIndex}]`);
      });

      const errorWrapper = newField.querySelector('.error-wrapper');
      if (errorWrapper) errorWrapper.innerHTML = '';

      container.appendChild(newField);
    }

    updateButtonStates();
    updateRemainingCount();
  });

  // マイナスボタンの処理
  container.addEventListener('click', (e) => {
    if (e.target.classList.contains('remove-content-btn')) {
      const field = e.target.closest('.content-field');
      
      // 物理的に削除せず、非表示にするだけ（中身のvalueは維持される）
      field.style.display = 'none';
      
      updateButtonStates();
      updateRemainingCount();
    }
  });

  updateRemainingCount();
});