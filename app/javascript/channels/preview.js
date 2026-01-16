// Turbolinks環境ではこのイベント名が必須です
document.addEventListener('turbolinks:load', () => {
  const fileInput = document.querySelector('.upload-image');
  const imageList = document.querySelector('.upload-image-list');

  // 要素が見つからない場合はここで終了（他ページでのエラー防止）
  if (!fileInput || !imageList) return;

  fileInput.addEventListener('change', (e) => {
    // 既存のプレビューがあれば削除
    const alreadyImage = imageList.querySelector('img');
    if (alreadyImage) alreadyImage.remove();

    const file = e.target.files[0];
    if (!file) return;

    // 画像のURLを生成して表示
    const blob = window.URL.createObjectURL(file);
    const blobImage = document.createElement('img');
    blobImage.setAttribute('src', blob);
    
    // 表示サイズを明示的に指定（CSSが当たっていない場合でも見えるように）
    blobImage.style.width = '200px'; 
    blobImage.style.height = 'auto';

    imageList.appendChild(blobImage);
  });
});