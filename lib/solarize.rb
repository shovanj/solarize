# make sure we're running inside Merb
if defined?(Merb::Plugins)

  # Merb gives you a Merb::Plugins.config hash...feel free to put your stuff in your piece of it
  Merb::Plugins.config[:solarize] = {
    :chickens => false
  }

  Merb::BootLoader.before_app_loads do
    # require code that must be loaded before the application
    # require solr-ruby gem
    require 'solr'
    require "solarize/solarize" if Merb.env == "production"
  end

  Merb::BootLoader.after_app_loads do
    # code that can be required after the application loads
  end

  Merb::Plugins.add_rakefiles "solarize/merbtasks"
end

module Solarize
end

require File.dirname(__FILE__) + '/solarize/solarize'
require File.dirname(__FILE__) + '/solarize/class_methods'
require File.dirname(__FILE__) + '/solarize/instance_methods'
require File.dirname(__FILE__) + '/solarize/common_methods'

