class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action do
    # If logged in, show rack profiler stats.
    if admin_signed_in?
      Rack::MiniProfiler.authorize_request
    end
  end
  before_action :set_locale

  def set_locale
    params[:locale] ||= extract_locale_from_accept_language_header
    I18n.locale = params[:locale]
  end

  def default_url_options
    {locale: I18n.locale}
  end

  private
  def extract_locale_from_accept_language_header
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first rescue I18n.default_locale
  end
end
