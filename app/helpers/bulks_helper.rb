module BulksHelper
  include IssuesHelper
  def plugin_settings
    Setting.available_settings["plugin_bulk_task"].present? ? Setting.plugin_bulk_task : {}
  end

  def bulk_fields project
    settings = plugin_settings
    # Setting
    #   .plugin_bulk_task.select{|key,value|key.start_with?("attributes__")}
    #   .map{|key,value|key.split("attributes__")[1]}
    fields = (settings["project_#{project.id}"].present? && settings["project_#{project.id}"]["attributes"].present?) ? settings["project_#{project.id}"]['attributes'].keys : []

    ["tracker_id", "subject"] + fields
  end

  def field_tag(form, issue, field_name:)
    return unless [
      'tracker_id',
      'subject',
      'priority_id',
      'assigned_to_id',
      'description',
      'start_date',
      'due_date',
      'estimated_hours'
    ].include? field_name

    self.send("field_#{field_name}", form, issue)
  end

  def field_tracker_id(f, issue)
    f.select :tracker_id, trackers_options_for_select(issue), {:required => true}
  end

  def field_subject(f, _issue)
    f.text_field :subject, :size => 20, :maxlength => 255, :required => true
  end

  def field_description(f, issue)
    f.text_area :description,
                :cols => 20,
                :rows => 5,
                :accesskey => accesskey(:edit),
                :class => 'wiki-edit',
                :no_label => true
  end

  def field_priority_id(f, issue)
    priorities = IssuePriority.active
    f.select :priority_id, (priorities.collect {|p| [p.name, p.id]}), {:required => true}
  end

  def field_assigned_to_id(f, issue)
    f.select :assigned_to_id, principals_options_for_select(issue.assignable_users, issue.assigned_to), :include_blank => true, :required => issue.required_attribute?('assigned_to_id')
  end

  def field_start_date(f, issue)
    f.date_field(:start_date, :size => 10, :required => issue.required_attribute?('start_date'))
  end

  def field_due_date(f, issue)
    f.date_field(:due_date, :size => 10, :required => issue.required_attribute?('due_date'))
  end

  def field_estimated_hours(f, issue)
     (f.text_field :estimated_hours, :size => 3, :required => issue.required_attribute?('estimated_hours')) + l(:field_hours)
  end
end
