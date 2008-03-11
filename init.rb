ActionController::Base.send :include, InheritableTemplates::Controller
ActionView::PartialTemplate.send :include, InheritableTemplates::PartialTemplate
