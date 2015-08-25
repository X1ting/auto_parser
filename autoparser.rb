require 'open-uri'
require 'pry'
require 'nokogiri'
fname = "marks_json.txt"

somefile = File.open(fname, "w")
url_start = 'http://auto.ru'
html = open(url_start)
doc = Nokogiri::HTML(html)
start_time = Time.now
temp_arr = []
hash = {}
doc.css('.marks-col-item').each do |marka|
	key = marka.children.first.attributes["name"].value
	value = marka.children.first["href"]
	hash["#{key}"] = value
end
count = hash.count
puts "Count of model = #{count}"
resulted_hash = {}
i = 0
hash.each do |key, value|
	i = i + 1
	puts "Parsed #{i} model, called #{key.capitalize}, remaining #{count - i} models"
	url = url_start + value
	html = open(url)
	doc = Nokogiri::HTML(html)
	models_array = []
	doc.css('.fast-mmm-link').each do |model|
		models_array.push(model.children.first.text)
	end
	resulted_hash["#{key}"] =  models_array.uniq
end
somefile.puts resulted_hash
puts "Parsed for #{(Time.now - start_time).round} seconds"
somefile.close
