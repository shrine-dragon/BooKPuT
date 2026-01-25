Rails.application.routes.draw do
  get 'static_pages/privacy_policy'
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }
  root to: "books#index"
  # SNS認証が失敗した場合の遷移先
  get 'users/auth/failure', to: redirect('/')
  get 'privacy_policy', to: 'static_pages#privacy_policy'
end
