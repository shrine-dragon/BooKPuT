document.addEventListener('turbolinks:load', () => {
  const titleField = document.getElementById('title-field');
  const amazonLink = document.getElementById('amazon-link');
  const googleLink = document.getElementById('google-link');

  if (titleField && amazonLink && googleLink) {
    titleField.addEventListener('input', () => {
      const query = encodeURIComponent(titleField.value || "本");
      amazonLink.href = `https://www.amazon.co.jp/s?k=${query}`;
      googleLink.href = `https://www.google.com/search?tbm=isch&q=${query}+表紙`;
    });
  }
});