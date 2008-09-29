require 'fileutils'

plugin_root = File.dirname(__FILE__)

FileUtils.cp File.join(plugin_root, 'config', 'starling.yml'), File.join(RAILS_ROOT, 'config')
FileUtils.cp File.join(plugin_root, 'script', 'workling_starling_client'), File.join(RAILS_ROOT, 'script')
FileUtils.cp File.join(plugin_root, 'script', 'bj_invoker.rb'), File.join(RAILS_ROOT, 'script')
FileUtils.chmod 0755, File.join(RAILS_ROOT, 'script', 'workling_starling_client')

puts "\n\ninstalled starling.yml, workling_starling_client.rb. and bj_invoker.rb. \n\n"
puts IO.read(File.join(File.dirname(__FILE__), 'README'))