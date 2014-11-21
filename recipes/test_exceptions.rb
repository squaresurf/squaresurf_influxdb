#
# Cookbook Name:: squaresurf_influxdb
# Recipe:: exceptions_test
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
# This is only for ChefSpec tests to test that expected exceptions are raised.
# Not for use otherwise.

# Mock how providers should catch exceptions
def provider_rescue_mock
  yield if block_given?
rescue SquaresurfInfluxDB::Error => e
  e.fail_or_log(@run_context.node)
end

if node.squaresurf_influxdb.check_missing_node
  provider_rescue_mock do
    SquaresurfInfluxDB::ClusterAdmin.client
  end
end

if node.squaresurf_influxdb.check_unknown_port
  node.override.squaresurf_influxdb.config.api.port = false

  # Try and do something now that the code doesn't know how to connect.
  squaresurf_influxdb_database 'testdb'
end

if node.squaresurf_influxdb.check_cluster_admin_delete
  node.override.squaresurf_influxdb.admin_username = 'tester'

  squaresurf_influxdb_cluster_admin 'tester' do
    action :delete
  end
end

if node.squaresurf_influxdb.check_missing_password_cluster_admin_create
  squaresurf_influxdb_cluster_admin 'tester'
end

if node.squaresurf_influxdb.check_missing_password_database_user_create
  squaresurf_influxdb_user 'tester'
end

if node.squaresurf_influxdb.check_set_cluster_admin_as_database_user
  module SquaresurfInfluxDB
    # Set the cluster_admins rather than ask influxdb for the list.
    module ClusterAdmin
      # This helps us test without a valid influxdb connection.
      @cluster_admins = { 'name' => 'tester' }
    end
  end

  node.override.squaresurf_influxdb.admin_username = 'tester'

  squaresurf_influxdb_user 'tester'
end
