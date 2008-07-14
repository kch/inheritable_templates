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
  
  module View
    def self.included base
      base.alias_method_chain :partial_pieces, :inheritance
      super
    end
  
    def partial_pieces_with_inheritance(partial_path)
      pieces = partial_pieces_without_inheritance(partial_path)
      return pieces if forgiving_template_exists?(pieces) || partial_path.include?('/')
      name = pieces.last
      
      k = controller.class
      super_pieces = nil
      while !super_pieces && (k = k.superclass) <= ApplicationController
        path = k.name.underscore.sub(/_controller$/, '')
        (super_pieces = [path, name]) and next if forgiving_template_exists?(path, name)
      end

      super_pieces || pieces
    end
    
    def forgiving_template_exists?(*pieces)
      path = [pieces].flatten.join("/_")
      begin 
        ext = find_template_extension_for(path)
      rescue ::ActionView::ActionViewError
        return false
      end
      template_exists? path, ext
    end
  end
  
end
