#
# Cookbook Name:: squaresurf_influxdb
# Provider:: user
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
    unless @new_resource.password
      SquaresurfInfluxDB::Error.missing_resource_parameter(
        @new_resource, 'password', :create)
    end

    if SquaresurfInfluxDB::ClusterAdmin.exists? @new_resource.username
      SquaresurfInfluxDB::Error.create_database_user_with_cluster_admin(
        @new_resource.username)
    end

    user_exists = SquaresurfInfluxDB::User.exists?(
      @new_resource.database,
      @new_resource.username)

    if user_exists
      props_not_merged = SquaresurfInfluxDB::User.props_not_matching(
        @new_resource.database,
        @new_resource.username,
        @new_resource.password,
        'admin' => @new_resource.admin,
        'readFrom' => @new_resource.read_from,
        'writeTo' => @new_resource.write_to)
    end

    if user_exists && props_not_merged.empty?
      Chef::Log.info(
        "#{@new_resource} has nothing to do for #{@new_resource.username}")
    else
      if !user_exists
        msg = "#{@new_resource} create #{@new_resource.username}"
      else
        msg = "#{@new_resource} converge props: "\
          "(#{props_not_merged.join(', ')})"
      end

      converge_by(msg) do
        SquaresurfInfluxDB::User.create(
          @new_resource.database,
          @new_resource.username,
          @new_resource.password,
          'admin' => @new_resource.admin,
          'readFrom' => @new_resource.read_from,
          'writeTo' => @new_resource.write_to)
      end
    end
  rescue SquaresurfInfluxDB::Error => e
    e.fail_or_log(@run_context.node)
  end
end

action :delete do
  begin
    if SquaresurfInfluxDB::User.exists?(
      @new_resource.database,
      @new_resource.username
    )
      converge_by("Delete #{@new_resource.username}") do
        SquaresurfInfluxDB::User.delete(
          @new_resource.database,
          @new_resource.username)
      end
    else
      Chef::Log.info("#{@new_resource} has nothing to do to "\
                     "delete #{@new_resource.username}")
    end
  rescue SquaresurfInfluxDB::Error => e
    e.fail_or_log(@run_context.node)
  end
end
