module BookSupport
  extend ActiveSupport::Concern

  def visit_new_book_path
    # ログインし、トップページに遷移する
    login_as(user)
    visit root_path
    # トップページに｢投稿する｣ボタンがあることを確認する
    expect(page).to have_selector('.right-bottom-btn-text.post', text: '投稿する', visible: false)
    # ｢投稿する｣ボタンを押すと、新規投稿ページに遷移することを確認する
    click_on('投稿する')
    expect(page).to have_current_path(new_book_path)
  end

  def fill_in_new_post_form
    fill_in 'title', with: book.title
    image_test('Momose-Akira-no-firstLove-failing.png', 'book[image]')
    select book.category.name, from: 'category'
    book.genres.each do |genre|
      check genre.name
    end
    fill_in 'book_content_0', with: book_content.content
  end

  def visit_book_path
    visit root_path
    # 既存の投稿の詳細ページに遷移する
    expect(page).to have_selector('.book-posted-image')
    expect(page).to have_content(book.title)
    find('.book-card-link').click
    expect(page).to have_current_path(book_path(book))
    expect(page).to have_content('投稿詳細')
  end
end
