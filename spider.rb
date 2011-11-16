module Spider
  
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'job'

class DefaultSpiderConfiguration
  def self.source
    return "http://careers.stackoverflow.com/jobs?pg=0"
  end
  
  def self.jobs
    return "//div[@id='jobslist']/div[@class='listitem']"
  end
  
  def self.title
    return ".//a[@class='title']/@title"
  end
  
  def self.score 
    return ".//span[@class='joeltestscore']/text()"
  end
  
  def self.location 
    return ".//p[@class='location']/text()"
  end
  
  def self.tags
    return ".//a[@class='post-tag']/text()"
  end
end

=begin
#SOURCE = "http://careers.stackoverflow.com/jobs?pg=0"
SOURCE = "/Users/marco/Downloads/sourcecareers.html"
=end

class StackOverflowSpider
  def initialize config
    @config = config
  end
  
  def crawl
    jobs = []
    doc = Nokogiri::HTML(open(@config.source))
    doc.xpath(@config.jobs).each do |jobElement|
        job = Job::Job.new

        job.title = jobElement.xpath(@config.title).to_s
        job.score = jobElement.xpath(@config.score).to_s.to_i
        jobElement.xpath(@config.tags).each {|tag| job.tags.push(tag.to_s.downcase)}

        locations = jobElement.xpath(@config.location).to_s
        # Remove annoying &nbsp; and split string to obtain an array of locations
        job.locations = locations.gsub!(/(&nbsp;|\s)+/, " ").split(';')

        jobs.push(job)
      end
    
    return jobs
  end
end

end
	  