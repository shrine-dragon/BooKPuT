// Turbolinks環境ではこのイベント名が必須です
document.addEventListener('turbolinks:load', () => {
  const fileInput = document.querySelector('.upload-image');
  const imageList = document.querySelector('.upload-image-list');

  // 要素が見つからない場合はここで終了（他ページでのエラー防止）
  if (!fileInput || !imageList) return;

  fileInput.addEventListener('change', (e) => {
    imageList.innerHTML = "";

    const file = e.target.files[0];
    if (!file) return;

    // 画像のURLを生成して表示
    const blob = window.URL.createObjectURL(file);

    // 画像の要素を付与
    const blobImage = document.createElement('img');
    blobImage.setAttribute('src', blob);
    // 表示サイズを明示的に指定（CSSが当たっていない場合でも見えるようにうる）
    blobImage.style.width = '200px'; 
    blobImage.style.height = 'auto';
    blobImage.style.display = 'block';

    imageList.appendChild(blobImage);

    const deleteBtn = document.createElement('button');
    deleteBtn.innerHTML = "削除";
    deleteBtn.setAttribute('type', 'button'); // form送信を防ぐために必須
    deleteBtn.classList.add('image-delete-btn'); // CSS用

    // 5. 削除ボタンが押された時の処理
    deleteBtn.addEventListener('click', () => {
      fileInput.value = ""; // ファイル選択をリセット
      imageList.innerHTML = ""; // プレビュー表示を消去
    });

    // 6. 画面に画像とボタンを表示
    imageList.appendChild(blobImage);
    imageList.appendChild(deleteBtn);
  });
});