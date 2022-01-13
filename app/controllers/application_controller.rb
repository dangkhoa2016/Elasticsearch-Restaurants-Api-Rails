class ApplicationController < ActionController::API
  include ActionController::MimeResponds

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, :with => :render_error
    # rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found   
    rescue_from ActionController::RoutingError, :with => :render_not_found
  end

  # #called by last route matching unmatched routes.  Raises RoutingError which will be rescued from in the same way as other exceptions.

  # #render 500 error 
  def render_error(err = nil)
    puts err
    respond_to do |format|
      # format.html { render plain: File.read(Rails.root.join('public', '500.html')), layout: false, :status => 500 }
      format.json { render :json => { "error": "500 Internal Server Error.", msg: 'Please go home' }, :status => 500 }
      format.all { render plain: File.read(Rails.root.join('public', '500.html')), layout: false, :status => 500 }
    end
  end

  # #render 404 error 
  def render_not_found(err = nil)
    puts err
    respond_to do |format|
      # format.html { render plain: File.read(Rails.root.join('public', '404.html')), layout: false, :status => 404 }
      format.json { render :json => { "error": "404 Route not found.", msg: 'Please go home' }, :status => 404 }
      format.all { render plain: File.read(Rails.root.join('public', '404.html')), layout: false, :status => 404 }
    end
  end
end
