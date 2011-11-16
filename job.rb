module Job

class Job
    attr_accessor :title, :tags, :score, :locations, :description
    
    def initialize
      @tags = []
      @locations = []
      @description = nil
    end
    
    def to_s
        "#{@title} - #{@location} (#{@score}) \n #{@description} \n #{@tags}\n"
    end

    def telecommute?
        # Return true whether the string 'telecommut' or 'remote' is contained
        # either in the title or the description
        canTelecommute = false
        
        # Search in title
        if not @title.nil?
            titleDown = @title.downcase
            canTelecommute = titleDown.index("telecommut") ||
                             titleDown.index("remote")
        end
        
        # No need to search in description if variable is already true
        if canTelecommute 
            return canTelecommute
        end

        # If not found in title search in description
        if not @description.nil?
            descriptionDown = @description.downcase
            canTelecommute = descriptionDown.index("telecommut") ||
                             descriptionDown.index("remote")
        end
        
        return canTelecommute
    end
end

end
