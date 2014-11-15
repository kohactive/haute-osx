require "./vendor/bundle/bundler/setup"

# Requires
require './lib/runner'
require 'coffee-script'
require 'haml'
require 'json/ext'
require 'kss'
require 'haute'
require 'pathname'
require 'sass'
require 'sinatra'
require 'sinatra/base'
require 'sinatra-index'
require 'sinatra/asset_pipeline'
require 'sinatra/reloader' if development?
require './db'

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

  set :public_folder, "#{File.expand_path("../", __FILE__)}/public"

  
  get '/' do
    haml :index
  end

  get '/project' do
    haml :project
  end

  get '/template' do
    haml :template
  end

  get '/blocks' do
    haml :blocks
  end

  get '/containers' do
    haml :containers
  end

  post '/browse' do
    content_type :json
    raw_path      = %x[osascript -e 'tell application "SystemUIServer" to return POSIX path of (choose file)']
    selected_path = Pathname.new raw_path.strip
    project_path  = Pathname.new params[:project_path]
    {
      absolute_path: selected_path,
      relative_path: selected_path.relative_path_from(project_path)
    }.to_json
  end

  post '/browse-for-folder' do
    content_type :json
    raw_path      = %x[osascript -e 'tell application "SystemUIServer" to return POSIX path of (choose folder)']
    selected_path = Pathname.new raw_path.strip
    
    if params[:project_path]
      project_path  = Pathname.new params[:project_path]
      relative_path = selected_path.relative_path_from(project_path)
      {
        absolute_path: selected_path,
        relative_path: relative_path
      }.to_json
    else
      selected_path.to_json
    end
  end

  # create project
  post '/projects' do
    content_type :json
    default_page_template = File.read("#{File.expand_path("../", __FILE__)}/views/styleguide.haml")
    project = Project.create(title: params[:title], path: params[:path], page_template: default_page_template)
    project.to_json
  end

  # read all projects
  get '/projects' do
    content_type :json
    Project.all.to_json
  end

  # read project
  get '/projects/:id' do
    content_type :json
    Project.find(params[:id]).to_json
  end

  # update project
  post '/projects/:id' do
    content_type :json

    project = Project.find( params[:id] )

    project.css_relative          = params[:css_relative] if params[:css_relative]
    project.css_absolute          = params[:css_absolute] if params[:css_absolute]
    project.stylesheets_relative  = params[:stylesheets_relative] if params[:stylesheets_relative]
    project.stylesheets_absolute  = params[:stylesheets_absolute] if params[:stylesheets_absolute]
    project.variables_relative    = params[:variables_relative] if params[:variables_relative]
    project.variables_absolute    = params[:variables_absolute] if params[:variables_absolute]
    project.output_relative       = params[:output_relative] if params[:output_relative]
    project.output_absolute       = params[:output_absolute] if params[:output_absolute]
    project.page_template         = params[:page_template] if params[:page_template]

    project.save()
    project.to_json
  end

  # delete project
  delete '/projects/:id' do
    content_type :json
    project = Project.find( params[:id] )
    project.destroy
    "project deleted".to_json
  end

  # create new block
  get '/projects/:id/blocks' do
    content_type :json
    project = Project.find(params[:id])
    block = project.blocks.create()
    block.to_json  
  end

  # read a project's blocks
  get '/blocks/:id' do
    content_type :json
    blocks = Project.find(params[:id]).blocks
    blocks.to_json
  end

  # update block
  post '/blocks/:id' do
    content_type :json

    block = Block.update( params[:id], {
      block_title:    params[:block_title],
      block_content:  params[:block_content]
    } )

    block.to_json
  end

  # delete block
  delete '/blocks/:id' do
    content_type :json
    block = Block.find( params[:id] )
    block.destroy
    "block deleted".to_json
  end

  post '/build' do
    project = Project.find(params[:id])

    @blocks     = project.blocks
    @colors     = Haute::Generator.generate( Haute::Parser.parse_file(project.variables_absolute) )
    @typography = haml :_typography_block

    @styleguide = Kss::Parser.new( project.stylesheets_absolute )
    styleguide_index = "#{project.output_absolute}/index.html"
    File.open( styleguide_index, 'w+' ) do |f|
      f.write(haml project.page_template)

      # copy and rename the compiled css file
      # into the output directory
      FileUtils.cp project.css_absolute, "#{project.output_absolute}/project.css"

      # copy over other necessary assets
      public_folder = "#{File.expand_path("../", __FILE__)}/public"
      FileUtils.cp "#{public_folder}/css/kss.css", "#{project.output_absolute}/kss.css"
      FileUtils.cp "#{public_folder}/js/jquery.js", "#{project.output_absolute}/jquery.js"
      FileUtils.cp "#{public_folder}/js/kss.js", "#{project.output_absolute}/kss.js"
      
      # potential problem in desktop app:
      # does it open in a new window?
      # %x[osascript -e 'open location "file://#{styleguide_index}"']
    end
    "build complete!"
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

  helpers do
    # Generates a styleguide block. A little bit evil with @_out_buf, but
    # if you're using something like Rails, you can write a much cleaner helper
    # very easily.
    def styleguide_block(section, string)
      @section = @styleguide.section(section)
      @example_html = string
      # @escaped_html = ERB::Util.html_escape @example_html
      # @_out_buf << erb(:_styleguide_block)
      haml :_styleguide_block
    end

    # Captures the result of a block within an erb template without spitting it
    # to the output buffer.
    def capture(&block)
      out, @_out_buf = @_out_buf, ""
      yield
      @_out_buf
    ensure
      @_out_buf = out
    end
  end

end

CocoaRackRunner.run do 
  Rack::Handler::WEBrick.run App, :Port => PORT
end
