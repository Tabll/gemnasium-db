#!/usr/bin/env ruby
# frozen_string_literal: true

require 'sqlite3'
require 'csv'

unless ARGV.size == 2
  puts 'usage ./nvd-stats <path-to-nvd-mirror-db> <csvfile>'
  exit(1)
end

dbpath = ARGV[0]
csvfile = ARGV[1]

unless File.exist?(dbpath)
  puts "#{dbpath} does not exist"
  exit(1)
end

CSV.open(csvfile,'a') do |csvfile|
  SQLite3::Database.new( dbpath ) do |db|
    db.execute("SELECT year, size  from feeds where year not like 'recent' ORDER BY year ASC") do |row|
      csvfile << row
    end
  end
end
