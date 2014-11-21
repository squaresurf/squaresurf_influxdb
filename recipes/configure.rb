#
# Cookbook Name:: squaresurf_influxdb
# Recipe:: configure
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

service 'influxdb' do
  supports [:restart, :status]
  action [:enable, :start]
end

%w(config benchmark_config).each do |config|
  toml = SquaresurfInfluxDB::Config.generate_toml(
    node.squaresurf_influxdb[config])

  file "/opt/influxdb/shared/#{config}.toml" do
    action :create
    content toml
    notifies :restart, 'service[influxdb]', :immediately
  end
end

squaresurf_influxdb_cluster_admin node.squaresurf_influxdb.admin_username do
  password node.squaresurf_influxdb.admin_password
end

squaresurf_influxdb_cluster_admin 'root-delete' do
  action :delete
  username 'root'
  only_if { node.squaresurf_influxdb.admin_username != 'root' }
end
