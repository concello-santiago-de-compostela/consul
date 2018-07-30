module Consul
  class Application < Rails::Application
  	config.i18n.default_locale = :gl
  	config.i18n.available_locales = [:gl, :es, :en] 
  	require Rails.root.join('lib/custom/census_api')
  end

end
