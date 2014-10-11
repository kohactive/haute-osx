require 'active_record'

ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'w'))

ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => 'haute.db'
)

ActiveRecord::Schema.define do

  unless ActiveRecord::Base.connection.tables.include? 'projects'
    create_table :projects do |table|
      table.column :title,                :string
      table.column :path,                 :string
      table.column :css_relative,         :string
      table.column :css_absolute,         :string
      table.column :stylesheets_relative, :string
      table.column :stylesheets_absolute, :string
      table.column :variables_relative,   :string
      table.column :variables_absolute,   :string
      table.column :output_relative,      :string
      table.column :output_absolute,      :string
    end
  end

  unless ActiveRecord::Base.connection.tables.include? 'blocks'
    create_table :blocks do |table|
      table.column :project_id,     :integer
      table.column :block_title,    :string
      table.column :block_content,  :string
    end
  end

  class Project < ActiveRecord::Base
    has_many :blocks
  end

  class Block < ActiveRecord::Base
    belongs_to :project
  end

end
