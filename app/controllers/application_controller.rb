class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper

  # CSRF脆弱性の対策のために、サインアウトさせる
  def handle_unverified_request
    sign_out
    super
  end

end
