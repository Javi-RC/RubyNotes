ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors, with: :threads)

  fixtures :all

  teardown do
    Mongoid.purge! if defined?(Mongoid)
  end
end
