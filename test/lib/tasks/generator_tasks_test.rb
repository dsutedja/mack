require File.dirname(__FILE__) + '/../../test_helper.rb'

class GeneratorTasksTest < Test::Unit::TestCase
  
  def test_list
    rake_task("generator:list") do
      assert_not_nil ENV["__generator_list"]
      
      model_gen_str = scaffold_gen_str = migration_gen_str = ""
      
      if !app_config.orm.nil?
        list = <<-LIST

Available Generators:

MackApplicationGenerator
	rake generate:mack_application_generator
ModelGenerator
	rake generate:model_generator
ScaffoldGenerator
	rake generate:scaffold_generator
PluginGenerator
	rake generate:plugin_generator
MigrationGenerator
	rake generate:migration_generator
        LIST
      else
        list = <<-LIST

Available Generators:

MackApplicationGenerator
	rake generate:mack_application_generator
PluginGenerator
	rake generate:plugin_generator
        LIST
      end
      
      # puts "---------------------------------"
      # puts "TEST: \n#{list}"
      # puts
      # puts ENV["__generator_list"]
      # puts "---------------------------------"
      
      assert_equal list.squeeze, ENV["__generator_list"].squeeze
    end
  end
  
end