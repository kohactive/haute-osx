# Sinatra Indices

The problem: you want the path `/` to give the contents of `public/index.html` and `/foo`, to go to `public/foo/index.html`.

The solution:

    require 'rubygems'
	require 'sinatra-index'
    
    class MyApp < Sinatra::Base
      register Sinatra::Index
      use_static_index 'index.html'
	  
	  ... Sinatra routes ...
	end