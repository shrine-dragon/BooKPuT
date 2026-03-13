document.addEventListener('turbolinks:load', () => {
  const titleField = document.getElementById('title-field');
  const apiBtn = document.getElementById('api-search-btn');
  const modal = document.getElementById('search-results-modal');
  const resultsList = document.getElementById('search-results-list');
  const amazonLink = document.getElementById('amazon-link');
  const googleLink = document.getElementById('google-link');

  // タイトルフィールドがないページでは一切何もしない
  if (!titleField) return;

  // リンクの更新処理（要素が存在する場合のみ）
  titleField.addEventListener('input', () => {
    const query = encodeURIComponent(titleField.value || "本");
    if (amazonLink) amazonLink.href = `https://www.amazon.co.jp/s?k=${query}`;
    if (googleLink) googleLink.href = `https://www.google.com/search?tbm=isch&q=${query}+表紙`;
  });

  apiBtn?.addEventListener('click', async () => {
    const title = titleField.value;
    if (!title) return alert("タイトルを入力してください");

    const apiKey = apiBtn.dataset.apiKey;
    // URLにキーを付与（これが制限緩和の決め手）
    const url = `https://www.googleapis.com/books/v1/volumes?q=${encodeURIComponent(title)}&maxResults=40&key=${apiKey}`;

    try {
      // 429エラー対策として一旦リクエスト
      const response = await fetch(url);
      
      if (response.status === 429) {
        alert("リクエストが多すぎます。少し時間を置いてから再度お試しください。");
        return;
      }

      const data = await response.json();
      resultsList.innerHTML = "";
      
      if (data.items) {
        // 画像があるものに絞り込み、タイトルに数字が含まれる場合は昇順にソート
        const sortedItems = data.items
          .filter(item => item.volumeInfo.imageLinks?.thumbnail)
          .sort((a, b) => {
            const getNum = (str) => {
              const m = str.match(/\d+/);
              return m ? parseInt(m[0], 10) : 999;
            };
            return getNum(a.volumeInfo.title) - getNum(b.volumeInfo.title);
          });

        sortedItems.forEach(item => {
          const info = item.volumeInfo;
          const thumbnail = info.imageLinks.thumbnail.replace('http:', 'https:');

          const card = document.createElement('div');
          card.className = 'result-card';
          card.innerHTML = `
            <img src="${thumbnail}">
            <p class="result-title">${info.title}</p>
          `;
          
          card.addEventListener('click', () => {
            const remoteField = document.getElementById('remote-image-url');
            const previewCont = document.getElementById('preview-image-container');
            if (remoteField) remoteField.value = thumbnail;
            if (previewCont) {
              previewCont.innerHTML = `
                <div class="preview-image-wrapper">
                  <img src="${thumbnail}" class="preview-image">
                  <span class="delete-image-btn">削除</span>
                </div>`;
            }
            modal.style.display = "none";
          });
          resultsList.appendChild(card);
        });
        modal.style.display = "flex";
      } else {
        alert("候補が見つかりませんでした。");
      }
    } catch (error) {
      console.error("API Error:", error);
    }
  });

  document.getElementById('close-modal')?.addEventListener('click', () => {
    if (modal) modal.style.display = "none";
  });
});