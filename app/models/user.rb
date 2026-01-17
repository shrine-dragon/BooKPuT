class User < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [:twitter, :facebook, :google_oauth2]
  has_one_attached :image
  belongs_to_active_hash :gender
  has_many :sns_credentials

  def self.from_omniauth(auth)
    sns = SnsCredential.where(provider: auth.provider, uid: auth.uid).first_or_create
    # sns認証したことがあればアソシエーションで取得
    # 無ければemailでユーザー検索して取得orビルド(保存はしない)
    user = User.where(email: auth.info.email).first_or_initialize(
      nickname: auth.info.name,
        email: auth.info.email
    )
  end

  with_options presence: true do
    validates :nickname, length: { minimum: 4, maximum: 16 }
    validates :birth_date
    validates :password, length: { minimum: 8, maximum: 20 },
                         format: { with: /\A(?=.*?[a-z])(?=.*?\d)[a-z\d]+\z/i, message: 'は半角英数混合で入力してください' },
                         allow_blank: true
    validates :password_confirmation
  end
  
  validates :email, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, message: 'は不正な形式です' }, allow_blank: true
  validates :gender_id, numericality: { other_than: 0, message: 'を選択してください' }

  validate :birth_date_cannot_be_in_the_future

  private

  def birth_date_cannot_be_in_the_future
    # birth_dateが存在し、かつ今日より後の日付であればエラーを追加
    if birth_date.present? && birth_date > Date.today
      errors.add(:birth_date, "は今日以前の日付を選択してください")
    end
  end
end
