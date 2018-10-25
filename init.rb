Redmine::Plugin.register :bulk_task do
  name 'Bulk Task plugin'
  author 'Amir Modarresi'
  description 'This plugin add issue bulk creation feature'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://amir.modarre.si'
  settings :default => {'empty' => true}, :partial => 'settings/bulk_task_settings'

  unless ProjectsHelper.included_modules.include?(ProjectsHelperPatch)
    ProjectsHelper.send(:include, ProjectsHelperPatch)
  end

  Redmine::AccessControl.map do |map|
    map.project_module :issue_tracking do |map|
      map.permission :bulk_issues, {:bulks=> [:new, :create]}
    end
  end
end
