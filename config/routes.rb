Rails.application.routes.default_url_options[:host] = 'gpcollect.duckdns.org'

Rails.application.routes.draw do
  scope '/:locale' do
    get 'static_pages/about'

    devise_for :admins
    resources :merge_runners_requests do
      member do
        get 'approve'
      end
    end
    resources :categories, only: %i[index show]
    resources :participants, only: :index
    resources :routes, only: :show
    resources :runs, only: %i[index show] # not actually in use.
    resources :feedbacks
    resources :geocode_results, only: %i[index show destroy]
    resources :runners, only: %i[index show] do
      collection do
        get 'show_remembered'
      end
    end
  end

  root 'runners#index'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
