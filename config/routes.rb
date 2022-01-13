Rails.application.routes.draw do
  root "home#welcome"
  get '/doc/:id', to: 'elasticsearch#get_doc'
  post '/search', to: 'elasticsearch#search'
  
  get '/favicon.ico', to: 'home#favicon_ico'
  get '/favicon.png', to: 'home#favicon_png'
  # get "/404" => "errors#not_found"
  # get "/500" => "errors#exception"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  match '*unmatched', to: 'application#render_not_found', via: :all
end
