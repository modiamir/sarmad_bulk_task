require_dependency 'projects_helper'

module ProjectsHelperPatch

  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      unloadable
      alias_method_chain :project_settings_tabs, :bulk_task
    end
  end

  module ClassMethods
  end

  module InstanceMethods

    def project_settings_tabs_with_bulk_task
      tabs = project_settings_tabs_without_bulk_task
      tabs.push({ :name => 'bulk_task_attributes',
                  :partial => 'settings/attributes',
                  :label => "settings.attributes" })

      tabs
    end

  end

end
