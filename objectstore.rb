module ObjectStore
  
require 'zlib'

  # Store an object as a gzipped file to disk
  # ObjectStore::store hash, 'hash.stash.gz'
  # ObjectStore.store hash, 'hash.stash', :gzip => false
  def store obj, file_name, options={}
    marshal_dump = Marshal.dump(obj)
    file = File.new(file_name,'w')
    file = Zlib::GzipWriter.new(file) unless options[:gzip] == false
    file.write marshal_dump
    file.close
    return obj
  end
  
  # Read a marshal dump from file and load it as an object
  # Ex. hash = ObjectStore.get 'hash.dump.gz'
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
