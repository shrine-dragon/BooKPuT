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

  def show_posted_contents
    # 投稿した画像とタイトルが表示されていることを確認する
    expect(page).to have_selector('.book-posted-image')
    expect(page).to have_content(@book.title)
    # 投稿にカーソルを当てるとカテゴリー名と内容が表示されることを確認する
    post_element = find('.card-content-wrapper')
    post_element.hover

    expect(page).to have_content('# 漫画', wait: 5)
    expect(page).to have_content('1つ目の内容項目です')
    # style属性の中に、カテゴリーが持つカラーコードが含まれているか確認する
    target_category = Category.find(1)
    expect(page).to have_selector(".category-tag[style*='#{target_category.color}']")
  end

  def new_post
    # ログインし、新規投稿ページへ遷移する
    login_as @user
    visit_new_book_path
    # 各項目を入力または選択する
    fill_in 'title', with: @book.title

    image_test('Momose-Akira-no-firstLove-failing.png', 'book[image]')

    category_name = '漫画'
    select category_name, from: 'category'
    target_category = Category.find_by(name: category_name)

    check '少年漫画'
    check '少女漫画'
    check '青年漫画'

    (0..6).each do |i|
      fill_in "book[book_contents_attributes][#{i}][content]", with: "#{i+1}つ目の内容項目です"
      if i < 6
        find('.plus-btn').click
      end
    end

    # 投稿ボタンを押す
    click_on('投稿する')

    # トップページに遷移し、フラッシュメッセージが表示されていることを確認する
    expect(page).to have_current_path(root_path)
    expect(page).to have_content('投稿しました')

    show_posted_contents
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
