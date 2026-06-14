require "sidekiq/web"

Rails.application.routes.draw do
  # Sidekiq Web UI (admin only in production)
  authenticate :user, ->(user) { user.team_memberships.exists?(role: "owner") } do
    mount Sidekiq::Web => "/sidekiq"
  end

  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    invitations: "users/invitations"
  }

  namespace :api do
    namespace :v1 do
      resources :teams, only: [:show, :update] do
        member do
          post :invite_member
        end
        resources :members, only: [:index, :update, :destroy], controller: "team_members"
      end

      resources :jobs do
        member do
          post :publish
          post :close
          post :archive
          post :restore
        end
        resources :stages, only: [:index, :create, :update, :destroy] do
          collection do
            patch :reorder
          end
        end
        resources :candidates do
          member do
            patch :move_stage
          end
          collection do
            patch :batch_move
          end
          resources :notes, only: [:index, :create, :update, :destroy]
          resources :attachments, only: [:index, :create, :destroy]
        end
      end

      resources :activity_logs, only: [:index]
    end
  end

  root "pages#home"
  get "health", to: "health#show"
end
