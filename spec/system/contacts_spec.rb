require 'rails_helper'

RSpec.describe 'お問い合わせ機能', type: :system do
  let(:contact) { FactoryBot.create(:contact) }

  describe 'お問い合わせ内容の送信' do
    context 'お問い合わせ内容を送信できる時' do
      it '正しい情報を入力すればお問い合わせ内容を送信でき、送信完了ページに遷移する' do
        visit_new_contact_path

        # 必須項目と任意項目をそれぞれ入力する
        fill_in 'name',    with: contact.name
        fill_in 'email',   with: contact.email
        fill_in 'subject', with: contact.subject
        fill_in 'message', with: contact.message

        # ｢送信｣ボタンを押すとContactモデルのカウントが1上がることを確認する
        expect(page).to have_selector('.orange-submit-btn')
        scroll_to(find('.orange-submit-btn'), align: :center)
        sleep 0.5

        expect do
          find('.orange-submit-btn').click
          sleep 0.5
        end.to change { Contact.count }.by(1)

        # 送信完了ページに遷移することを確認する
        expect(page).to have_current_path(submit_completion_contacts_path)

        expect(page).to have_content('送信完了')
        expect(page).to have_content('お問い合わせ内容を送信しました。')
      end
    end

    context 'お問い合わせ内容を送信できない時' do
      it '必須事項を空欄にするとエラーメッセージが表示され、送信できない' do
        visit_new_contact_path

        # 必須項目を空欄のままにする
        fill_in 'name',    with: ''
        fill_in 'email',   with: ''
        fill_in 'message', with: ''

        # ｢送信｣ボタンを押してもContactモデルのカウントは変化しないことを確認する
        expect(page).to have_selector('.orange-submit-btn')
        scroll_to(find('.orange-submit-btn'), align: :center)
        sleep 0.5

        expect do
          find('.orange-submit-btn').click
          sleep 0.5
        end.not_to change(Contact, :count)

        error_messages = %w[
          氏名を入力してください
          メールアドレスを入力してください
          メールアドレスは不正な形式です
          メッセージ本文を入力してください
        ]

        # お問い合わせページで各入力項目にエラーメッセージが表示されていることを確認する
        expect(page).to have_current_path(contacts_path)

        error_messages.each do |message|
          expect(page).to have_content(message)
        end
      end
    end
  end
end
