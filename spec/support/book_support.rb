module BookSupport
  extend ActiveSupport::Concern

  def visit_new_book_path
    # ログインし、トップページに遷移する
    login_as(user)
    visit root_path
    # トップページに｢投稿する｣ボタンがあることを確認する
    expect(page).to have_selector('.right-bottom-btn.post', text: '投稿する', visible: false)
    # ｢投稿する｣ボタンを押すと、新規投稿ページに遷移することを確認する
    click_on('投稿する')
    expect(page).to have_current_path(new_book_path)
  end

  def fill_in_new_post_form
    # 必須項目を入力または選択する
    fill_in 'title', with: book.title
    select book.category.name, from: 'category'
    book.genres.each do |genre|
      check genre.name
    end
    fill_in 'book_content_0', with: book_content.content

    # 任意項目の画像を添付する
    image_test('Momose-Akira-no-firstLove-failing.png', 'book[image]')
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

  def check_book_list_in_my_page(user_name, selector_name, text)
    # マイページの指定のリストに指定の内容が存在していることを確認する
    visit user_path(user_name)
    scroll_to(find('.my-page-contents.' + selector_name), align: :center)

    sleep 0.5

    expect(page).to have_content(text + '：1件')
    expect(page).to have_selector('.book-posted-image')
    expect(page).to have_content(book.title)
  end

  def check_no_book_list_in_my_page(selector_name, text)
    visit user_path(user2)
    scroll_to(find('.my-page-contents.' + selector_name), align: :center)

    sleep 0.5

    expect(page).to have_content(text + '：0件')
    expect(page).to have_content('投稿はありません')
    expect(page).to have_no_selector('.book-posted-image')
    expect(page).to have_no_content(book.title)
  end

  def visit_search_books_path
    # 検索ボタンを押すと検索結果ページに遷移することを確認する
    find('.search-btn').click
    has_current_path?(search_books_path, wait: 5)
  end

  def show_search_result
    # 「検索結果」の文字やbook投稿の画像・タイトル・カテゴリー名・ジャンル名・投稿者の画像がそれぞれ表示されていることを確認する
    expect(page).to have_content('検索結果')
    expect(page).to have_selector('.book-posted-image')
    expect(find('.book-posted-image')[:src]).to include('Momose-Akira-no-firstLove-failing')
    expect(page).to have_content(book.title)

    target_card = find('.book-card')
    scroll_to(target_card, align: :center)
    target_card.hover

    expect(page).to have_selector('.hover-details', wait: 5)
    expect(page).to have_content(book.category.name)
    book.genres.each do |genre|
      expect(page).to have_content(genre.name)
    end
    expect(page).to have_selector('.card-badge.book-poster')
    first_content = book.book_contents.first.content
    expect(page).to have_content(first_content[0])
  end
end
