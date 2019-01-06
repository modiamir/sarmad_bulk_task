Redmine::Plugin.register :bulk_task do
  name 'تسک ساز پیشرفته'
  author 'SarmadBS'
  description 'ساخت تسک به صورت دسته جمعی با حداقل اطلاعات'
  version '1.0.1'
  url 'http://sarmadbs.com'
  author_url 'mailto:plugin@satrapp.com'

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
