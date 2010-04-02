C_DIR = File.dirname(__FILE__)
def path(p)
  File.join(C_DIR,p)
end

$:.unshift(path('../lib'))
require 'rubygems'
require 'test/unit'
require 'depo'
require 'active_support'
require 'active_support/test_case'
require "rails_generator"
require "active_record"
require 'rails_generator/scripts/generate'
require 'ftools'


gem_root= path('..')
Rails::Generator::Base.default_options :collision => :ask, :quiet => false
Rails::Generator::Base.reset_sources
Rails::Generator::Base.append_sources(Rails::Generator::PathSource.new(:plugin, "#{gem_root}/generators/"))

RAILS_ROOT = path('rails_root')

class GeneratorTest < ActiveSupport::TestCase
  def generate(*args)
    Rails::Generator::Scripts::Generate.new.run(args, :destination=>fake_rails_root)
  end

  def read(path)
    IO.readlines("#{fake_rails_root}/#{path}",'').to_s
  end

  def assert_file(file)
    assert_block "File #{file} not exists, as not expected" do
      File.exists? "#{fake_rails_root}/#{file}"
    end
  end

  def create_if_missing *names
    names.each do |name|
      File.makedirs(name) unless File.directory?(name)
    end
  end

  def setup
    FileUtils.rm_r(fake_rails_root)
    FileUtils.mkdir_p(fake_rails_root)
  end

  protected
  def fake_rails_root
   RAILS_ROOT
  end
end

class TestDbUtils
  class<< self
    def config
      @config ||= YAML::load(IO.read(path('/database.yml'))).symbolize_keys
    end

    #create test database
    def ensure_test_database
      connect_to_test_db
    rescue
      create_database
    end

    def load_schema
      ensure_test_database
      load(path('db/schema.rb'))
    end

    def ensure_schema
      load_schema
    rescue
      puts "tests database exists: skip schema loading"
    end

    def create_database
      connect_to_postgres_db
      ActiveRecord::Base.connection.create_database(config[:database], config)
      connect_to_test_db
    rescue
      $stderr.puts $!, *($!.backtrace)
      $stderr.puts "Couldn't create database for #{config.inspect}"
    end

    def connect_to_test_db
      ActiveRecord::Base.establish_connection(config)
      ActiveRecord::Base.connection
    end

    def connect_to_postgres_db
      ActiveRecord::Base.establish_connection(config.merge(:database => 'postgres', :schema_search_path => 'public'))
    end

    def drop_database
      connect_to_postgres_db
      ActiveRecord::Base.connection.drop_database config[:database]
    end
  end
end
