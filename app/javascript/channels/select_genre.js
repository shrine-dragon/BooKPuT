document.addEventListener('turbolinks:load', () => {
  const categorySelect = document.getElementById('category');
  const genreSection = document.getElementById('genre-section');
  const genreOptions = document.querySelectorAll('.genre-option');
  const checkboxes = document.querySelectorAll('.genre-checkbox');
  
  if (!categorySelect || !genreSection) return;

  const updateGenreDisplay = (isInitialLoad = false) => {
    const selectedCategoryId = categorySelect.value;
    const hiddenIds = ['0', '10', '11']; 
    
    // 表示・非表示の切り替え
    if (selectedCategoryId === "" || hiddenIds.includes(selectedCategoryId)) {
      genreSection.style.display = 'none';
      // 手動でカテゴリーを変えた時だけチェックを消す
      if (!isInitialLoad) clearAllChecks();
    } else {
      genreSection.style.display = 'flex';
      
      genreOptions.forEach(option => {
        const catId = String(option.dataset.categoryId);
        const cb = option.querySelector('input');

        // 関係ないジャンルが隠れ、そのカテゴリー専用のジャンル ＋ 共通ジャンル(その他・回答しない)だけがパッと切り替わって表示される仕組み
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

  function updateCheckboxLimit(e) {
    // 今回クリックされた要素（イベントが発生した場合のみ）
    const target = e ? e.target : null;

    // 「回答しない(901)」のID定義
    const exclusiveIds = ['901'];

    // もし今回クリックされたのが排他項目（回答しない等）で、かつチェックを入れた場合
    if (target && exclusiveIds.includes(target.value) && target.checked) {
      checkboxes.forEach(cb => {
        if (cb !== target) cb.checked = false; // 自分以外をすべて解除
      });
    } 
    // もし今回クリックされたのが通常項目で、かつすでに排他項目がチェックされていた場合
    else if (target && !exclusiveIds.includes(target.value) && target.checked) {
      checkboxes.forEach(cb => {
        if (exclusiveIds.includes(cb.value)) cb.checked = false; // 排他項目のチェックを解除
      });
    }

    const checkedBoxes = Array.from(checkboxes).filter(cb => cb.checked);
    const checkedCount = checkedBoxes.length;
    const isExclusiveSelected = checkedBoxes.some(cb => exclusiveIds.includes(cb.value));

    checkboxes.forEach(cb => {
      if (isExclusiveSelected) {
        cb.disabled = !cb.checked;
      } else {
        cb.disabled = !cb.checked && checkedCount >= 3;
      }
      
      // スタイル反映
      const parent = cb.parentElement;
      if (cb.disabled) {
        parent.style.opacity = '0.5';
        parent.style.pointerEvents = 'none';
      } else {
        parent.style.opacity = '1';
        parent.style.pointerEvents = 'auto';
      }
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