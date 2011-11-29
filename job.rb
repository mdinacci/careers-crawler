# Copyright 2011 Marco Dinacci <marco.dinacci@gmail.com> / www.intransitione.com
# 
# Hi, this program reads jobs listings from the careers.stackoverflow.com website and 
# dump it on a file. It then read back the data and output JSON files ready to be 
# used with the Google Visualization API.
#
# You are free to do what you want with it except pretend that you wrote it. 
# If you redistribute it, keep the copyright line above.
#
# I've written it in a couple of days because/in order to:
# - learn Ruby, play some more with Javascript.
# - I like to "see" data
# - increase the chances of finding a *good* job

# This module contains the Job related classes.

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
        # Return true whether the string 'telecommut' (could be telecommutE or telecommutING) 
        # is contained in any of the fields
        can_telecommute = false

        [@title,@locations,@description,@locations].flatten.each do |field|
            can_telecommute = !field.downcase.index("telecommut").nil? 
            if can_telecommute
                break
            end
        end

        
        return can_telecommute
    end
end

end
