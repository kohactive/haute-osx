require 'rubygems'
require 'test/unit'
require 'rack/test'
require 'sinatra/base'
require "./#{File.dirname(__FILE__)}/../lib/sinatra-index"

class TestIndices < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    TestApp
  end
  
  def test_serves_first_asset
    get 'foo'
    assert_equal 'foo', last_response.body
  end
  
  def test_serves_first_index
    get '/'
    assert_equal 'foo.html', last_response.body
  end
  
  def test_subfolders
    get '/qux'
    assert_equal 'qux/foo.html', last_response.body
  end
  
end

class TestApp < Sinatra::Base
  
  register Sinatra::Index
  use_static_indices 'foo.html', 'bar.html'

  set :app_file, __FILE__
  
end