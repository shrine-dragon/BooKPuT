class User < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [:twitter, :facebook, :google_oauth2, :line]
  has_one_attached :image
  belongs_to_active_hash :gender
  has_many :sns_credentials, dependent: :destroy # ユーザーが消えるときにSNS情報も自動で削除される

  def self.from_omniauth(auth)
    Rails.logger.debug "===== AUTH DATA ====="
    Rails.logger.debug auth.info
    
    # LINEの場合、auth.info.email が空なら自動入力されません
    user = User.where(email: auth.info.email).first_or_initialize if auth.info.email
    puts "===== LINE AUTH DATA ====="
    p auth.info
    # 1. SNS情報を元にSNS認証テーブルからデータを探す、なければ作る
    sns = SnsCredential.where(provider: auth.provider, uid: auth.uid).first_or_initialize

    # 2. SNS情報のメールアドレスを元に、既にUserが存在するか確認する
    # （もし過去にメールアドレスだけで登録していた場合、そのユーザーとSNSを紐付けるため）
    user = User.where(email: auth.info.email).first_or_initialize(
      nickname: auth.info.name,
      email: auth.info.email
    )

    # 3. もし新規ユーザー（まだ保存されていない）なら、ランダムなパスワードを設定する
    if user.persisted? == false
      # SNS経由の場合はパスワードを手動で入れさせないため、自動生成する
      password = Devise.friendly_token[0, 20] # 20桁のランダムな文字列
      user.password = password
      user.password_confirmation = password
    end

    # 4. Userが既にDBに保存されている（登録済み）場合、SNS情報と紐付ける
    # persisted? = already_save
    if user.persisted?
      sns.user = user
      sns.save
    end

    # コントローラーに { user: user, sns: sns } の形で返す
    { user: user, sns: sns } 
  end

  with_options presence: true do
    validates :nickname, length: { minimum: 3, maximum: 16 }
    validates :birth_date
    validates :password, length: { minimum: 8, maximum: 20 },
                         format: { 
                           with: /\A(?=.*?[a-z])(?=.*?[A-Z])(?=.*?\d)[a-zA-Z\d]+\z/, 
                           message: 'は英字の大文字・小文字・数字をすべて含めて入力してください' 
                         },unless: -> { password.blank? && (sns_auth_process || sns_credentials.any? || session_sns_auth_exists?) },
                         allow_blank: true
  end
  validates :password_confirmation, presence: true, unless: -> { password.blank? && sns_auth_process? }

  attr_accessor :sns_auth_process

  def sns_auth_process?
    self.sns_auth_process || self.password.blank? && self.sns_credentials.present?
  end

  # ヘルパーメソッドを追加（もし必要なら）
  def session_sns_auth_exists?
    # ここはモデルなので session を直接触れませんが、
    # sns_auth_process をコントローラーから確実に渡すようにします
    self.sns_auth_process == true
  end
  
  validates :email, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, message: 'は不正な形式です' }, allow_blank: true
  validates :gender_id, numericality: { other_than: 0, message: 'を選択してください' }, unless: :sns_auth_process?

  validate :birth_date_cannot_be_in_the_future

  private

  def birth_date_cannot_be_in_the_future
    # birth_dateが存在し、かつ今日より後の日付であればエラーを追加
    if birth_date.present? && birth_date > Date.today
      errors.add(:birth_date, "は今日以前の日付を選択してください")
    end
  end
end
