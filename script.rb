#!/usr/bin/env ruby -w

require 'rubygems'
require 'job'
require 'json'
require 'spider'
require 'objectstore'

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

def tagsFrequencyMap minimumFrequency
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
  
  # get rid of the tags that have only one occurrence
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

def tagsCloud minFrequency
  tagsMap = tagsFrequencyMap minFrequency
  
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
  
def tagsCumulus minFrequency
  tagsMap = tagsFrequencyMap minFrequency
  
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

def remoteVSLocal
  jobs = loadJobs
  
  remote_jobs = 0
  jobs.each do |job| 
    remote_jobs += 1 if job.telecommute?
  end
  
  data = {}
  data["cols"] = [{"id" => "remote","label" => "Remote", "type" => "number"},
                {"id" => "local","label" => "Local", "type" => "number"}
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

def writeJSON fileName, data
  puts fileName
  f = File.new(fileName, "w")
  f.write(data)
  f.close()
end

data = tagsCumulus 0
writeJSON "json/tagsCumulusJSON_full.json", JSON.generate(data)

data = tagsCumulus 5
writeJSON "json/tagsCumulusJSON_mini.json", JSON.generate(data)

data = tagsCloud 0
writeJSON "json/tagsCloudJSON_full.json", JSON.generate(data)

data = tagsCloud 5
writeJSON "json/tagsCloudJSON_mini.json", JSON.generate(data)

data = remoteVSLocal
writeJSON "json/remoteVSlocal.json", JSON.generate(data)
