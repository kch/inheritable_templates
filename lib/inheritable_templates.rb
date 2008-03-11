module InheritableTemplates
  
  module Controller
    def self.included base
      base.alias_method_chain :default_template_name, :inheritance
      super
    end
  
    def default_template_name_with_inheritance *args
      name = default_template_name_without_inheritance *args
      return name if template_exists? name
      k = self.class
      super_name = nil
      while !super_name && (k = k.superclass) <= ApplicationController
        s = k.name.underscore.sub(/_controller$/, "/" + name.split('/').last) 
        (super_name = s) and next if template_exists? s
      end
      super_name || name
    end
  end
  
  module PartialTemplate
    def self.included base
      base.alias_method_chain :partial_pieces, :inheritance
    end

    def partial_pieces_with_inheritance(view, partial_path)
      pieces = partial_pieces_without_inheritance(view, partial_path)
      return pieces if partial_path.include?('/') || partial_template_exists?(view, *pieces)
      name = pieces.last
      
      k = view.controller.class
      super_pieces = nil
      while !super_pieces && (k = k.superclass) <= ApplicationController
        path = k.name.underscore.sub(/_controller$/, '')
        (super_pieces = [path, name]) and next if partial_template_exists?(view, path, name)
      end

      super_pieces || pieces
    end
    
    def partial_template_exists?(view, path, name)
      view.finder.file_exists?("#{path}/_#{name}")
    end

  end
  
end
