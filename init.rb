ActionController::Base.send :include, InheritableTemplates::Controller
ActionView::Base.send :include, InheritableTemplates::View
