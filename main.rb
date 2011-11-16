#!/usr/bin/env ruby -w

# Copyright 2011 Marco Dinacci <marco.dinacci@gmail.com> / www.intransitione.com
# 
# Hi, this program reads data from the careers.stackoverflow.com website and 
# try to make sense of it with the aid of some visualizations. 
#
# You are free to do what you want with it except pretend that you wrote it. 
# If you redistribute it, keep the copyright line above.
#
# I've written it in a couple of days in order to:
# - learn Ruby
# - be accepted on careers.stackoverflow.com 
# - increase the chances of finding a *good* job
# - killing time because my client is not paying me for the iPhone app I'm developing
#   and I generally don't work for free.

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