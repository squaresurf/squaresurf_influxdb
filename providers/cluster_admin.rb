#
# Cookbook Name:: squaresurf_influxdb
# Provider:: cluster_admin
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

    user_exists = SquaresurfInfluxDB::ClusterAdmin.exists?(
      @new_resource.username)
    pass_correct = SquaresurfInfluxDB::ClusterAdmin.password?(
      @new_resource.username, @new_resource.password)

    if user_exists && pass_correct
      Chef::Log.info("#{@new_resource} has nothing to do to create "\
                     + @new_resource.username)
    else
      if user_exists
        msg = "Update #{@new_resource.username} password"
      else
        msg = "Create #{@new_resource.username}"
      end

      converge_by(msg) do
        SquaresurfInfluxDB::ClusterAdmin.create(
          @new_resource.username, @new_resource.password)
      end
    end
  rescue SquaresurfInfluxDB::Error => e
    e.fail_or_log(@run_context.node)
  end
end

action :delete do
  begin
    admin_username = @run_context.node.squaresurf_influxdb.admin_username
    if @new_resource.username == admin_username
      SquaresurfInfluxDB::Error.delete_main_cluster_admin_attempt(
        @new_resource.username)
    end

    if SquaresurfInfluxDB::ClusterAdmin.exists?(@new_resource.username)
      converge_by("Delete #{@new_resource.username}") do
        SquaresurfInfluxDB::ClusterAdmin.delete(@new_resource.username)
      end
    else
      Chef::Log.info("#{@new_resource} has nothing to do to delete "\
                     + @new_resource.username)
    end
  rescue SquaresurfInfluxDB::Error => e
    e.fail_or_log(@run_context.node)
  end
end
