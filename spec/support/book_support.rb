module BookSupport
  extend ActiveSupport::Concern

  def visit_new_book_path
    # ログインし、トップページに遷移する
    login_as(@user)
    visit root_path
    # トップページに｢投稿する｣ボタンがあることを確認する
    expect(page).to have_selector('.right-bottom-btn-text.post', text: '投稿する', visible: false)
    # ｢投稿する｣ボタンを押すと、新規投稿ページに遷移することを確認する
    click_on('投稿する')
    expect(page).to have_current_path(new_book_path)
  end

  def fill_in_new_post_form
    fill_in 'title', with: @book.title
    image_test('Momose-Akira-no-firstLove-failing.png', 'book[image]')
    select @book.category.name, from: 'category'
    @book.genres.each do |genre|
      check genre.name
    end
    fill_in 'book_content_0', with: @book_content.content
  end

  def show_posted_contents
    # 投稿した画像とタイトルが表示されていることを確認する
    expect(page).to have_selector('.book-posted-image')
    expect(page).to have_content(@book.title)

    # 投稿にカーソルを当てるとカテゴリー名・ジャンル名・内容が表示されることを確認する
    post_element = find('.card-content-wrapper')
    post_element.hover

    expect(page).to have_content("# #{@book.category.name}")

    @book.genres.each do |genre|
      expect(page).to have_content("# #{genre.name}")
    end
    expect(page).to have_content(@book_content.content)
    # style属性の中に、カテゴリーが持つカラーコードが含まれているか確認する
    target_category = Category.find(@book.category_id)
    expect(page).to have_selector(".category-tag[style*='#{target_category.color}']")
  end

  def show_high_rating_posted_contents
    # 高評価した投稿内容が保存されていることを確認する
    # 未実装
  end

  def show_favorite_posted_contents
    # お気に入りに追加した投稿内容が保存されていることを確認する
    # 未実装
  end
end
