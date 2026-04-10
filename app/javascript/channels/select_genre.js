document.addEventListener('turbolinks:load', () => {
  const categorySelect = document.getElementById('category');
  const genreSection = document.getElementById('genre-section');
  const genreOptions = document.querySelectorAll('.genre-option');
  const checkboxes = document.querySelectorAll('.genre-checkbox');
  
  if (!categorySelect || !genreSection) return;

  const updateGenreDisplay = (isInitialLoad = false) => {
    const selectedCategoryId = categorySelect.value;
    const hiddenIds = ['0', '10', '11', '12']; 
    
    // 表示・非表示の切り替え
    if (selectedCategoryId === "" || hiddenIds.includes(selectedCategoryId)) {
      genreSection.style.display = 'none';
      // 手動でカテゴリーを変えた時だけチェックを消す
      if (!isInitialLoad) clearAllChecks();
 n
    } else {
      genreSection.style.display = 'flex';
      
      genreOptions.forEach(option => {
        const catId = String(option.dataset.categoryId);
        const cb = option.querySelector('input');

        if (catId === String(selectedCategoryId) || catId === "999") {
          option.style.display = 'block';
        } else {
          option.style.display = 'none';
          // 【重要】ここがポイント！
          // カテゴリーを「手動で切り替えた時」だけ、非表示になった項目のチェックを外す
          // ページ読み込み時(isInitialLoad)は、非表示でもチェックを維持させる
          if (!isInitialLoad && cb) {
            cb.checked = false;
          }
        }
      });
      updateCheckboxLimit();
    }
  };

  function updateCheckboxLimit() {
    // 全チェックボックスの中から、チェックされている「数」を数える
    // ※ 3つ制限は表示・非表示に関わらず「チェックされている総数」で判断
    const checkedBoxes = Array.from(checkboxes).filter(cb => cb.checked);
    const checkedCount = checkedBoxes.length;

    // 「その他(900)」「回答しない(901)」の排他制御
    const isExclusiveSelected = checkedBoxes.some(cb => ['900', '901'].includes(cb.value));

    checkboxes.forEach(cb => {
      if (isExclusiveSelected) {
        // 排他項目が選ばれている場合、チェックされていないものは全て無効
        cb.disabled = !cb.checked;
      } else {
        // 通常時：3つ制限
        cb.disabled = !cb.checked && checkedCount >= 3;
      }
      
      // スタイル反映
      cb.parentElement.style.opacity = cb.disabled ? '0.5' : '1';
      cb.parentElement.style.pointerEvents = cb.disabled ? 'none' : 'auto';
    });
  }

  function clearAllChecks() {
    checkboxes.forEach(cb => {
      cb.checked = false;
      cb.disabled = false;
      cb.parentElement.style.opacity = '1';
      cb.parentElement.style.pointerEvents = 'auto';
    });
  }

  categorySelect.addEventListener('change', () => updateGenreDisplay(false));
  
  checkboxes.forEach(cb => {
    cb.addEventListener('change', updateCheckboxLimit);
  });

  // 初回実行：Railsが生成したHTMLの状態を壊さないように true を渡す
  updateGenreDisplay(true);
});