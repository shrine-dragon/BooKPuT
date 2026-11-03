class Category < ActiveHash::Base
  self.data = [
    # transparent == 非表示
    { id:  0,  name: '--', color: 'transparent' },
    { id:  1,  name: '漫画',      color: 'orange' },
    { id:  2,  name: '雑誌',      color: 'pink' },
    { id:  3,  name: '小説',      color: 'lightblue' },
    { id:  4,  name: 'エッセイ', color: 'yellow' },
    { id:  5,  name: 'ビジネス書', color: 'gray' },
    { id:  6,  name: '実用書',    color: 'darkblue' },
    { id:  7,  name: '専門書',    color: 'black' },
    { id:  8,  name: '児童書',    color: 'green' },
    { id:  9,  name: '参考書',    color: 'red' },
    { id: 10,  name: 'その他',    color: 'transparent' },
    { id: 11,  name: '回答しない', color: 'transparent' }
  ]

  include ActiveHash::Associations
  has_many :books
end
