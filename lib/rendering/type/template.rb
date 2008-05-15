module Mack
  module Rendering
    module Type
      class Template < Mack::Rendering::Type::Base
        
        def render
          t_file = File.join(Mack::Configuration.views_directory, "#{self.view_template.engine_type_value}.#{self.options[:format]}")
          Mack::Rendering::Engine::Registry.engines[:action].each do |e|
            @engine = engine(e).new(self.view_template)
            
            find_file(t_file + ".#{@engine.extension}") do |f|
              return @engine.render(File.open(f).read, self.view_template.binder)
            end
            
          end
          raise Mack::Errors::ResourceNotFound.new(t_file)
        end
        
        def concat(txt, b)
          @engine.concat(txt, b)
        end
        
      end
    end
  end
end