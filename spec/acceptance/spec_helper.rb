require 'serverspec'
require 'facter'

Dir[Pathname.new(File.dirname(__FILE__)).join('shared/**/*.rb')].each{ |f| require f }

RSpec.configure do |config|
  config.add_formatter('RspecJunitFormatter', "build/junit/#{ENV['KITCHEN_SUITE']}.xml")
  config.add_formatter('html', "build/html/#{ENV['KITCHEN_SUITE']}.html")
  set :host, ENV['KITCHEN_HOSTNAME']
  set :ssh_options,
    :user => ENV['KITCHEN_USERNAME'],
    :port => ENV['KITCHEN_PORT'],
    :auth_methods => [ 'publickey' ],
    :paranoid => false,
    :keys => ENV['KITCHEN_SSH_KEY']
  set :backend, :ssh
  set :request_pty, true
end
