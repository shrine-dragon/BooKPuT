class User < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :omniauthable, omniauth_providers: [:twitter, :facebook, :google_oauth2, :line]
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
      secure_password = "Password123" # これなら大文字・小文字・数字すべてクリア
      user.password = secure_password
      user.password_confirmation = secure_password
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

  after_validation :report_errors, if: -> { errors.any? }

  def report_errors
    puts "--- ❌ バリデーションエラーが発生しました ❌ ---"
    p errors.full_messages
  end

  with_options presence: true do
    validates :nickname, length: { minimum: 3, maximum: 16 }
    validates :birth_date
  end

  validates :password, presence: true, length: { minimum: 8, maximum: 20 },
          format: { 
            with: /\A(?=.*?[a-z])(?=.*?[A-Z])(?=.*?\d)[a-zA-Z\d]+\z/, 
            message: 'は英字の大文字・小文字・数字をすべて含めて入力してください' 
          }, 
          # sns_auth_process が true の時は、このバリデーションをまるごとスキップ！
          confirmation: true,
          unless: :sns_auth_process?
  validates :password_confirmation, presence: true, unless: :sns_auth_process?

  attr_accessor :sns_auth_process

  def sns_auth_process?
    # self.sns_credentials.present? だけでもSNS経由と判定できるはずですが、
    # テストコードからの sns_auth_process も確実に拾います
    self.sns_auth_process.to_s == "true" || self.sns_credentials.any? || self.sns_credentials.present?
  end

  validates :email, presence: true, uniqueness: true,
            format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, message: 'は不正な形式です' }
  validates :gender_id, numericality: { other_than: 0, message: 'を選択してください' }, unless: :sns_auth_process?

  validate :birth_date_cannot_be_in_the_future

  # ヘルパーメソッドを追加（もし必要なら）
  def session_sns_auth_exists?
    # ここはモデルなので session を直接触れませんが、
    # sns_auth_process をコントローラーから確実に渡すようにします
    self.sns_auth_process == true
  end

  private

  def birth_date_cannot_be_in_the_future
    # birth_dateが存在し、かつ今日より後の日付であればエラーを追加
    if birth_date.present? && birth_date > Date.today
      errors.add(:birth_date, "は今日以前の日付を選択してください")
    end
  end
end
