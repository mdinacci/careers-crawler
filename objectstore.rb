# Copyright 2011 Marco Dinacci <marco.dinacci@gmail.com> / www.intransitione.com
# 
# Hi, this program reads jobs listings from the careers.stackoverflow.com website and 
# dump it on a file. It then read back the data and output JSON files ready to be 
# used with the Google Visualization API.
#
# You are free to do what you want with it except pretend that you wrote it. 
# If you redistribute it, keep the copyright line above.
#
# This module is responsible of storing and loading the jobs data on disk.

module ObjectStore
  
require 'zlib'

  # Store an object as a gzipped file to disk
  def store obj, file_name, options={}
    f = File.new(file_name,'w')
    f = Zlib::GzipWriter.new(f) unless options[:gzip] == false
    f.write Marshal.dump(obj)
    f.close
    return obj
  end
  
  # Read a marshal dump from file and load it as an object
  def load file_name
    begin
      file = Zlib::GzipReader.open(file_name)
    rescue Zlib::GzipFile::Error
      file = File.open(file_name, 'r')
    ensure
      obj = nil
      if not file.nil?
        obj = Marshal.load file.read
        file.close
      end
      return obj
    end
  end

module_function :store
module_function :load
  
end
