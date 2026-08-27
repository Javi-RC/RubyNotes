begin
  require "minitest/rake_task"
  Minitest::RakeTask.new(:brakeman)
rescue LoadError
  # minitest/rake_task not available
end
