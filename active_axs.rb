
require 'win32ole'

%w(
  core
  base
  record_map
  record_set
  sql_generator
).each {|name| require File.expand_path("../active_axs/#{name}" , __FILE__)}


