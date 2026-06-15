module ContactSupport
  extend ActiveSupport::Concern

  def visit_new_contact_path
    # トップページに遷移する
    visit root_path
    # ｢お問い合わせ｣ボタンを押すとお問い合わせページに遷移することを確認する
    scroll_to(find('.footer-upper'), align: :center)
    expect(page).to have_selector('#underline-text', text: "お問い合わせ")
    find('#underline-text', text: "お問い合わせ").click
    expect(page).to have_current_path(new_contact_path)
    expect(page).to have_content("お問い合わせフォーム")
  end
end