module Import
  class Task
    attr_accessor :description, :estimated_hours, :status
  
    def initialize(opts={})
      opts.each do |key, value|
        send("#{key}=", value)
      end    
    end
  end
end