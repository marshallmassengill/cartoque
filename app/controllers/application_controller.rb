class ApplicationController < ActionController::Base
  before_filter :authenticate!

  protect_from_forgery

  helper_method :current_user, :logged_in?

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render_404 exception
  end

  def render_404(exception = nil)
    logger.info "Rendering 404 with exception: #{exception.message}" if exception
    respond_to do |format|
      format.html { render :text => %(<div class="center not_found">These are not the droids you're looking for</div>),
                           :status => :not_found, :layout => true }
      format.atom { head :not_found }
      format.xml { head :not_found }
      format.js { head :not_found }
      format.json { head :not_found }
    end
  end

  private
  def authenticate!
    redirect_to("/auth/required") unless logged_in? || api_request?
  end

  def current_user
    return @current_user if @current_user
    # Standard login
    if valid_session_user_id?
      @current_user = User.find(session_user_id)
    # API login
    elsif valid_api_token?
      @current_user = User.find_by_authentication_token(token)
    end
    # update User#seen_on if possible
    @current_user.try(:seen_now!)
    @current_user
  end

  def logged_in?
    current_user.present?
  end

  def api_request?
    %w(csv json xml).include?(params[:format]) && valid_api_token?
  end

  def valid_session_user_id?
    session_user_id && session_user_id.to_i > 0
  end

  def session_user_id
    session[:user_id]
  end

  def valid_api_token?
    token && token.length > 5
  end

  def token
    env["HTTP_X_CARTOCS_TOKEN"]
  end

  #for more information on pdfkit + asset pipeline:
  #http://www.mobalean.com/blog/2011/08/02/pdf-generation-and-heroku
  def request_from_pdfkit?
    request.env["Rack-Middleware-PDFKit"] == "true"
  end
  helper_method :request_from_pdfkit?
end
