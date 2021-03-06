#
# Cookbook Name:: squaresurf_influxdb
# ChefSpec:: matchers
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

if defined?(ChefSpec)
  def create_if_missing_remote_file(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      'remote_file',
      :create_if_missing,
      resource_name)
  end

  def create_squaresurf_influxdb_database(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      'squaresurf_influxdb_database',
      :create,
      resource_name)
  end

  def delete_squaresurf_influxdb_database(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      'squaresurf_influxdb_database',
      :delete,
      resource_name)
  end

  def create_squaresurf_influxdb_cluster_admin(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      'squaresurf_influxdb_cluster_admin',
      :create,
      resource_name)
  end

  def delete_squaresurf_influxdb_cluster_admin(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      'squaresurf_influxdb_cluster_admin',
      :delete,
      resource_name)
  end

  def create_squaresurf_influxdb_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      'squaresurf_influxdb_user',
      :create,
      resource_name)
  end

  def delete_squaresurf_influxdb_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      'squaresurf_influxdb_user',
      :delete,
      resource_name)
  end

end
