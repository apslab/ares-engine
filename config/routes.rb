Rails.application.routes.draw do
  resources :tasaivas

  resources :condicionivas

  match '/contact', :to => 'pages#contact'
  match '/about',   :to => 'pages#about'
  match '/help',    :to => 'pages#help'
  match '/'    ,    :to => 'pages#home'
  match '/config', :to => 'pages#config'
  
  get "pages/home"

  get "pages/contact"

  get "pages/about"

  get "pages/help"
  
  get "pages/config"

  resources :clientes do 
    resources :facturas
    resources :recibos
    resources :notacreditos

    resources :facturarecibos
    resources :facturanotacreditos
    member do
      get 'list_accounts', :action => :list_accounts

      get 'cuentacorriente', :action => :cuentacorriente 
    end
  end  
    
  resources :facturas do
    resources :facturadetalles, :only => [:new, :create, :index, :destroy, :edit]
    member do
      get 'print', :action => :imprimir 
    end
    collection do
      get 'print'
    end
  end
end
