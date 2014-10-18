class ApplicationController < ActionController::Base
  include Jpmobile::ViewSelector
  before_filter :disable_mobile_view_if_tablet
  protect_from_forgery

  def disable_mobile_view_if_tablet
    if request.mobile && request.mobile.tablet?
      disable_mobile_view!
    end
  end
end
