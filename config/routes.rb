Rails.application.routes.draw do

  get 'sessions/new'

  root 'main_pages#home'

  get 'about' => 'main_pages#about'

  get 'help' => 'main_pages#help'

  get 'contact' => 'main_pages#contact'

  # Users
  get 'signup' => 'users#new'

  get 'users' => 'users#index'

  get 'users/new' => 'users#new', as: :new_user
  post 'users/' => 'users#create'

  get 'users/:id' => 'users#show', as: :user

  get 'users/edit/:id' => 'users#edit', as: :edit_user
  patch 'users/:id' => 'users#update'


  # Sessions
  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'

  delete 'logout' => 'sessions#destroy'


end
