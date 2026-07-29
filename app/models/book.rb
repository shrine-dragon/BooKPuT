class Book < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions

  belongs_to :user

  validates :title, presence: true, length: { maximum: 100 }

  has_one_attached :image
  # attr_accessor：外部から変数を参照したり、変更したりできるようになる
  attr_accessor :remote_image_url
  attr_accessor :delete_image

  belongs_to :category
  validates  :category_id, presence: true, numericality: { other_than: 0, message: 'を選択してください' }

  attribute :genre_ids, :json, default: []
  validates :genre_ids, presence: { message: 'を選択してください' }, unless: :skip_genre_validation?
  validate  :genre_selection_limit, unless: :skip_genre_validation?

  def genres
    Genre.where(id: genre_ids)
  end

  has_many :book_contents, dependent: :destroy
  validate :validate_book_contents_count
  before_validation :compact_book_contents
  accepts_nested_attributes_for :book_contents, allow_destroy: true

  has_many :reported_books, dependent: :destroy
  has_many :book_goods,     dependent: :destroy
  has_many :book_bads,      dependent: :destroy
  has_many :favorites,      dependent: :destroy
  has_many :comments,       dependent: :destroy

  def self.search(keyword)
    if keyword.present?
      # キーワードに一致する「ジャンルのID」を先に取得する
      matched_genre_ids = Genre.all.select { |g| g.name.include?(keyword) }.map(&:id)
      # キーワードに一致する「カテゴリーのID」を先に取得する（ActiveHash対策）
      matched_category_ids = Category.all.select { |c| c.name.include?(keyword) }.map(&:id)

      # メインの検索クエリを組み立てる
      query = where(
        'books.title LIKE :kw OR ' \
        'book_contents.content LIKE :kw OR ' \
        'users.nickname LIKE :kw',
        kw: "%#{keyword}%"
      )

      # ジャンルIDやカテゴリーIDに一致するものがあれば OR 条件で追加する
      if matched_genre_ids.present?
        # JSON形式の配列内に、一致したジャンルIDが1つでも含まれているかを判定
        # ※ SQLiteやMySQL/PostgreSQLなど環境に合わせて柔軟に引っかかるようにする
        matched_genre_ids.each do |genre_id|
          # jsonのカラム内に文字列や数値として含まれているか部分一致で追記
          query = query.or(where('books.genre_ids LIKE ?', "%#{genre_id}%"))
        end
      end

      if matched_category_ids.present?
        query = query.or(where(category_id: matched_category_ids))
      end

      query
    else
      all
    end
  end

  private

  def genre_selection_limit
    # ジャンルが空の場合
    if genre_ids.blank? || genre_ids.all?(&:blank?)
      errors.add(:genre_ids, 'を選択してください')
    # 3つより多い場合
    elsif genre_ids.reject(&:blank?).length > 3
      errors.add(:genre_ids, 'は3つまで選択してください')
    end
  end

  def skip_genre_validation?
    [10, 11].include?(category_id)
  end

  def validate_book_contents_count
    # 空白ではなく、かつ削除対象（_destroy=1）になっていない有効なコンテンツだけを抽出
    valid_contents = book_contents.reject { |c| c.content.blank? || c.marked_for_destruction? }

    if valid_contents.empty?
      errors.add(:book_contents, 'を少なくとも1つ入力してください')
    elsif valid_contents.length > 7
      errors.add(:book_contents, 'を7項目以内で入力してください')
    end
  end

  def compact_book_contents
    # contentが空のものを、保存対象から除外する
    book_contents.each do |content|
      content.mark_for_destruction if content.content.blank?
    end
  end
end
