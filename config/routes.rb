Pickmeup::Application.routes.draw do
  match '/organizers/:organizer_id/events/new', to: 'events#new'
  resources :organizers do
    member do
      match "import_event_brite" => "organizers#import_event_brite", as: "import_events"
    end

    resources :events
  end
  resources :org_sessions

  get "sessions/create"
  get "sessions/destroy"

  # authentication for event organizer
  get 'org_signup', to: 'organizers#new', as: 'org_signup'
  get 'org_login', to: 'org_sessions#new', as: 'org_login'
  get 'org_logout', to: 'org_sessions#destroy', as: 'org_logout'

  get 'events/genre/:id', to: 'events#genre', as: 'events_genre'

  # this is to show the list of all existing pmus for this user
  get '/pmus', to: 'pmus#index', as: 'pmus'

  #For searching functionality
  post '/events/:id', to: 'events#show'

  #For ticket validation
  post '/events/:id/confirm', to: 'events#confirm'

  #help page
  get '/help', to: 'events#help'

  #pmu introduction
  get '/pmu_intro', to: 'events#pmu_introduction'

  #team introduction
  get '/team_intro', to: 'events#team_introduction'

  resources :events do
    resources :pmus do
      member do
        match "add_user/:user_id" => "pmus#add_user", as: "add_user"
        match "add_requesting_user" => "pmus#add_requesting_user", as: "add_requesting_user"
        match "create_new_cab_trip/:user_id" => "pmus#create_new_cab_trip", :as => 'create_new_cab_trip'
        delete "remove_user/:user_id" => "pmus#remove_user", :as => "remove_user"
        delete "remove_requesting_user/:user_id" => "pmus#remove_requesting_user", as: "remove_requesting_user"
      end
    end
  end

  resources :users

  # managing authentication
  match 'auth/:provider/callback', to: 'sessions#create'
  match 'auth/failure', to: redirect('/')
  match '/signout', to: 'sessions#destroy', as: 'signout'

  # POST request for pmu confirmation
  match 'pmu/confirmation', as: 'pmu_confirmation', to: 'pmus#confirm'

  #root to: 'sessions#new'
  root to: 'events#index'
end
