require 'rubygems'
require 'fastercsv'
require 'task'

module Import
  class Story
    attr_accessor :title, :description, :size, :priority, :tasks
  
    def self.stories
      @@stories ||= []
    end
  
    def self.find(title)
      Import::Story.stories.detect do |story| story.title == title end
    end
  
    def self.load_from_csv(csv_file)
      FasterCSV.foreach(csv_file, :headers => true) do |line|
        unless story = Import::Story.find(line["story_title"])
          story = Import::Story.new(:title => line["story_title"],
                            :description => line["story_description"],
                            :size => line["story_size_value"],
                            :priority => line["priority"],
                            :tasks => [])
        end

        story.tasks << Import::Task.new(:description =>line["task_description"],
                                :estimated_hours => line["estimated_hours"],
                                :status => line["task_status"])

      end
    end
  
    def initialize(opts={})
      opts.each do |key, value|
        send("#{key}=", value)
      end
      Import::Story.stories << self
    end

  end
end