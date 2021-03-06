require File.dirname(__FILE__) + '/../../test_helper.rb'

class PluginGeneratorTest < Test::Unit::TestCase
  
  def test_generate
    pg = PluginGenerator.new("name" => "bandit")
    assert !File.exists?(bandit_dir)
    assert !File.exists?(File.join(bandit_dir, "init.rb"))
    assert !File.exists?(File.join(bandit_dir, "lib"))
    assert !File.exists?(File.join(bandit_dir, "lib", "bandit.rb"))
    assert !File.exists?(File.join(bandit_dir, "lib", "tasks"))
    pg.generate
    assert File.exists?(bandit_dir)
    assert File.exists?(File.join(bandit_dir, "init.rb"))
    assert File.exists?(File.join(bandit_dir, "lib"))
    assert File.exists?(File.join(bandit_dir, "lib", "bandit.rb"))
    assert File.exists?(File.join(bandit_dir, "lib", "tasks"))
    assert File.exists?(File.join(bandit_dir, "lib", "tasks", "bandit_tasks.rake"))
    
    File.open(File.join(bandit_dir, "init.rb"), "r") do |f|
      assert_equal "require 'bandit'\n", f.read
    end

    File.open(File.join(bandit_dir, "lib", "bandit.rb"), "r") do |f|
      assert_equal "# Do work here for bandit\n", f.read
    end
  end
  
  def cleanup
    clean_bandit_dir
  end
  
  def bandit_dir
    File.join(Mack::Configuration.plugins, "bandit")
  end
  
end