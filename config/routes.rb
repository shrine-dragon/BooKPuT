Rails.application.routes.draw do
  # deviseを用いたユーザー管理機能
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    passwords: 'users/passwords'
  }

  devise_scope :user do
    # SNS認証が失敗した場合の遷移先
    get '/users/auth/failure', to: 'users/omniauth_callbacks#failure'
    # パスワード再設定用URLが添付されたメールが送信された際の遷移先
    get 'passwords/email_submitted', to: 'users/passwords#email_submitted', as: :email_submitted
    # パスワードの変更が完了した際の遷移先
    get 'passwords/update_completion', to: 'users/passwords#update_completion', as: :update_completion
  end

  root to: "books#index"

  get 'privacy_policy', to: 'static_pages#privacy_policy'
  
  resources :users, only: [:show, :update, :destroy] do
    member do
      get 'edit_profile'
      get 'edit_email'
      get 'edit_password'
      # 更新処理は標準の update アクションを使い回すか、別途 patch を定義する
    end
  end
end
