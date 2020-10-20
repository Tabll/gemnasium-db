#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'

unless ARGV.size == 1
  puts 'usage ./exctract_description.rb <file>'
  exit(1)
end

filename = ARGV[0]

unless File.exist?(filename)
  puts "#{filename} does not exist"
  exit(0)
end

unless File.extname(filename) == '.yml'
  exit(0)
end

file = File.absolute_path(filename, '.')

dict = {}
begin
  dict = YAML.load_file(file)
rescue StandardError
  puts "#{file} is not a valid YAML file"
  exit(1)
end

unless dict.key?('description')
  puts "#{file} does not have a description field"
  exit(1)
end

puts dict['description']

exit(0)
