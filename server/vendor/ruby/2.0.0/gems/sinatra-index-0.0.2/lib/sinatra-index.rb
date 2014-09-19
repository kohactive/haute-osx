require 'rubygems'
require 'sinatra/base'

module Sinatra
  module Index
    
    def self.registered(app)
      app.set :static_indices, []
      app.before do
        if app.static? && (request.get? || request.head?)
          orig_path = request.path_info
          path = unescape orig_path
          path = path << '/' unless path.end_with? '/'

          app.static_indices.each do |idx|
            request.path_info = path + idx
            static!
          end

          request.path_info = orig_path
        end 
      end
    end
    
    def use_static_indices(*args)
      static_indices.concat(args.flatten)
    end
    
    alias_method :use_static_index, :use_static_indices
  end
  
  register Index
end
