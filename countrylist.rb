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