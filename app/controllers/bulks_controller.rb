class BulksController < ApplicationController
  include BulksHelper

  before_action :find_optional_project, :only => [:new, :create]
  # before_action :build_new_issue_from_params, :only => [:new, :create]

  def new
    @fields = bulk_fields @project
    @issues = 1.times.to_a.map do |_k|
      Issue.new project_id: @project.id,
                author_id: User.current.id
    end

    if request.xhr?
      render layout: false, partial: "rows", locals: {issues: @issues}
    end

  end

  def create
    unless User.current.allowed_to?(:bulk_issues, @project, :global => true)
      raise ::Unauthorized
    end

    @issues = params[:issues].map{|attrs|build_new_issue attrs}
    @invalid_issues = @issues.reject{|issue|issue.valid?}

    if @invalid_issues.length > 0
      # return render json: @invalid_issues.map{|issue|issue.errors[:subject]}
      @fields = bulk_fields @project
      return render :action => 'new'
    end

    ActiveRecord::Base.transaction do
      @issues.each do |issue|
        issue.save!
      end

      easy_gantt_path = easy_gantt_path(project_id: @project.id)
      # begin
      # rescue
      #   easy_gantt_path = nil
      # end
      flash[:notice] = l(:notice_bulk_issue_successful_create,
                         count: @issues.length,
                         easy_gantt_path: easy_gantt_path,
                         overview_path: project_path(id: @project.id))
    end

    redirect_to action: :new
  end

  def build_new_issue attrs
    issue = Issue.new
    issue.project = @project
    if request.get?
      issue.project ||= issue.allowed_target_projects.first
    end
    issue.author ||= User.current
    issue.start_date ||= User.current.today if Setting.default_issue_start_date_to_creation_date?
    issue.safe_attributes = attrs
    if issue.project
      issue.tracker ||= issue.allowed_target_trackers.first
      if issue.tracker.nil?
        if issue.project.trackers.any?
          # None of the project trackers is allowed to the user
          render_error :message => l(:error_no_tracker_allowed_for_new_issue_in_project), :status => 403
        else
          # Project has no trackers
          render_error l(:error_no_tracker_in_project)
        end
        return false
      end
      if issue.status.nil?
        render_error l(:error_no_default_issue_status)
        return false
      end
    elsif request.get?
      render_error :message => l(:error_no_projects_with_tracker_allowed_for_new_issue), :status => 403
      return false
    end
    issue
  end

  def issue_params
    params.require(:person).permit(bulk_fields @project)
  end
end
