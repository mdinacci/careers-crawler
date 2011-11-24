require 'rubygems'
require 'sinatra'
require 'job'
require 'json'
require 'spider'
require 'objectstore'

JOBS_DB = "jobs.dump.gz"

data = "No data."

def tagsCloud
  jobs = ObjectStore::load JOBS_DB
  
  # TODO not only if it is nil, also if it is outdated.
  if jobs.nil?
    spider = Spider::StackOverflowSpider.new Spider::DefaultSpiderConfiguration
    jobs = spider.crawl
    ObjectStore::store jobs, JOBS_DB
  end
  
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
  
  return tagsOccurrences
end


get '/careers/remotevslocal' do
  puts 'hello, not ready yet'
end

get '/careers/jobsbycountry' do
  puts 'hello, not ready yet'
end

get '/careers/tagcloud' do
  tagsMap = tagsCloud()
          
  # Format data in a way suitable for the Google Visualization API
  data = {}
  data["cols"] = [{"label" => "Tag", "type" => "string"},
                  {"label" => "URL", "type" => "number"}]
  
  data["rows"] = []
  tagsMap.each do |tag, occurrence|
    cells = {"c" => [ 
                      {"v" => tag}, 
                      {"v" => occurrence}
                    ]
            }
    data["rows"].push(cells)
  end
    
  # return JSON formatted data
  content_type :json
  puts JSON.generate(data)
end

not_found do
  puts '404.'
end