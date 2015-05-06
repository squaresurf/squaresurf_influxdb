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

# Install necessary gems.
{
  'toml' => '0.1.2',
  'influxdb' => '0.1.8'
}.each do |gem, version|
  gem_version = Gem::Requirement.create version
  installed = Gem::Specification.each.any? do |spec|
    gem == spec.name && gem_version.satisfied_by?(spec.version)
  end

  Gem::DependencyInstaller.new.install gem, gem_version unless installed

  require gem
end

# Monkey patch for InfluxDB::Client authentication methods. This monkey patch
# won't be necessary if the following PRs are merged and the gem is published.
# * https://github.com/influxdb/influxdb-ruby/pull/64
# * https://github.com/influxdb/influxdb-ruby/pull/85
module InfluxDB
  # The client class
  class Client
    def authenticate_cluster_admin
      get(full_url('/cluster_admins/authenticate'), true)
    end

    def authenticate_database_user(database)
      get(full_url("/db/#{database}/authenticate"), true)
    end

    def get_return_success(response, return_response)
      if return_response
        return response
      else
        return JSON.parse(response.body)
      end
    end

    def get(url, return_response = false)
      connect_with_retry do |http|
        response = http.request(Net::HTTP::Get.new(url))
        if response.is_a? Net::HTTPSuccess
          return get_return_success response, return_response
        elsif response.is_a? Net::HTTPUnauthorized
          fail InfluxDB::AuthenticationError.new, response.body
        else
          fail InfluxDB::Error.new, response.body
        end
      end
    end

    def create_database(name, options = {})
      url = full_url("/cluster/database_configs/#{name}")
      data = JSON.generate(options)
      post(url, data)
    end
  end
end
