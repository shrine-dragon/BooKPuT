document.addEventListener('turbolinks:load', () => {
  const titleField = document.getElementById('title-field');
  const apiBtn = document.getElementById('api-search-btn');
  const modal = document.getElementById('search-results-modal');
  const resultsList = document.getElementById('search-results-list');
  const amazonLink = document.getElementById('amazon-link');
  const googleLink = document.getElementById('google-link');

  if (!titleField) return;

  titleField.addEventListener('input', () => {
    const query = encodeURIComponent(titleField.value || "本");
    amazonLink.href = `https://www.amazon.co.jp/s?k=${query}`;
    googleLink.href = `https://www.google.com/search?tbm=isch&q=${query}+表紙`;
  });

  apiBtn?.addEventListener('click', async () => {
    const title = titleField.value;

    if (!title) {
      alert("タイトルを入力してください");
      return;
    }

    const response = await fetch(`https://www.googleapis.com/books/v1/volumes?q=${encodeURIComponent(title)}&maxResults=40`);
    const data = await response.json();

    resultsList.innerHTML = "";
    
    if (data.items) {
      // ソート処理
      const sortedItems = data.items.filter(item => item.volumeInfo.imageLinks?.thumbnail).sort((a, b) => {
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
          document.getElementById('remote-image-url').value = thumbnail;
          document.getElementById('preview-image-container').innerHTML = `
            <div class="preview-image-wrapper">
              <img src="${thumbnail}" class="preview-image">
              <span class="delete-image-btn">削除</span>
            </div>`;
          modal.style.display = "none";
        });
        resultsList.appendChild(card);
      });
      modal.style.display = "flex";
    } else {
      alert("候補が見つかりませんでした。");
    }
  });

  document.getElementById('close-modal')?.addEventListener('click', () => {
    modal.style.display = "none";
  });
});