ActionController::Routing::Routes.draw do |map|
  map.resources :notes
  map.resource :user_session
  map.login "/login", :controller => :user_session, :action => :new
  map.root :controller => :home, :action => :show
end
