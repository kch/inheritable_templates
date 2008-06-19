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
      while !super_name && (k = k.superclass) < ActionController::Base
        s = k.name.underscore.sub(/_controller$/, "/" + name.split('/').last) 
        (super_name = s) and next if template_exists? s
      end
      super_name || name
    end
  end
  
  module PartialTemplate
    def self.included base
      base.alias_method_chain :initialize, :inheritance
      base.alias_method_chain :set_path_and_variable_name!, :inheritance
    end

    def initialize_with_inheritance(view, partial_path, object = nil, locals = {})
      @view = view
      initialize_without_inheritance(view, partial_path, object, locals)
    end

    def set_path_and_variable_name_with_inheritance!(partial_path)
      return set_path_and_variable_name_without_inheritance!(partial_path) if partial_path.include?('/') || !@view_controller

      @variable_name = partial_path
      k = @view_controller.class
      while k < ActionController::Base
        tentative_path = "#{k.controller_path}/_#{@variable_name}"
        break @path = tentative_path if @view.view_paths.template_exists?(@view.send(:template_file_from_name, tentative_path))
        k = k.superclass
      end
      @path ||= "#{@view_controller.controller_path}/_#{@variable_name}"

      @variable_name = @variable_name.sub(/\..*$/, '').to_sym
    end

  end
  
end
