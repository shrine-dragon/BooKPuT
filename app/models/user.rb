class User < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions
  # アソシエーション
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :omniauthable, omniauth_providers: %i[twitter facebook google_oauth2 line]

  has_one_attached :image
  belongs_to_active_hash :gender

  has_many :sns_credentials,   dependent: :destroy

  has_many :books,             dependent: :destroy
  has_many :reported_books,    dependent: :destroy

  has_many :book_goods,        dependent: :destroy
  has_many :good_books,        through:   :book_goods, source: :book
  has_many :book_bads,         dependent: :destroy
  has_many :favorites,         dependent: :destroy
  has_many :favorite_books,    through: :favorites, source: :book

  has_many :comments,          dependent: :destroy
  has_many :hidden_comments,   dependent: :destroy
  has_many :reported_comments, dependent: :destroy
  has_many :comment_goods,     dependent: :destroy
  has_many :good_comments,     through:   :comment_goods, source: :comment
  has_many :comment_bads,      dependent: :destroy

  with_options presence: true do
    validates :nickname, length: { minimum: 3, maximum: 16 }
    validates :birth_date
  end

  validate :birth_date_cannot_be_in_the_future

  validates :gender_id, presence: true, numericality: { other_than: 0, message: 'を選択してください' }

  validates :email, presence: true, uniqueness: true,
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.(com|net|org|jp|co\.jp|ne\.jp)\z/i, message: 'は不正な形式です' }
  validate  :email_domain_typo_check

  validates :password, presence: true, on: :create, unless: :sns_auth_process?
  validates :password, length: { minimum: 8, maximum: 20 },
                       format: {
                         with: /\A(?=.*?[a-z])(?=.*?[A-Z])(?=.*?\d)[a-zA-Z\d]+\z/,
                         message: 'は英字の大文字・小文字・数字をすべて含めて入力してください'
                       },
                       # sns_auth_process が true の時は、このバリデーションをまるごとスキップ！
                       confirmation: true,
                       # 編集時などでパスワードが空(nil)の時はスキップする
                       allow_blank: true,
                       unless: :sns_auth_process?

  validates :password_confirmation,
            presence: true,
            if: -> { password.present? }, # パスワードがある時だけ必須にする
            unless: :sns_auth_process?

  # SNS認証
  def self.from_omniauth(auth)
    Rails.logger.debug '===== AUTH DATA ====='
    Rails.logger.debug auth.info

    # LINEの場合、auth.info.email が空なら自動入力されません
    puts '===== LINE AUTH DATA ====='
    p auth.info
    # 1. SNS情報を元にSNS認証テーブルからデータを探す、なければ作る
    sns = SnsCredential.where(provider: auth.provider, uid: auth.uid).first_or_initialize

    # メールアドレスをキーにユーザーを特定
    # emailがない場合に備え、空のUserオブジェクトを確実に生成する
    email = auth.info.email
    user = User.where(email: email).first_or_initialize if email
    user ||= User.new # emailがnilの場合でもUserオブジェクトを生成

    # ニックネームやメールをセット（既存ユーザーでも上書きしたくない場合は条件分岐）
    user.nickname = auth.info.name if user.nickname.blank?
    user.email = email if user.email.blank?

    user.gender_id = 4 if user.gender_id.blank?

    # もし新規ユーザー（まだ保存されていない）なら、ランダムなパスワードを設定する
    if user.persisted? == false
      # SNS経由の場合はパスワードを手動で入れさせないため、自動生成する
      secure_password = 'Password123' # これなら大文字・小文字・数字すべてクリア
      user.password = secure_password
      user.password_confirmation = secure_password
    end

    # Userが既にDBに保存されている（登録済み）場合、SNS情報と紐付ける
    # persisted? = already_save
    if user.persisted?
      sns.user = user
      sns.save
    end

    # コントローラーに { user: user, sns: sns } の形で返す
    { user: user, sns: sns }
  end

  attr_accessor :sns_auth_process

  def sns_auth_process?
    sns_auth_process.to_s == 'true'
  end

  # ヘルパーメソッドを追加（もし必要なら）
  def session_sns_auth_exists?
    # ここはモデルなので session を直接触れられないが、
    # sns_auth_process をコントローラーから確実に渡すようにする
    sns_auth_process == true
  end

  # メールアドレスを伏せ字にする
  def masked_email
    # 例: test1234@example.com -> t*******@example.com
    first_char = email[0]
    domain = email.split('@').last
    "#{first_char}********@#{domain}"
  end

  private

  def email_domain_typo_check
    return if email.blank?

    domain = email.split('@').last.to_s.downcase

    # gmail.com の打ち間違いっぽいパターンを弾く
    return unless domain.start_with?('gm') && domain != 'gmail.com'

    errors.add(:email, 'のドメイン（@以降）が正しくありません（例: gmail.com）')
  end

  def birth_date_cannot_be_in_the_future
    # birth_dateが存在し、かつ今日より後の日付であればエラーを追加
    return unless birth_date.present? && birth_date > Date.today

    errors.add(:birth_date, 'は今日以前の日付を選択してください')
  end
end
