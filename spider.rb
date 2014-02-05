# Copyright 2011 Marco Dinacci <marco.dinacci@gmail.com> / www.intransitione.com
# 
# Hi, this program reads jobs listings from the careers.stackoverflow.com website and 
# dump it on a file. It then read back the data and output JSON files ready to be 
# used with the Google Visualization API.
#
# You are free to do what you want with it except pretend that you wrote it. 
# If you redistribute it, keep the copyright line above.
#
# This module contains the web crawler.

module Spider
  
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require_relative 'job'

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

  def self.description
    return ".//p[@class='description']/text()"
  end
end

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
        #jobElement.xpath(@config.tags).each {|tag| job.tags.push(tag.to_s.downcase)}
        jobElement.xpath(@config.tags).each do |tag| 
          # refine a few tags that are semantically the same but have different text
          tag = tag.to_s.downcase
          if tag == "html5" || tag == "html4"
            tag = "html" 
          end
          if tag == "rails" || tag == "ror"
            tag = "ruby-on-rails" 
          end
          if tag == "css3"
            tag = "css" 
          end
          job.tags.push(tag)
        end

        locations = jobElement.xpath(@config.location).to_s
        # Remove annoying &nbsp; and split string to obtain an array of locations
        job.locations = locations.gsub!(/(&nbsp;|\s)+/, " ").split(';')

        job.description = jobElement.xpath(@config.description).to_s

        jobs.push(job)
      end
    
    return jobs
  end
end

end
	  