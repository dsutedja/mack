orm = app_config.orm || 'data_mapper'
unless orm.nil? 
  Mack.logger.info "Initializing #{orm} orm..."
  begin
    require "mack-#{orm}"
	  require "mack-#{orm}_tasks"
  rescue Exception => e
    Mack.logger.warn "There was an error configuring #{orm}"
  end
end