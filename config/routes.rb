# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
resources :projects do
  resource :bulk, only: [:new, :create, ]
end

post 'bulk_task/project_settings', to: 'project_settings#save'