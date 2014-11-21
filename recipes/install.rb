#
# Cookbook Name:: squaresurf_influxdb
# Recipe:: install
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

arch = node.kernel.machine
arch = 'amd64' if arch == 'x86_64'
influxdb_deb = 'http://s3.amazonaws.com/influxdb/influxdb_'\
  "#{node.squaresurf_influxdb.version}_#{arch}.deb"

if node.squaresurf_influxdb.update_version
  deb_action = :create
else
  deb_action = :create_if_missing
end

remote_file '/opt/influxdb.deb' do
  source influxdb_deb
  action deb_action
end

dpkg_package 'influxdb' do
  action :install
  source '/opt/influxdb.deb'
end
