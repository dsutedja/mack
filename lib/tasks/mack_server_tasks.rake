namespace :mack do
  
  namespace :server do

    desc "Starts the webserver."
    task :start do |t|
      require 'rubygems'
      require 'thin'
      MACK_ROOT = FileUtils.pwd unless Object.const_defined?("MACK_ROOT")
      require 'mack'
      Thin::Runner.new(["start"]).run!
    end # start

  end # server
  
end # mack

alias_task :server, "log:clear", "mack:server:start"