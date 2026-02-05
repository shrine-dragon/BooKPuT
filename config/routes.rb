Rails.application.routes.draw do
  get 'static_pages/privacy_policy'
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

  end
  # get 'users/auth/failure', to: redirect('/')
  root to: "books#index"
  get 'privacy_policy', to: 'static_pages#privacy_policy'
end
