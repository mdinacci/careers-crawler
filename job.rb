module Job

class Job
    attr_accessor :title, :tags, :score, :locations, :description
    
    def initialize
      @tags = []
      @locations = []
      @description = nil
    end
    
    def to_s
        "#{@title} - #{@locations} (#{@score}) \n #{@description} \n #{@tags}\n"
    end

    def telecommute?
        # Return true whether the string 'telecommut' or 'remote' is contained
        # either in the title or the description
        canTelecommute = false

        # Search in title
        if not @title.nil?
            titleDown = @title.downcase
            canTelecommute = !titleDown.index("telecommut").nil?
        end
        
        # No need to search in description if variable is already true
        if canTelecommute 
            return canTelecommute
        end

        if not @locations.nil?
            locationsDown = @locations.join.downcase
            canTelecommute = !locationsDown.index("telecommut").nil?
        end

        if canTelecommute 
            return canTelecommute
        end

        # If not found in title nor in location search in description
        if not @description.nil?
            descriptionDown = @description.downcase
            canTelecommute = !descriptionDown.index("telecommut").nil? 
        end
        
        return canTelecommute
    end
end

end
