#!/usr/bin/env ruby

require 'awesome_print'
require 'toml'

unless ARGV.length == 2
  print "Usage: #{__FILE__} /path/to/file.toml attr_name\n"
  exit 1
end

toml = ARGV[0]
attr_name = ARGV[1]

unless File.exist?(toml)
  print "#{toml} does not exist!\n"
  exit 2
end

hash = TOML.load_file(toml)

print "default.squaresurf_influxdb.#{attr_name} = "
ap hash, plain: true, index: false
