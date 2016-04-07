require 'open-uri'
require 'nokogiri'
require 'json'

class AutoParser
  attr_reader :filename, :url, :results, :start_time,
    :marks, :models

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
    doc = Nokogiri::HTML(open(url))
    @start_time = Time.now

    {}.tap do |hash|
      doc.css('.mmm__item').each do |marka|
        key = marka.children.first.children.first.text
        value = marka.children.first["href"]

        hash[key] = value
      end

      @marks = hash
    end

    puts "Count of model = #{marks.count}"
  end

  def parse_models
    marks.each_with_index do |mark, index|
      key, value = mark
      index += 1
      puts "Parsed #{index} model, called #{key.capitalize}, remaining #{marks.count - index} models"
      @url = "https:#{value}"
      doc = Nokogiri::HTML(open(url))

      [].tap do |models|
        doc.css('.mmm__item').each do |model|
          models << model.children.first.text
        end

        @results[key] = models
      end
    end

    puts "Parsed for #{(Time.now - start_time).round} seconds"
  end

  def write_to_file
    file_descriptor = File.open(filename, 'w')
    file_descriptor.puts results.to_json
    file_descriptor.close
  end
end

AutoParser.new(filename: 'result.json', url: 'https://auto.ru').do_parse
