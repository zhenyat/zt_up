################################################################################
#   zt_up.rb
#     Main Module of the Gem
#
#   07.11.2015   ZT
################################################################################
require 'zt_up/version'
require 'active_support/concern'
require 'fileutils'
require 'active_support/dependencies/autoload'
require 'zt_up/pictures_processing'
require 'zt_up/railtie' if defined?(Rails)

module ZtUp
  # Your code goes here...
end
