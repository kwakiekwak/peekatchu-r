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

  delete 'users/:id' => 'users#destroy'


  # Sessions
  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'

  delete 'logout' => 'sessions#destroy'

  # Challenges
  get 'challenges' => 'challenges#index'

  get 'challenges/new' => 'challenges#new', as: :new_challenge
  post 'challenges' => 'challenges#create'

  get 'challenges/:id' => 'challenges#show', as: :challenge



end
