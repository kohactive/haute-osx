require './vendor/bundler/setup.rb'

# Requires
require './lib/runner'
require 'coffee-script'
require 'haml'
require 'json/ext'
require 'kss'
require 'pathname'
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

  set :public_folder, "#{File.expand_path("../", __FILE__)}/public"

  
  get '/' do
    haml :index
  end

  get '/project' do
    haml :project
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
      { path: selected_path }.to_json
    end
  end

  get '/load-projects' do
    content_type :json
    File.read(projects_file)
  end

  post '/load-project' do
    content_type :json
    projects = get_projects
    id = params[:id].to_s
    projects['projects'][id].to_json
  end

  post '/create-project' do
    content_type :json

    projects = get_projects

    # increment for new project id
    new_project_id = projects['projects'].keys.last.to_i + 1

    new_project_data = {
      id: new_project_id,
      title: params[:title],
      path: params[:path]
    }
    
    projects['projects'][new_project_id.to_s] = new_project_data
    write_projects(projects)

    new_project_data.to_json
  end

  post '/save-project' do
    id = params[:id].to_s
    
    # set up project with new data
    project = get_project(id)
    project['css_relative']         = params[:css_relative]
    project['css_absolute']         = params[:css_absolute]
    project['stylesheets_relative'] = params[:stylesheets_relative]
    project['stylesheets_absolute'] = params[:stylesheets_absolute]
    project['variables_relative']   = params[:variables_relative]
    project['variables_absolute']   = params[:variables_absolute]
    project['output_relative']      = params[:output_relative]
    project['output_absolute']      = params[:output_absolute]

    projects = get_projects
    
    # overwrite project with new data
    projects['projects'][id] = project
    write_projects(projects)
    true
  end

  post '/build' do
    id = params[:id].to_s
    project = get_project(id)

    @block_title    = project['block_title']
    @block_content  = project['block_content']

    @styleguide = Kss::Parser.new(params[:stylesheet_path])
    styleguide_index = "#{params[:output_path]}/index.html"
    File.open( styleguide_index, 'w+' ) do |f|
      f.write(haml :styleguide)

      # copy and rename the compiled css file
      # into the output directory
      FileUtils.cp project['css_absolute'], "#{params[:output_path]}/project.css"
      
      # potential problem in desktop app:
      # does it open in a new window?
      %x[osascript -e 'open location "file://#{styleguide_index}"']
    end
    "build complete!"
  end

  post '/save-block' do
    id = params[:id].to_s
    project = get_project(id)

    project['block_title']    = params[:block_title]
    project['block_content']  = params[:block_content]

    projects = get_projects
    projects['projects'][id] = project
    write_projects(projects)
    true
  end

  post '/load-blocks' do
    content_type :json
    id = params[:id].to_s
    project = get_project(id)
    {
      block_title: project['block_title'],
      block_content: project['block_content']
    }.to_json
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

  private

  def projects_file
    "#{File.expand_path("../", __FILE__)}/public/js/projects.json"
  end

  def get_projects
    # get all projects and convert to hash
    JSON.parse( File.read(projects_file) )
  end

  def get_project(id)
    get_projects['projects'][id.to_s]
  end

  def write_projects(projects)
    # takes `projects` as a hash
    # overwrites projects json
    File.open( projects_file, 'w+' ) do |f|
      f.write(projects.to_json)
    end
  end

end

CocoaRackRunner.run do 
  Rack::Handler::WEBrick.run App, :Port => PORT
end
