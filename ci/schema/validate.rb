#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'json'
require 'json-schema'
require 'optparse'
require 'semver_dialects'

current_dir = File.dirname(__FILE__)
schema_file = File.join(current_dir, 'schema.json')
$schema = JSON.parse(File.read(schema_file))
$uuids = []

def validate_semantics(yaml_dict)
  errors = validate_mutually_exclusive_versions(yaml_dict)
  errors += validate_inclusive_language(yaml_dict)
  errors += validate_description(yaml_dict)
  errors
end

# iterate through each text block within `data` that is not contained between
# two backticks

# Examples:
# "The vulnerable parameter `blacklist_param` exists" =>
#     ["The vulnerable parameter ", " exists"]
#
# "The vulnerable parameter blacklist_param exists" =>
#     ["The vulnerable parameter blacklist_param exists"]
def _iter_non_inline_code_text(data)
  code = false
  data.split('`').each do |chunk|
    yield chunk unless code
    code = !code
  end
end

# If a denied word must be used, it must be a technical term and surrounded
# by backticks
def validate_inclusive_language(yaml_dict)
  errors = []

  denied_words = %w[blacklist whitelist]

  fields = %w[title description]

  fields.each do |field_name|
    text = yaml_dict[field_name]
    _iter_non_inline_code_text(text) do |text_block|
      denied_words.each do |denied_word|
        if text_block.include?(denied_word)
          errors.push("Field #{field_name} uses non-inclusive term #{denied_word.inspect} in plaintext block")
        end
      end
    end
  end

  errors
end

def validate_description(yaml_dict)
  errors = []
  if yaml_dict['title'].include?('TODO')
    errors << 'Incomplete title field.'
  end
  errors
end

def validate_mutually_exclusive_versions(yaml_dict)
  errors = []

  raw_fixed = (yaml_dict['fixed_versions'] || []).map(&:to_s)
  raw_affected = yaml_dict['affected_range']
  # e.g. maven/org.apache.thrift/ABCD
  package_type_str = yaml_dict['package_slug'].split('/').first

  unless %w[maven nuget].include?(package_type_str)
    valid_range = /^[><=]{1,2} *[\w\.\-]+ *,? *([><=]{1,2} *[\w\.\-]+)*$/
    raw_affected.strip.split('||').each do |ran|
      range = ran.gsub(/[\s\u00A0]/, '')
      if !range.match?(valid_range)
        errors << "malformed version range #{range}"
        return errors
      end
    end
  end

  raw_fixed.each do |raw_fixed_str|
    begin
      sat = SemverDialects::VersionChecker.version_sat?(package_type_str == "swift" ? "npm" : package_type_str, raw_fixed_str, raw_affected)
      if sat
        errors << "Fixed version #{raw_fixed_str} may be also be affected (#{raw_affected})"
      end
    rescue SemverDialects::InvalidVersionError => e
      # conan does not enforce semver compatibility
      errors << e.message unless package_type_str == 'conan'
    end
  end

  errors
end

def validation_errors(yaml_file, semantic = false)
  errors = []
  begin
    yaml_dict = YAML.load_file(yaml_file)
    errors = JSON::Validator.fully_validate($schema, yaml_dict.to_json)
    # validate whether path to avisory is consistent with package slug
    target_file = "#{File.join(yaml_dict['package_slug'], yaml_dict['identifier'])}.yml"
    unless yaml_file == target_file
      errors << "detected inconsistencies between package slug and file for #{yaml_file}"
    end

    if $uuids.include?(yaml_dict['uuid'])
      errors << "uuid duplicate detected #{yaml_dict['uuid']}"
      return err
    else
      $uuids << yaml_dict['uuid']
    end

    errors += validate_semantics(yaml_dict) if semantic
  rescue StandardError => e
    errors << e.message
  end
  errors
end

def obtain_yaml_files(path)
  File.directory?(path) ? Dir.glob("#{path}/**/*.yml") : [path]
end

options = {
  semantic: false
}
optparse = OptionParser.new do |opts|
  opts.banner = "#{$PROGRAM_NAME} [-s] <path0> <path1> ... <pathN>"

  opts.on('-s', '--semantic', 'Include semantic tests. Requires advisory-db-curation-tools')
  opts.on('-h', '--help', 'Print this help') do
    puts opts
    puts "\nPath can be a yaml file and/or a directory"
    exit(1)
  end
end
optparse.parse!(into: options)

if ARGV.empty?
  puts "At least one file/directory is required\n"
  puts optparse.help
  exit(1)
end

# ensure all provided paths exist
if ARGV.reject { |path| File.exist?(path) }.any?
  puts "Not all provided paths exist\n\n"
  puts optparse.help
  exit(1)
end

num_errors = 0
ARGV.flat_map { |path| obtain_yaml_files(path) }.each do |yaml_file|
  next if %w[unknown].include?(File.basename(yaml_file, '.yml'))

  errors = validation_errors(yaml_file, semantic = options[:semantic])
  next unless errors.any?

  num_errors += errors.length
  puts "#{yaml_file} is invalid:"
  errors.each do |error|
    puts "    - #{error}"
  end
end

if num_errors.positive?
  puts "\n\n#{num_errors} were detected"
  exit(1)
end

puts 'All yaml files are valid'
exit(0)
