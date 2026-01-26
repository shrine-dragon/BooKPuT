Rails.application.routes.draw do
  get 'static_pages/privacy_policy'
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }
  # SNS認証が失敗した場合の遷移先
  devise_scope :user do
    get '/users/auth/failure', to: 'users/omniauth_callbacks#failure'
  end
  # get 'users/auth/failure', to: redirect('/')
  root to: "books#index"
  get 'privacy_policy', to: 'static_pages#privacy_policy'
end
