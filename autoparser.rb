require 'open-uri'
require 'nokogiri'
require 'json'

class AutoParser
  attr_reader :filename, :url, :results, :start_time,
    :marks_data, :models

  def initialize(args = {})
    @filename = args[:filename]
    @url = args[:url]
    @results = {}
  end

  def do_parse
    parse_marks
    parse_models
    write_to_file
  end

  private
  def parse_marks
    doc = nokogiri_object
    @start_time = Time.now

    @marks_data = doc.css('.mmm__item').inject({}) do |hash, marka|
      hash[marka.children.first.children.first.text] = marka.children.first['href']; hash
    end

    puts "Count of model = #{marks_data.count}"
  end

  def parse_models
    marks_data.to_enum.with_index(1).each do |mark, index|
      key, value = mark
      doc = nokogiri_object("https:#{value}")
      puts "Parsed #{index} model, called #{key.capitalize}, remaining #{marks_data.count - index} models"

      models = doc.css('.mmm__item').inject([]) do |array, model|
        array << model.children.first.text; array
      end

      @results[key] = models
    end

    puts "Parsed for #{(Time.now - start_time).round} seconds"
  end

  def write_to_file
    file_descriptor = File.open(filename, 'w')
    file_descriptor.puts results.to_json
    file_descriptor.close
  end

  def nokogiri_object(url = @url)
    Nokogiri::HTML(open(url))
  end
end

AutoParser.new(filename: 'result.json', url: 'https://auto.ru').do_parse
