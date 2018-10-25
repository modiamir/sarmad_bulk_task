class ProjectSettingsController < ActionController::Base
  def save
    project_id = params[:project_id]
    setting = Setting.plugin_bulk_task
    project_setting = params.require(:settings).to_hash["project_#{project_id}"]
    setting["project_#{project_id}"] = project_setting
    Setting.plugin_bulk_task = setting

    redirect_to settings_project_path(id: project_id, tab: :bulk_task_attributes)
  end
end
