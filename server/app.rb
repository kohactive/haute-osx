require './vendor/bundler/setup.rb'

# Requires
require './lib/runner'
require 'haml'
require 'coffee-script'
require 'sass'
require "sinatra"
require "sinatra/base"
require 'sinatra-index'
require 'sinatra/asset_pipeline'
require "sinatra/reloader" if development?

# Globals
ORG_STRING       = "com.foo.rack-cocoa.org"
PORT             = ENV['PORT'] || 9999

class App < Sinatra::Base
  register Sinatra::Reloader
  register Sinatra::Index

  
  set :port, PORT
  set :assets_prefix, %w(assets vendor/assets)
  set :assets_precompile, %w(app.js app.css *.png *.jpg *.svg *.eot *.ttf *.woff)
  set :assets_css_compressor, :sass

  register Sinatra::AssetPipeline

  puts "#{File.expand_path("../", __FILE__)}/public"
  set :public_folder, "#{File.expand_path("../", __FILE__)}/public"

  
  get '/' do
    haml :index
  end



  post '/browse' do
    content_type :json
    raw_path  = %x[osascript -e 'tell application "SystemUIServer" to return POSIX path of (choose file)']
    puts "Selected: #{raw_path}"
    {path: raw_path}.to_json
  end

  get '/version' do
    CocoaRackRunner.running_version.to_s
  end

  post '/kill' do
    exit!
  end

  post '/ping' do
    "pong"
  end


end

CocoaRackRunner.run do 
  Rack::Handler::WEBrick.run App, :Port => PORT
end


