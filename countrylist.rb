# Copyright 2011 Marco Dinacci <marco.dinacci@gmail.com> / www.intransitione.com
# 
# Hi, this program reads jobs listings from the careers.stackoverflow.com website and 
# dump it on a file. It then read back the data and output JSON files ready to be 
# used with the Google Visualization API.
#
# You are free to do what you want with it except pretend that you wrote it. 
# If you redistribute it, keep the copyright line above.

module CountryList

def loadFromFile countries_file
	f = File.new countries_file
	countries = {}
	f.each do |line|
		country, code = line.split(';').collect(|word| word.upcase)
		countries[country] = code[0...-2] #discard \r\n
	end

	f.close

	return countries
end

class CountryList

	def initialize countries_file
		@countries_file = countries_file
		@countries = {}
	end

	def contains country_name
		if @countries.empty?
			@countries = loadFromFile @countries_file
		end
		return @countries.keys.include? country_name
	end
end

end
