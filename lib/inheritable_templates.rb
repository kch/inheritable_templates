module InheritableTemplates

  # abstracts the process of finding an existing template up the controller inheritance chain
  def self.find_inherited_template(controller, template_basename)
    k = controller.class
    while (k = k.superclass) < ActionController::Base
      template_name = "#{k.controller_path}/#{template_basename}"
      return template_name if controller.send :template_exists?, template_name
    end
  end

  # extends ActionController::Base
  module Controller
    def self.included base
      base.alias_method_chain :default_template_name, :inheritance
    end
  
    def default_template_name_with_inheritance(action_name = self.action_name)
      template_name = default_template_name_without_inheritance(action_name)
      return template_name if template_exists? template_name
      InheritableTemplates.find_inherited_template(self, action_name) || template_name
    end
  end

  # extends ActionView::Partials
  module Partials
    def self.included base
      base.alias_method_chain :find_partial_path, :inheritance
    end

    def find_partial_path_with_inheritance(partial_path)
      path = find_partial_path_without_inheritance(partial_path)
      return path unless !partial_path.include?('/') && respond_to?(:controller) && !file_exists?(path)
      InheritableTemplates.find_inherited_template(controller, "_#{partial_path}")
    end
  end
  
end
