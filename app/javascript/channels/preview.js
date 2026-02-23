document.addEventListener('turbolinks:load', () => {
  const fileInput = document.querySelector('.upload-image');
  const imageList = document.querySelector('.upload-image-list');

  if (!fileInput || !imageList) return;

  // 削除処理を関数として独立させる
  const deleteImage = () => {
    fileInput.value = ""; // ファイル選択をリセット
    imageList.innerHTML = ""; // プレビュー表示を消去

    // 隠しフィールドがあれば '1' (削除する) に書き換える
    const deleteFlag = document.getElementById('delete-image-flag');
    if (deleteFlag) {
      deleteFlag.value = '1';
    }
  };

  // 新しく画像を選択した時のプレビューを生成
  fileInput.addEventListener('change', (e) => {
    // 新しく画像が選ばれたら削除フラグを '0' に戻す
    const deleteFlag = document.getElementById('delete-image-flag');
    if (deleteFlag) deleteFlag.value = '0';
    
    const file = e.target.files[0];
    if (!file) {
      deleteImage();
      return;
    }

    imageList.innerHTML = "";
    const blob = window.URL.createObjectURL(file);
    const blobImage = document.createElement('img');
    blobImage.setAttribute('src', blob);
    blobImage.classList.add('preview-image'); // CSSクラスを統一

    const deleteBtn = document.createElement('button');
    deleteBtn.innerHTML = "削除";
    deleteBtn.setAttribute('type', 'button');
    deleteBtn.classList.add('image-delete-btn');

    // 生成したボタンに削除イベントを登録
    deleteBtn.addEventListener('click', deleteImage);

    imageList.appendChild(blobImage);
    imageList.appendChild(deleteBtn);
  });

  // 最初から表示されている（編集時の）削除ボタンにもイベントを登録
  // イベントデリゲーションという手法を使い、imageList内のどこかがクリックされた時に判定する
  imageList.addEventListener('click', (e) => {
    if (e.target.classList.contains('image-delete-btn')) {
      deleteImage();
    }
  });
});