module Consul
  class Application < Rails::Application
  	config.i18n.default_locale = 'gl-ES'
  	config.i18n.available_locales = ['gl-ES', :es, :en] 
  	require Rails.root.join('lib/custom/census_api')
  end

end
