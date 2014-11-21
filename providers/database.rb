#
# Cookbook Name:: squaresurf_influxdb
# Provider:: config
#
# Copyright 2014, Daniel Paul Searles
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

def initialize(new_resource, run_context)
  super
  SquaresurfInfluxDB.node(run_context.node)
end

def whyrun_supported?
  true
end

action :create do
  begin
    if SquaresurfInfluxDB::Database.exists?(@new_resource.database)
      Chef::Log.info("#{@new_resource.database} already exists so there is "\
                     "nothing for #{@new_resource} to do to create it.")
    else
      converge_by("Create #{@new_resource.database}") do
        SquaresurfInfluxDB::Database.create(@new_resource.database)
      end
    end
  rescue SquaresurfInfluxDB::Error => e
    e.fail_or_log(@run_context.node)
  end
end

action :delete do
  begin
    if !SquaresurfInfluxDB::Database.exists?(@new_resource.database)
      Chef::Log.info("#{@new_resource.database} doesn't exist so there is "\
                     "nothing for #{@new_resource} to do to delete it.")
    else
      converge_by("Delete #{@new_resource.database}") do
        SquaresurfInfluxDB::Database.delete(@new_resource.database)
      end
    end
  rescue SquaresurfInfluxDB::Error => e
    e.fail_or_log(@run_context.node)
  end
end
