#!/usr/bin/env ruby -w

# Copyright 2011 Marco Dinacci <marco.dinacci@gmail.com> / www.intransitione.com
# 
# Hi, this program reads jobs listings from the careers.stackoverflow.com website and 
# dump it on a file. It then read back the data and output JSON files ready to be 
# used with the Google Visualization API.
#
# You are free to do what you want with it except pretend that you wrote it. 
# If you redistribute it, keep the copyright line above.

require 'rubygems'
require 'job'
require 'json'
require 'spider'
require 'objectstore'
require 'matrix'
require 'pp'

JOBS_DB = "jobs.dump.gz"

data = "No data."

def loadJobs
  jobs = ObjectStore::load JOBS_DB
  
  # TODO not only if it is nil, also if it is outdated.
  if jobs.nil?
    spider = Spider::StackOverflowSpider.new Spider::DefaultSpiderConfiguration
    jobs = spider.crawl
    ObjectStore::store jobs, JOBS_DB
  end
  return jobs
end

def tagsFrequencyMap jobs, minimumFrequency
  jobs = loadJobs
  
  tagsOccurrences = {}
  jobs.each do |job| 
    job.tags.each do |tag|
      if tagsOccurrences[tag] == nil
        tagsOccurrences[tag] = 1
      else
        tagsOccurrences[tag] += 1 
      end
    end
  end
  
  # get rid of the tags that have less than minimumFrequency occurrences
  if minimumFrequency > 0
    tagsFrequency = {}
    tagsOccurrences.each do |tag,occurrence|
      if occurrence >= minimumFrequency
        tagsFrequency[tag] = occurrence
      end
    end
  
    tagsOccurrences = tagsFrequency
  end
  return tagsOccurrences
end

def tagsCloud jobs, minFrequency
  tagsMap = tagsFrequencyMap jobs, minFrequency
  
  # Format data in a way suitable for the Google Visualization API
  data = {}
  data["cols"] = [{"id" => "tag","label" => "Tag", "type" => "string"},
                {"id" => "frequency","label" => "Frequency", "type" => "number"},
                {"id" => "URL","label" => "URL", "type" => "string"}
                ]

  data["rows"] = []
  tagsMap.each do |tag, occurrence|
    cells = {"c" => [ 
                    {"v" => tag}, 
                    {"v" => occurrence},
                    {"v" => "http://careers.stackoverflow.com/jobs/tag/#{tag}"}
                    ]
            }
    data["rows"].push(cells)
  end
  
  return data
end
  
def tagsCumulus jobs, minFrequency
  tagsMap = tagsFrequencyMap jobs, minFrequency
  
  # Format data in a way suitable for the Google Visualization API
  data = {}
  
  # The cumulus, unlike the cloud, wants the URL *before* the frequency
  data["cols"] = [{"id" => "tag", "label" => "Tag", "type" => "string"},
                {"id" => "URL", "label" => "URL", "type" => "string"},
                {"id" => "frequency", "label" => "Frequency", "type" => "number"}
                ]

  data["rows"] = []
  
  max_occurrence = tagsMap.sort_by {|k,v| v}[-1][1]
  min_occurrence = 1
  max_font_size = 30
  min_font_size = 10
  tagsMap.each do |tag, occurrence|
    size = (max_font_size * (occurrence - min_occurrence)) / (max_occurrence - min_occurrence)

    cells = {"c" => [ 
                    {"v" => tag}, 
                    {"v" => "http://careers.stackoverflow.com/jobs/tag/#{tag}"},
                    {"v" => size}
                    ]
            }
    data["rows"].push(cells)
  end
  
  return data
end

def remoteVSLocal jobs
  remote_jobs = 0
  jobs.each do |job| 
    remote_jobs += 1 if job.telecommute?
  end
  
  data = {}
  data["cols"] = [{"id" => "key","label" => "key", "type" => "string"},
                 {"id" => "value","label" => "value", "type" => "number"}
                ]

  data["rows"] = []
  cell_local = {"c" => [ 
                    {"v" => "Local"},
                    {"v" => jobs.length}
                    ]
            }
   cell_remote = {"c" => [ 
                    {"v" => "Remote"},
                    {"v" => remote_jobs}
                    ]
               }
  data["rows"].push(cell_local)
  data["rows"].push(cell_remote)

  return data
end

def jobsPerCountry jobs
  data = {}
  data["cols"] = [{"id" => "key","label" => "key", "type" => "string"},
                 {"id" => "value","label" => "value", "type" => "number"}
                ]

  data["rows"] = []

  return data
end

def tagsGraph jobs
  nodes = {}
  tagsMap = tagsFrequencyMap jobs, 3

  tmp = tagsMap.sort_by {|k,v| v}.reverse
  best_tags = []
  tmp.each do |tag,number|
    best_tags.push tag
    if best_tags.length == 20:  
      break
    end
  end

  jobs.each do |job| 
    tags = job.tags
    keys = nodes.keys

    tags.each do |tag|
      # HACK combine html5 and html
      if tag.strip == "html5"
        tag = "html"
      end
      # check that tag is included in the tags map 
      if best_tags.include? tag
        # create a new hash for a new tag
        if ! keys.include? tag
          nodes[tag] = {}
        end
        links_keys = nodes[tag].keys
        # array containing all the other tags
        linked_tags = tags.reject {|x| x==tag}
        linked_tags.each do |linked_tag|
          # HACK combine html5 and html
          if linked_tag.strip == "html5"
            linked_tag = "html"
          end
          if links_keys.include? linked_tag
            nodes[tag][linked_tag] +=1
          else
            nodes[tag][linked_tag] = 1
          end
        end
      end
    end
  end

  nodes.each do |tag, tags|
    nodes[tag] = tags.sort_by {|k,v| v}.reverse[0..9]
  end

# debug stuff to test  
=begin
  if the_tags[0] == "all"
    pp nodes.sort
  else
    the_tags.each do |the_tag|
      pp nodes[the_tag].sort
    end
  end
=end

return nodes

end

def writeJSON fileName, data
  puts fileName
  f = File.new(fileName, "w")
  f.write(data)
  f.close()
end

# load jobs dump
jobs = loadJobs

# Generate all the JSON files with the data required by the visualizations

data = tagsGraph jobs
writeJSON "json/tagsGraph.json", JSON.generate(data)

data = tagsCumulus jobs, 0
writeJSON "json/tagsCumulusJSON_full.json", JSON.generate(data)

data = tagsCumulus jobs, 5
writeJSON "json/tagsCumulusJSON_mini.json", JSON.generate(data)

data = tagsCloud jobs, 0
writeJSON "json/tagsCloudJSON_full.json", JSON.generate(data)

data = tagsCloud jobs, 5
writeJSON "json/tagsCloudJSON_mini.json", JSON.generate(data)

data = remoteVSLocal jobs
writeJSON "json/remoteVSlocal.json", JSON.generate(data)

#data = jobsPerCountry
#writeJSON "json/jobsPerCountry.json", JSON.generate(data)

