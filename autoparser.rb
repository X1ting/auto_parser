require 'open-uri'
require 'nokogiri'
require 'json'
fname = "marks_json.txt"

somefile = File.open(fname, "w")
url_start = 'https://auto.ru'
html = open(url_start)
doc = Nokogiri::HTML(html)
start_time = Time.now
hash = {}

doc.css('.mmm__item').each do |marka|
  key = marka.children.first.children.first.text
  value = marka.children.first["href"]
  hash["#{key}"] = value
end

count = hash.count
puts "Count of model = #{count}"
resulted_hash = {}

hash.each_with_index do |h, index|
  key, value = h
  index += 1
  puts "Parsed #{index} model, called #{key.capitalize}, remaining #{count - index} models"
  url = "https:#{value}"
  html = open(url)
  doc = Nokogiri::HTML(html)
  models_array = []
  doc.css('.mmm__item').each do |model|
    models_array.push(model.children.first.text)
  end

  resulted_hash["#{key}"] =  models_array.uniq
end

somefile.puts resulted_hash.to_json
puts "Parsed for #{(Time.now - start_time).round} seconds"
somefile.close
