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

require_relative 'influxdb_dependencies'

# This module holds the logic for SquaresurfInfluxDB to interact with and
# configure InfluxDB via the chef LWRPs.
module SquaresurfInfluxDB
  @node = nil

  def self.node(node = nil)
    @node = node if node

    SquaresurfInfluxDB::Error.missing_node if @node.nil?
    @node
  end

  def self.port(key)
    api_config = node.squaresurf_influxdb.config.api.to_hash
    if api_config.key?(key) && api_config[key]
      return api_config.key(key)
    else
      SquaresurfInfluxDB::Error.unknown_port
    end
  end

  def self.port_and_ssl_hash
    use_ssl = node.squaresurf_influxdb.client_use_ssl
    if use_ssl
      return { port: port('ssl-port'), use_ssl: true }
    else
      return { port: port('port'), use_ssl: false }
    end
  end

  def self.client_opts(username, password)
    port_and_ssl_hash.merge(
      hosts: node.squaresurf_influxdb.client_hosts,
      retry: node.squaresurf_influxdb.client_retries,
      username: username,
      password: password
    )
  end

  def self.get_client(username, password, database = nil)
    client = InfluxDB::Client.new(client_opts(username, password))

    # Authenticate client.
    if database
      client.authenticate_database_user database
    else
      client.authenticate_cluster_admin
    end

    client
  end

  # A module for raising or logging errors.
  class Error < StandardError
    def fail_or_log(node)
      if node.squaresurf_influxdb.fail_on_error
        fail self
      else
        Chef::Log.error(to_s)
      end
    end

    def self.cluster_admin_cannot_connect
      fail self, "We can't connect to influxdb with the cluster admin "\
        'credentials set. Are you sure that you have the correct cluster '\
        'admin username and password set?'
    end

    def self.missing_node
      # We can't check the attributes to know if we should log instead of fail.
      fail self, "We can't connect to influxdb and configure it if we don't "\
        'have the node attributes.'
    end

    def self.unknown_port
      fail self, "We couldn't determine the port to connect to influxdb with."
    end

    def self.delete_main_cluster_admin_attempt(user)
      fail self, 'You cannot delete the main admin for us to connect to '\
        "influxdb with. If you would like to delete #{user}, then please set "\
        'another cluster admin credentials in the node attributes '\
        'node.squaresurf_influxdb.admin_username and '\
        'node.squaresurf_influxdb.admin_password.'
    end

    def self.create_database_user_with_cluster_admin(user)
      fail self, "You cannot set #{user} to be a database user."
    end

    def self.missing_resource_parameter(resource, param, action)
      fail self, "#{resource} requires a #{param} for action: #{action}"
    end
  end

  # influxdb config methods
  module Config
    def self.generate_toml(node)
      TOML::Generator.new(node.to_hash).body
    end
  end

  # influxdb database methods
  module Database
    @databases = nil

    def self.list
      @databases ||= SquaresurfInfluxDB::ClusterAdmin.client.get_database_list
    end

    def self.exists?(database)
      list.each do |db|
        return true if database == db['name']
      end

      false
    end

    def self.create(database, options)
      SquaresurfInfluxDB::ClusterAdmin.client.create_database(database, options)
      @databases.push('name' => database)
    end

    def self.delete(database)
      SquaresurfInfluxDB::ClusterAdmin.client.delete_database(database)
      @databases.delete_if { |db| db['name'] == database }
    end
  end

  # influxdb ClusterAdmin methods
  module ClusterAdmin
    @client = nil
    @cluster_admins = nil

    def self.node(run_context = nil)
      @node = run_context.node if run_context

      SquaresurfInfluxDB::Error.missing_node if @node.nil?

      @node
    end

    # Potential admin usernames to try initally in order of liklihood.
    def self.potential_users
      [
        SquaresurfInfluxDB.node.squaresurf_influxdb.admin_username,
        SquaresurfInfluxDB.node.squaresurf_influxdb.admin_old_username,
        'root'
      ]
    end

    # Potential admin passwords to try initally in order of liklihood.
    def self.potential_passes
      [
        SquaresurfInfluxDB.node.squaresurf_influxdb.admin_password,
        SquaresurfInfluxDB.node.squaresurf_influxdb.admin_old_password,
        'root'
      ]
    end

    def self.init_client(user, pass)
      SquaresurfInfluxDB.get_client(user, pass)
    rescue InfluxDB::AuthenticationError
      false
    end

    # The main cluster admin client.
    def self.client
      return @client if @client

      potential_users.product(potential_passes) do |user, pass|
        @client = init_client(user, pass)
        break if @client
      end

      SquaresurfInfluxDB::Error.cluster_admin_cannot_connect unless @client

      @client
    end

    def self.list
      @cluster_admins ||= client.get_cluster_admin_list
    end

    def self.exists?(username)
      list.each do |user|
        return true if username == user['name']
      end

      false
    end

    def self.password?(username, password)
      SquaresurfInfluxDB.get_client(username, password)
      return true
    rescue InfluxDB::AuthenticationError
      return false
    end

    def self.create(user, pass)
      if self.exists?(user)
        SquaresurfInfluxDB::ClusterAdmin.client.update_cluster_admin(user, pass)
      else
        SquaresurfInfluxDB::ClusterAdmin.client.create_cluster_admin(user, pass)
        @cluster_admins.push('name' => user)
      end

      if user == SquaresurfInfluxDB.node.squaresurf_influxdb.admin_username
        @client = SquaresurfInfluxDB.get_client(user, pass)
      end
    end

    def self.delete(user)
      SquaresurfInfluxDB::ClusterAdmin.client.delete_cluster_admin(user)
    end
  end

  # influxdb database user methods
  module User
    @users = {}

    def self.list(database)
      @users[database] ||=
        SquaresurfInfluxDB::ClusterAdmin.client.get_database_user_list(database)
    end

    def self.exists?(database, username)
      list(database).each do |user|
        return true if username == user['name']
      end

      false
    end

    def self.password?(database, username, password)
      SquaresurfInfluxDB.get_client(username, password, database)
      return true
    rescue InfluxDB::AuthenticationError
      return false
    end

    def self.props_not_matching(database, username, password, props = {})
      props_not_matching = []

      unless self.password?(database, username, password)
        props_not_matching.push 'password'
      end

      SquaresurfInfluxDB::ClusterAdmin.client
        .get_database_user_info(database, username).each do |key, value|
        props_not_matching.push key if props.key?(key) && props[key] != value
      end

      props_not_matching
    end

    def self.create(database, username, password, opts = {})
      unless self.exists?(database, username)
        SquaresurfInfluxDB::ClusterAdmin
          .client.create_database_user(database, username, password)
        @users[database].push('name' => username)
      end

      SquaresurfInfluxDB::ClusterAdmin
        .client.update_database_user(
          database, username, opts.merge(password: password))
    end

    def self.delete(database, username)
      SquaresurfInfluxDB::ClusterAdmin
        .client.delete_database_user(database, username)
    end
  end
end
