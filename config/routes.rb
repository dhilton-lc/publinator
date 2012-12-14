Publinator::Engine.routes.draw do

  match "/manage" => 'manage#index'
  match "/manage/preview" => 'manage#preview'

  namespace :manage do

    Publinator::PublishableType.all.each do |pt|
      resources pt.name.tableize.to_sym, :controller => "publishable", :publishable_type => pt.name.tableize do
        member do
          post :sort
          get :preview
        end
      end
    end

    #constraints(Publinator::PublishableType) do
      #match '/:publishable_type/' => "publishable#index", :requirements => {
        #:publishable_type => /\A([a-zA-Z]+[a-zA-Z_]*)\z/i
        #}, :as => "publishables"

      #match '/:publishable_type/new' => "publishable#new", :requirements => {
        #:publishable_type => /\A([a-zA-Z]+[a-zA-Z_]*)\z/i
      #}

      #match '/:publishable_type/create' => "publishable#create", :requirements => {
        #:publishable_type => /\A([a-zA-Z]+[a-zA-Z_]*)\z/i
        #}, :as => "create_publishable"

      #match '/:publishable_type/:id/edit' => "publishable#edit", :requirements => {
          #:id => /\A\d*\z/i,
          #:publishable_type => /\A([a-zA-Z]+[a-zA-Z_]*)\z/i
      #}, :as => "edit_publishable"

      #match '/:publishable_type/:id' => "publishable#show", :requirements => {
        #:id => /\A\d*\z/i,
        #:publishable_type => /\A([a-zA-Z]+[a-zA-Z_]*)\z/i
        #}, :as => "publishable"
    #end

    resources :pages do
      collection do
        post :sort
        post :preview
      end
    end
    resources :sites
    resources :sections do
      member do
        post :sort
      end
    end
    resources :publishable_types
    resources :asset_items
  end

  #constraints(Publinator::PublishableType) do
    #match '/:publishable_type/' => "publishable#index", :requirements => {
       #:publishable_type => /\A([a-zA-Z]+[a-zA-Z_]*)\z/i
    #}

    #match '/:publishable_type/:id' => "publishable#show", :requirements => {
      #:id => /\A\d*\z/i,
      #:publishable_type => /\A([a-zA-Z]+[a-zA-Z_]*)\z/i
      #}, :as => "publishable"
  #end
  #

  Publinator::PublishableType.all.each do |pt|
    resources pt.name.tableize.to_sym, :controller => "publishable", :only => [:index, :show], :publishable_type => pt.name.tableize
  end


  constraints(Publinator::Section) do
    match '/:section/' => "section#index", :requirements => {
       :section =>  /\A([a-zA-Z0-9]+[a-zA-Z0-9\-_]*)\z/i
    }

    match '/:section/:id' => "section#show", :requirements => {
      :id => /\A\d*\z/i,
      :section =>  /\A([a-zA-Z0-9]+[a-zA-Z0-9\-_]*)\z/i
      }, :as => "publishable"
  end

  match "/:slug", :controller => :publishable, :action => :page, :requirements => {
    :slug => /\A([a-zA-Z]+[a-zA-Z\-_]*)\z/i
  }, :as => 'publishable'

  root :to  => "home#index"
  match '/' => 'home#index'

end
