# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action do
    # If logged in, show rack profiler stats.
    Rack::MiniProfiler.authorize_request if admin_signed_in?
  end
  before_action :set_locale

  def set_locale
    params[:locale] ||= extract_locale_from_accept_language_header
    I18n.locale = params[:locale]
  end

  def default_url_options
    h = { locale: I18n.locale }
    h[:host] = 'gpcollect.duckdns.org' if Rails.env.production?
    h
  end

  private

  def extract_locale_from_accept_language_header
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
  rescue StandardError
    I18n.default_locale
  end
end
