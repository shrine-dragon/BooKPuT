class Category < ActiveHash::Base
  self.data = [
    { id: 0, name: '--' },
    { id: 1, name: '漫画' },
    { id: 2, name: '雑誌' },
    { id: 3, name: '小説' },
    { id: 4, name: 'ライトノベル' },
    { id: 5, name: 'エッセイ' },
    { id: 6, name: 'ビジネス書' },
    { id: 7, name: '実用書' },
    { id: 8, name: '専門書' },
    { id: 9, name: '児童書・絵本' },
    { id: 10, name: '参考書' },
    { id: 11, name: 'その他' },
    { id: 12, name: '回答しない' }
  ]
  include ActiveHash::Associations

  has_many :books
end
