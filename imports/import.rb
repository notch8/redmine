Import::Story.load_from_csv("cplus.csv")
project_id = 2
feature_id = 2
task_id = 4
author_id = 1

status_map = {"Not Started" => 1, nil => 1, "Completed" => 5, "Committed" => 3, "Staged" => 7}

Import::Story.stories.each do |story|
  begin
    feature = Issue.create!(:project_id => project_id,
                  :tracker_id => feature_id,
                  :subject => story.title,
                  :description => story.description,
                  :position => story.priority,
                  :story_points => story.size,
                  :author_id => 1)
    feature.move_to_root
    story.tasks.each do |task|
      begin
        raise "Can't find #{task.status}" unless status_id = status_map[task.status]
        task = Issue.create!(:project_id => project_id,
                      :tracker_id => task_id,
                      :subject => task.description[0..50],
                      :description => task.description,
                      :status_id => status_id,
                      :root_id => feature.id,
                      :estimated_hours => task.estimated_hours,
                      :author_id => 1
                      )
        feature.reload
        task.reload
        task.move_to_child_of feature
      rescue Exception => error
        puts task.description
        puts error.message
      end
    end
  rescue Exception => error
    puts story.title
    puts error.message
  end
end