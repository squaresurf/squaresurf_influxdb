#
# Cookbook Name:: squaresurf_influxdb
# Recipe:: test
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
# This is only for kitchen and ChefSpec tests. Not for use otherwise.

package 'curl'

include_recipe 'squaresurf_influxdb::default'

squaresurf_influxdb_database 'testdb'

squaresurf_influxdb_database 'testdb2'
squaresurf_influxdb_database 'testdb2-delete' do
  database 'testdb2'
  action :delete
end

squaresurf_influxdb_database 'testdb3' do
  options spaces: [
    {
      name: 'default',
      retentionPolicy: '30d',
      shardDuration: '7d',
      regEx: '/.*/',
      replicationFactor: 1,
      split: 1
    }
  ]
end

squaresurf_influxdb_cluster_admin 'tester_cluster_admin' do
  password 'tester'
end

squaresurf_influxdb_cluster_admin 'tester_cluster_admin2' do
  password 'tester'
end
squaresurf_influxdb_cluster_admin 'tester_cluster_admin2-delete' do
  username 'tester_cluster_admin2'
  action :delete
end

squaresurf_influxdb_user 'tester_db_user' do
  password 'tester'
  database 'testdb'
end

squaresurf_influxdb_user 'tester_db_user2' do
  password 'tester'
  database 'testdb'
end
squaresurf_influxdb_user 'tester_db_user2-delete' do
  username 'tester_db_user2'
  database 'testdb'
  action :delete
end

squaresurf_influxdb_user 'tester_db_admin' do
  admin true
  password 'tester'
  database 'testdb'
end

squaresurf_influxdb_user 'tester_db_admin2' do
  admin true
  password 'tester'
  database 'testdb'
end
squaresurf_influxdb_user 'tester_db_admin2-delete' do
  username 'tester_db_admin2'
  database 'testdb'
  action :delete
end

squaresurf_influxdb_user 'tester_read_only_user' do
  write_to ' '
  password 'tester'
  database 'testdb'
end

squaresurf_influxdb_user 'tester_read_only_user2' do
  write_to ' '
  password 'tester'
  database 'testdb'
end
squaresurf_influxdb_user 'tester_read_only_user2-delete' do
  username 'tester_read_only_user2'
  database 'testdb'
  action :delete
end

squaresurf_influxdb_user 'tester_write_only_user' do
  read_from ' '
  password 'tester'
  database 'testdb'
end

squaresurf_influxdb_user 'tester_write_only_user2' do
  read_from ' '
  password 'tester'
  database 'testdb'
end
squaresurf_influxdb_user 'tester_write_only_user2-delete' do
  username 'tester_write_only_user2'
  database 'testdb'
  action :delete
end
