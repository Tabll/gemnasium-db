#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'

def search_files(dir, pattern, base_only = true)
  Dir[File.join(dir, '**', pattern)].map { |file| base_only ? File.basename(file) : file }.sort
end

def generate_package_hash(slug)
  slug.gsub('-', '_').downcase
end

def validate_unique_names(dir)
  ret = true
  grouped_slugs = {}

  # group package slugs by type
  search_files(dir, '*.yml', false).each do |f|
    dict = YAML.safe_load(File.read(f))
    if dict.nil?
      puts "invalid YAML file #{f}"
      ret = false
      next
    end

    slug = dict['package_slug']
    package_type = slug.split('/').first

    grouped_slugs[package_type] = {} unless grouped_slugs.key?(package_type)
    grouped_slugs[package_type][slug] = true unless grouped_slugs[package_type].key?(package_type)
  end

  clashes = []
  # check for clashes
  grouped_slugs.each do |typ, slugs|
    seen = {}
    case typ
    when 'pypi', 'gem', 'nuget', 'go', 'swift'
      slugs.each do |slug, _|
        hashed_slug = generate_package_hash(slug)

        unless seen.key?(hashed_slug)
          seen[hashed_slug] = [slug]
          next
        end

        seen[hashed_slug] << slug
      end

      clashes += seen.filter { |_, pslugs| pslugs.size > 1 }.map { |_, pslugs| pslugs }
    else
      puts "skip #{typ} because it is case sensitive"
    end
  end

  clashes
end

if ARGV.size != 1
  puts 'usage: ./naming.rb <dir>'
  exit(1)
end

searchdir = ARGV[0]

exit(1) unless Dir.exist?(searchdir)

clashes = validate_unique_names(searchdir)
if clashes.empty?
  puts 'No clashes detected'
  exit(0)
end

clashes.each do |clash_set|
  puts "Clashing package slugs: #{clash_set.join(',')}"
end

exit(1)
