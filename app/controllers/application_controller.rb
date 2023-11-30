class ApplicationController < ActionController::API
   def show_content_params
        @filtro = params[:filtro]
      end
end
