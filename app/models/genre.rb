class Genre < ActiveHash::Base
  self.data = [
    # 漫画 (category_id: 1) のジャンル
    { id:  1, category_id: 1, name: '少年漫画' },
    { id:  2, category_id: 1, name: '少女漫画' },
    { id:  3, category_id: 1, name: '青年漫画' },
    { id:  4, category_id: 1, name: 'バトル' },
    { id:  5, category_id: 1, name: 'アクション' },
    { id:  6, category_id: 1, name: 'ファンタジー' },
    { id:  7, category_id: 1, name: '恋愛' },
    { id:  8, category_id: 1, name: 'ミステリー' },
    { id:  9, category_id: 1, name: 'サスペンス' },
    { id: 10, category_id: 1, name: 'SF' },
    { id: 11, category_id: 1, name: 'ホーム' },
    { id: 12, category_id: 1, name: '学園' },
    { id: 13, category_id: 1, name: 'グルメ' },
    { id: 14, category_id: 1, name: 'ホラー' },
    { id: 15, category_id: 1, name: 'オーバーキル' },
    { id: 16, category_id: 1, name: 'デスゲーム' },
    { id: 17, category_id: 1, name: '異世界転生' },
    { id: 18, category_id: 1, name: 'スローライフ' },
    { id: 19, category_id: 1, name: '日常' },
    { id: 20, category_id: 1, name: 'スポーツ' },

    # 雑誌 (category_id: 2) のジャンル
    { id: 21, category_id: 2, name: '漫画' },
    { id: 22, category_id: 2, name: 'アニメ' },
    { id: 23, category_id: 2, name: 'ファッション' },
    { id: 24, category_id: 2, name: '料理・グルメ' },
    { id: 25, category_id: 2, name: '健康' },
    { id: 26, category_id: 2, name: 'ビジネス' },
    { id: 27, category_id: 2, name: 'スポーツ' },
    { id: 28, category_id: 2, name: 'アウトドア' },
    { id: 29, category_id: 2, name: '美容・コスメ' },
    { id: 30, category_id: 2, name: '文芸' },
    { id: 31, category_id: 2, name: 'アート' },
    { id: 32, category_id: 2, name: '総合週刊誌' },

    # 小説 (category_id: 3) のジャンル
    { id: 33, category_id: 3, name: 'アクション' },
    { id: 34, category_id: 3, name: 'ミステリー' },
    { id: 35, category_id: 3, name: 'サスペンス' },
    { id: 36, category_id: 3, name: 'ファンタジー' },
    { id: 37, category_id: 3, name: 'SF' },
    { id: 38, category_id: 3, name: 'ホラー' },
    { id: 39, category_id: 3, name: '恋愛' },
    { id: 40, category_id: 3, name: '学園' },
    { id: 41, category_id: 3, name: '歴史' },
    { id: 42, category_id: 3, name: '政治・経済' },
    { id: 43, category_id: 3, name: 'ヒューマンドラマ' },
    { id: 44, category_id: 3, name: 'ライトノベル' },
    { id: 45, category_id: 3, name: '古典文学' },
    { id: 46, category_id: 3, name: '近代文学' },
    { id: 47, category_id: 3, name: '純文学' },

    # エッセイ (category_id: 4) のジャンル
    { id: 48, category_id: 4, name: '日常・生活' },
    { id: 49, category_id: 4, name: 'コラム' },
    { id: 50, category_id: 4, name: 'コミック' },
    { id: 51, category_id: 4, name: '旅・紀行' },
    { id: 52, category_id: 4, name: 'グルメ' },
    { id: 53, category_id: 4, name: '教養' },
    { id: 54, category_id: 4, name: '哲学' },
    { id: 55, category_id: 4, name: '自伝・回想録' },

    # ビジネス書 (category_id: 5) のジャンル
    { id: 56, category_id: 5, name: '自己啓発' },
    { id: 57, category_id: 5, name: 'ビジネススキル' },
    { id: 58, category_id: 5, name: 'マーケティング' },
    { id: 59, category_id: 5, name: '経営・戦略' },
    { id: 60, category_id: 5, name: '経済・金融・社会' },
    { id: 61, category_id: 5, name: '教養' },
    { id: 62, category_id: 5, name: '起業・イノベーション' },
    { id: 63, category_id: 5, name: 'マネー・資産運用' },

     # 実用書 (category_id: 6) のジャンル
    { id: 64, category_id: 6, name: '生活(健康・美容・医療・ファッション・冠婚葬祭)' },
    { id: 65, category_id: 6, name: '趣味(インドア・アウトドア・料理・インテリア・スポーツ・筋トレ・占い・ゲーム・旅行)' },
    { id: 66, category_id: 6, name: '女性(恋愛・結婚・出産・家事・育児・教育)' },
    { id: 67, category_id: 6, name: '自己啓発' },
    { id: 68, category_id: 6, name: '語学・資格' },

    # 専門書 (category_id: 7) のジャンル
    { id: 69, category_id: 7, name: '人文書(哲学・心理学・宗教)' },
    { id: 70, category_id: 7, name: '社会書(法律・経営・経済・政治)' },
    { id: 71, category_id: 7, name: '理工書(数学・科学・化学・物理・生物・地学' },
    { id: 72, category_id: 7, name: '医学書(医師・看護師)' },
    { id: 73, category_id: 7, name: '歴史書(日本史・世界史)' },
    { id: 74, category_id: 7, name: '美術書(美術・デザイン・音楽・映像・建築)' },
    { id: 75, category_id: 7, name: 'IT' },

    # 児童書 (category_id: 8) のジャンル
    { id: 76, category_id: 8, name: '絵本' },
    { id: 77, category_id: 8, name: '童話' },
    { id: 78, category_id: 8, name: 'ファンタジー' },
    { id: 79, category_id: 8, name: 'SF' },
    { id: 80, category_id: 8, name: 'ヤングアダルト' },
    { id: 81, category_id: 8, name: 'ノンフィクション' },
    { id: 82, category_id: 8, name: '伝記' },

    # 参考書 (category_id: 9) のジャンル
    { id: 83, category_id: 9, name: '小学生向け' },
    { id: 84, category_id: 9, name: '中学生向け' },
    { id: 85, category_id: 9, name: '高校生向け' },
    { id: 86, category_id: 9, name: '大学生向け' },
    { id: 87, category_id: 9, name: '語学' },
    { id: 88, category_id: 9, name: '資格' },
    { id: 89, category_id: 9, name: '問題集' },

    # 共通項目
    { id: 900, category_id: 999, name: 'その他' },
    { id: 901, category_id: 999, name: '回答しない' }
  ]

  include ActiveHash::Associations
  belongs_to :category
end