#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'yaml'
require 'set'

def search_files(dir, pattern, base_only = true)
  Dir[File.join(dir, '**', pattern)].map { |file| base_only ? File.basename(file) : file }.sort
end

def strip_count(fname)
  File.basename(fname, File.extname(fname)).split('-')[2]
end

def invalidated_range(slug)
  case slug
  when 'maven', 'nuget'
    return '(,0)'
  when 'pypi', 'packagist', 'conan', 'gem', 'npm', 'go', 'swift'
    return '<0'
  end
  ''
end

def validate_unique_identifiers(dir)
  ret = true
  ids2file = {}

  search_files(dir, '*.yml', false).each do |f|
    dict = YAML.safe_load(File.read(f))
    if dict.nil?
      puts "invalid YAML file #{f}"
      ret = false
      next
    end

    package_type = dict['package_slug'].split('/').first
    # ignore files that are already invalidated
    invalidated = invalidated_range(package_type)
    next if dict['affected_range'] == invalidated

    dict['identifiers'].each do |id|
      next unless id.start_with?('CVE')

      ids2file[id] = [] unless ids2file.key?(id)
      ids2file[id] << f
    end
  end

  duplicates = ids2file.transform_values { |files| files.group_by { |f| File.dirname(f) } }

  duplicates.each do |_, slugs|
    slugs.each do |slug, files|
      if files.count > 1
        puts "duplicate for #{slug}: #{files.join(',')}"
        ret = false
      end
    end
  end

  ret
end

def validate_identifiers(dir)
  return false unless search_files(dir, 'GMS*.yml').reject { |fil| fil.match?(/GMS-\d{4}-\d+/) }.empty?

  ret = true
  lookup = {}
  search_files(dir, 'GMS*.yml', false).each do |f|
    dict = YAML.safe_load(File.read(f))
    slug = dict['package_slug']

    dict['identifiers'].each do |id|
      lookup[slug] = Set.new unless lookup.key?(slug)
      if lookup[slug].include?(id)
        puts "#{id} already present for #{slug}"
        ret = false
      end
      lookup[slug] << id
    end
  end
  ret
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
  exit(1) unless validate_unique_identifiers(searchdir)
  puts 'All identifiers are ok'
end

exit(0)
