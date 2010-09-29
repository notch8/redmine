class ScheduledIssue < ActiveRecord::Base
  belongs_to :issues
  belongs_to :users

  # # Compute total time scheduled on issue
  #   connected with this object
  # @ returns float #
  def scheduledTime
    scheduledIssues = ScheduledIssue.all(:conditions => ["user_id = ? AND issue_id = ?", user_id, issue_id]);
    sum = scheduledIssues.sum(&:scheduled_hours) if !scheduledIssues.nil?

    return sum.nil? ? 0 : sum;
  end

  def ScheduledIssue.emptyHours(user_id, project_id, date)
    issue = ScheduledIssue.first(:conditions => ["user_id = ? AND date = ? AND project_id = ? AND issue_id = 0",
        user_id, date, project_id]);

    return issue;
  end

  #
  # Check if there are any scheduled issue for given
  # user/date/project, don't include empty hours
  #
  def ScheduledIssue.notEmpty?(user_id, project_id, date)
    sched_issue = ScheduledIssue.find_all_by_user_id_and_project_id_and_date(user_id, project_id, date);

    if(sched_issue.nil? || sched_issue.empty?)
      return true;
    else
      sched_issue.each do |s_issue|
        return false if(s_issue.issue_id != 0)
      end
      
      return true;
    end
  end

  #
  # Retrieve current issues
  #
  def ScheduledIssue.currentIssues(project_id, user_id)
    return Issue.all(:conditions => ["project_id = ?
      AND assigned_to_id IN (?) AND #{IssueStatus.table_name}.is_closed = 0",
        project_id, user_id],
      :joins => "LEFT JOIN issue_statuses ON #{Issue.table_name}.status_id = #{IssueStatus.table_name}.id");
  end

  #
  #
  # # #
  def issue()
    return Issue.find_by_id issue_id()
  end

  #
  #
  # # #
  def ScheduledIssue.find_by_all(user_id, project_id, date)
    return ScheduledIssue.all(:conditions => ["date = ? AND user_id = ? AND project_id = ?",
        date, user_id, project_id]);
  end

  #
  #
  # # #
  def ScheduledIssue.findByIssueIdAndDate(issue_id, date)
    return ScheduledIssue.all(:conditions => ["issue_id = ? AND date = ?",
        issue_id, date]);
  end

  #
  # Check if the ScheduleIssue is first of the day # # #
  def first?
    first = ScheduledIssue.all(:conditions => ["date = ? ORDER BY updated_at ASC LIMIT 1", self.data]);

    if(!first.nil? && !first.empty?)
      return first.first.id == self.id;
    else
      return true;
    end
  end

  #
  #
  # # # #
  def ScheduledIssue.previouslyUsedHours(user_id, project_id, date)
    scheduledIssues = ScheduledIssue.all(:conditions => ["date = ? AND user_id = ?
        AND project_id <> ? ", date, user_id, project_id]);
    if(!scheduledIssues.nil? && !scheduledIssues.empty?)
      hours = scheduledIssues.sum(&:scheduled_hours)
    else
      hours = 0;
    end

    return hours;
  end

  #
  #
  # # # #
  def ScheduledIssue.scheduledTimeByIssueAndDate(issue_id, date)
    sched_issue = ScheduledIssue.all(:conditions => ["issue_id = ? AND date = ?",
        issue_id, date]);
    if(!sched_issue.nil? && !sched_issue.empty?)
      return sched_issue.is_a?(Array) ? sched_issue.first.scheduled_hours : sched_issue.scheduled_hours;
    else
      return nil;
    end
  end

  #
  #
  # # # #
  def ScheduledIssue.hours(user_id, project_id, date)
    issues = ScheduledIssue.all(:conditions => ["date = ? AND project_id = ? AND
        user_id = ?", date, project_id, user_id]);
    sum = issues.sum(&:scheduled_hours) if !issues.nil?

    return sum.nil? ? 0 : sum;
  end

end
