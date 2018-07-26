module Consul
  class Application < Rails::Application
  	config.i18n.default_locale = :gl
  	config.i18n.available_locales = [:es,:gl,:en] 
  	
  end

end
