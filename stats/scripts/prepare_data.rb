#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'csv'
require 'git'
require 'time'
require 'open-uri'

def download_file(url, file)
  open(file, 'wb') do |file|
    file << open(url).read
  end
end

unless ARGV.size == 2
  puts 'usage ./prepare_data.rb <path-to-gemnasium-db> <outdir>'
  exit(1)
end

unless ARGV.reject { |arg| Dir.exist?(arg) }.empty?
  puts "#{ARGV[0]} does not exist"
  exit(1)
end

repo = ARGV[0]
outdir = ARGV[1]

rows = []
rows << %w[file pubdate mergedate delta packagetype]
# compute statistics about creation dates/times
Dir.chdir(repo) do
  g = Git.open('.')
  Dir.glob('**/*.yml').each do |file|
    # we can load the file safely, because we have schema validation
    yaml_dict = YAML.load_file(file)
    identifier = File.join(yaml_dict['package_slug'], yaml_dict['identifier'])
    next unless yaml_dict.key?('date')

    first_sha = g.log.object(file).last
    advisory_merge_date = first_sha.date.strftime('%Y-%m-%d').to_s
    # we extract the first observed date entry here
    # because this is the close approximation we can get to the date on which
    # the CVE was first made available on NVD
    first_content = g.show(first_sha, file).to_s

    begin
      # in the past we did not have schema validators, so this could go wrong for
      # advisories that were added in the non-recent past
      advisory_first = YAML.safe_load(first_content)
    rescue StandardError => _e
      advisory_first = {}
    end

    # use pubdate as a fallback as it is more conservative
    cve_creation_date = advisory_first.key?('date') ? advisory_first['date'].to_s : yaml_dict['pubdate'].to_s
    delta = ((Time.parse(advisory_merge_date.strip) - Time.parse(cve_creation_date.strip)) / (3600 * 24)).round
    rows << [identifier, cve_creation_date, advisory_merge_date, delta, yaml_dict['package_slug'].split('/').first]
  end
end

File.write(File.join(outdir, 'data.csv'), rows.map(&:to_csv).join)

# download nvd data
file_id = '1gN-p-nB_BoqZ48T79llGI3p-Lg1biO6Q'
download_file("https://docs.google.com/uc?export=download&id=#{file_id}", File.join(outdir, 'nvd.csv'))
