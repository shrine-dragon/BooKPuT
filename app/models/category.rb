class Category < ActiveHash::Base
  self.data = [
    { id: 0,  name: '--',          color: 'transparent' },
    # 非表示用
    { id: 1,  name: '漫画',        color: '#ff9500' },     
    # オレンジ
    { id: 2,  name: '雑誌',        color: '#ffb6c1' },
    # ピンク
    { id: 3,  name: '小説',        color: '#00bfff' },
    # 水色
    { id: 4,  name: 'エッセイ',     color: '#ffff00' },
    # 黄色
    { id: 5,  name: 'ビジネス書',   color: '#808080' },
    # 灰色
    { id: 6,  name: '実用書',       color: '#000080' },
    # 紺色
    { id: 7,  name: '専門書',       color: '#000000' },
    # 黒色
    { id: 8,  name: '児童書', color: '#008000' },
    # 緑色
    { id: 9, name: '参考書',       color: '#ff0000' },
    # 赤色
    { id: 10, name: 'その他',       color: 'transparent' },
    # 非表示
    { id: 11, name: '回答しない',   color: 'transparent' }
    # 非表示
  ]

  include ActiveHash::Associations
  has_many :books
end