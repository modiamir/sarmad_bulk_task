Redmine::Plugin.register :bulk_task do
  name 'Bulk Task plugin'
  author 'SarmadBS'
  description 'This plugin add issue bulk creation feature'
  version '0.0.1'
  url 'http://sarmadbs.com/'
  author_url 'plugin@satrapp.com'
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

Redmine::MenuManager.map :project_menu do |menu|
  menu.push(:bulk_task, { controller: 'bulks', action: 'new' },
            param: :project_id,
            caption: :bulk_task,
            if: proc { |p| User.current.allowed_to?(:bulk_issues, p, :global => true) })
end
