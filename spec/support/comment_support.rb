module CommentSupport
  extend ActiveSupport::Concern

  included do
    let(:user1)   { FactoryBot.create(:user) }
    let(:user2)   { FactoryBot.create(:user) }
    let(:user3)   { FactoryBot.create(:user) }

    let!(:book)   { FactoryBot.create(:book, user: user1) }
    let(:comment) { FactoryBot.create(:comment, user: user2, book: book) }
  end

  def check_comment_info
    new_comment = Comment.last

    expect(page).to have_selector('.user-image.posted-comment')
    expect(page).to have_selector('.user-nickname.posted-comment')
    expect(page).to have_content(new_comment.text)
    expect(page).to have_content(new_comment.created_at.strftime('%Y/%m/%d %H:%M:%S'))
  end
end