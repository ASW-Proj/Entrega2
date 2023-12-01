class ApplicationController < ActionController::API
    before_action :authenticate_user, if: -> { %w[post put delete].include?(request.method.downcase) }
    attr_reader :current_user

    private
        def authenticate_user
            token = extract_token_from_request
            if token_valid?(token)
                @current_user = User.find_by(api_key: token)
            else
                render json: { error: 'Unauthorized' }, status: :unauthorized
            end
        end
    
        def extract_token_from_request
            header = request.headers['Authorization']
            header&.split(' ')&.last 
        end
    
        def token_valid?(token)
            !token.nil? && !token.empty? && User.exists?(api_key: token)
        end
end
