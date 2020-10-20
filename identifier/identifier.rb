#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def search_files(dir, pattern)
  Dir[File.join(dir, '**', pattern)].map { |file| File.basename(file) }.sort
end

def strip_count(fname)
  File.basename(fname, File.extname(fname)).split('-')[2]
end

def validate_identifiers(dir)
  base = search_files(dir, 'GMS*.yml').group_by { |file| file }
  duplicate_filter = base.filter { |_, v| v.count != 1 }.first

  unless duplicate_filter.nil?
    puts "There is a duplicate identifier: #{duplicate_filter.first}"
    return false
  end

  true
end

def generate_new_identifier(dir, year)
  file_list = search_files(dir, "GMS-#{year}-*").to_a
  return "GMS-#{year}-1" if file_list.empty?

  latest_file = file_list.max_by { |file| strip_count(file).to_i }
  latest = strip_count(latest_file)

  "GMS-#{year}-#{latest.to_i + 1}"
end

banner = 'Usage: identifier.rb (-v <path> | -n <path> <year>)'

options = {}
OptionParser.new do |opts|
  opts.on('-v', '--validate', 'validate whether identifiers are unique') do |v|
    options[:validate] = v
  end
  opts.on('-n', '--new', 'obtain a new identifier') do |v|
    options[:new] = v
  end
end.parse!

if options[:validate] == true && ARGV.size != 1
  puts banner
  exit(1)
end

if options[:new] == true && ARGV.size != 2
  puts banner
  exit(1)
end

searchdir = ARGV[0]

unless Dir.exist?(searchdir)
  puts "directory '#{searchdir}' does not exist"
  exit 1
end

if options[:new]
  year = ARGV[1]
  unless year.match?(/^\d{4,4}$/)
    puts "year #{year} is invalid"
    exit(1)
  end
  puts generate_new_identifier(searchdir, year)
elsif options[:validate]
  exit(1) unless validate_identifiers(searchdir)
  puts "No duplicate 'GMS' identifiers found"
end

exit(0)
