:warning: NOT CURRENTLY MAINTAINED :warning:

Open an issue if you would like to take over maintenance of this repo.

SquareSurf InfluxDB Cookbook
===========================

[Chef](https://www.getchef.com/chef/) cookbook for installing and configuring
[InfluxDB](http://influxdb.com/). This cookbook took inspiration from the
[influxdb cookbook](https://supermarket.getchef.com/cookbooks/influxdb). The
main difference is that this cookbook tries to take the approach that
[InfluxDB](http://influxdb.com/) should be always running once it is installed.
Whereas my understanding of the [influxdb
cookbook](https://supermarket.getchef.com/cookbooks/influxdb) is that it tries
to seperate configuration from starting the service into two processes.

Requirements
------------

* Chef version 0.11 or higher
* Ruby 1.9 (preferably from the Chef full-stack installer)

### Tested Platforms

* Ubuntu 14.04

Note: I'm open to more platforms, this is just what I started with in order to
fill my current need.

Resources
---------

### squaresurf\_influxdb\_user

Use the *squaresurf\_influxdb\_user* resource to create/update/delete an
InfluxDB database user.

#### Actions

* `:create` (Default)
* `:delete`

#### Attributes

* `username`  - Name for the user. (Defaults to the name of the block)
* `password`  - Password for the user.
* `database`  - The database the user will have access to.
* `admin`     - A bool whether or not the user is a database admin. (default: false)
* `read_from` - A regex to match the series the user can read from. (default: '.\*')
* `write_to`  - A regex to match the series the user can write to. (default: '.\*')

#### Examples

##### Create a user

```ruby 
squaresurf_influxdb_user 'john' do
  action :create
  password 'super secret'
  database 'metrics'
  admin true
  read_from '/^public$/'
  write_to '/^john_workspace$/'
end
```

##### Delete a user

```ruby
squaresurf_infludb_user 'old_user' do
  action :delete
  database 'sensitive data'
end
```

### squaresurf\_influxdb\_cluster\_admin

Use the *squaresurf\_influxdb\_cluster\_admin* resource to create/update/delete
an InfluxDB cluster admin.

#### Actions

* `:create` (Default)
* `:delete`

#### Attributes

* `username` - Name for the cluster admin. (Defaults to the name of the block)
* `password` - Password for the cluster admin.

#### Examples

##### Create a cluster admin

```ruby 
squaresurf_influxdb_cluster_admin 'jane' do
  action :create
  password 'super secret again'
end
```

##### Delete a cluster admin

```ruby
squaresurf_infludb_cluster_admin 'old_cluster_admin' do
  action :delete
end
```

### squaresurf\_influxdb\_database

Use the *squaresurf\_influxdb\_database* resource to create/update/delete an
InfluxDB database.

#### Actions

* `:create` (Default)
* `:delete`

#### Attributes

* `database` - Database name. (Defaults to the name of the block)
* `options`  - An extra hash of options to send to the create api.

#### Examples

##### Create a database

```ruby 
squaresurf_influxdb_database 'metrics'
```

##### Create a database with a 30 day retention policy

```ruby
squaresurf_influxdb_database 'metrics' do
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
```

##### Delete a database

```ruby
squaresurf_infludb_database 'old_project_name' do
  action :delete
end
```

Recipes
-------

### squaresurf\_influxdb::default

This recipe includes the *squaresurf\_influxdb::install* recipe then the
*squaresurf\_influxdb::configure* recipe.

### squaresurf\_influxdb::install

This recipe will download the appropriate package according to the version
attribute and install it.

### squaresurf\_influxdb::configure

This recipe will:
* Setup the influxdb service to be enabled and start.
* Write out to toml the config and benchmark\_config from the node attributes.
* Update the main cluster admin password if it has changed.
* Create an alternate cluster admin user if the main admin username is
  different than *root*
* Delete the root user if the main cluster admin username is different than *root*

### squaresurf\_influxdb::test

This is used by our chef spec and kitchen test suites.

### squaresurf\_influxdb::test\_exceptions

This is used by our chef spec test suite.

Attributes
----------

### General Attributes

Attributes that will affect general cookbook usage.

#### default.squaresurf\_influxdb.fail\_on\_error = true

If set to false then failures will not fail the chef run and will log errors
instead.

### Install attributes

Attributes that affect the installation of InfluxDB.

#### default.squaresurf\_influxdb.version = :latest

This will decide which version of InfluxDB to download and install. It can
either be the version string or the ruby symbol `:latest` in order to install
the latest available.

#### default.squaresurf\_influxdb.update\_version = false

This will decide whether or not to install a new version of influxdb if it is
already installed and the version attribute above differs from that of the
installed version.

### InfluxDB Client Attributes

Attributes that affect the ability for this cookbook to connect to InfluxDB in
order to configure users, cluster admins, and databases.

#### default.squaresurf\_influxdb.client\_retries = 10

This is how many times we should try to connect to InfluxDB before giving up.
Set this to nil or '-1' to retry indefinitely.

#### default.squaresurf\_influxdb.client\_hosts = ['localhost']

This is the host we should connect to InfluxDB with.

#### default.squaresurf\_influxdb.client\_use\_ssl = false

Whether or not we should connect via ssl with our client when configuring
users, cluster admins, and databases.

#### default.squaresurf\_influxdb.admin\_username = 'root'

The cluster admin username to use when connecting to InfluxDB.

#### default.squaresurf\_influxdb.admin\_password = 'root'

The cluster admin password to use when connecting to InfluxDB.

#### default.squaresurf\_influxdb.admin\_old\_username = 'root'

The previous cluster admin username for use if you ever change the username to
another value. This is so that we can create a new cluster admin and delete
this old cluster admin.

#### default.squaresurf\_influxdb.admin\_old\_password = 'root'

The previous cluster admin password for use if you ever change the password to
another value. This is so that we can set the new password.

### InfluxDB TOML Config Attributes

#### default.squaresurf\_influxdb.config

This should be a ruby hash that will be converted to toml for the InfluxDB
config.toml. The default was generated from the default config.toml that comes
with InfluxDB.

#### default.squaresurf\_influxdb.benchmark\_config

This should be a ruby hash that will be converted to toml for the InfluxDB
benchmark\_config.toml. The default was generated from the default
benchmark\_config.toml that comes with InfluxDB.

Usage
-----

The one main attribute that you should always change is the
node.squaresurf\_influxdb.admin\_password. That way you won't have a default
cluster admin password that anyone can connect to your server with.

### squaresurf\_influxdb::default

Either include the recipe in your *run\_list* or `include_recipe` from within
one of your recipes. For example you could do the following to setup influxdb
and create a database named *metrics* and a user named *sensu*.

```ruby
# Make sure to set the admin password to some secret value. It would probably
# be even better to use an encrypted data bag here as shown in the next example.
node.set.squaresurf_influxdb.admin_password = 'super secret'

include_recipe 'squaresurf_influxdb::default'

squaresurf_influxdb_database 'metrics'

squaresurf_influxdb_user 'sensu' do
    password 'some secret value'
    database 'metrics'
end
```

### squaresurf\_influxdb::install and squaresurf\_influxdb::configure

Instead of using the default recipe you can seperate your logic into an install
then a configure in case you need to setup some items vefore the service is
started. For example you could set up ssl configuration for the http api like so:

```ruby
cert_file = '/opt/influxdb/ssl_cert.pem'
node.set.squaresurf_influxdb.config.api['ssl-cert'] = cert_file
node.set.squaresurf_influxdb.config.api['ssl-port'] = 8084

cert = Chef::EncryptedDataBagItem.load('ssl', 'influxdb')

admin = Chef::EncryptedDataBagItem.load('influxdb', 'admin')
node.default.squaresurf_influxdb.admin_password = admin['password']
node.default.squaresurf_influxdb.admin_old_password = admin['old_password']

# install first so that the /opt/influxdb dir and influxdb user will be created
include_recipe 'squaresurf_influxdb::install'

file cert_file do
  content cert['cert'] + "\n" + cert['key']
  user 'influxdb'
  group 'influxdb'
  mode '0700'
end

include_recipe 'squaresurf_influxdb::configure'
```

Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

### Testing

There is a Rakefile with tasks to make testing easy. You will probably need to
`bundle install` before running any of them.

* rake test:all            # Run all tests
* rake test:chefspec       # Run chefspec
* rake test:foodcritic     # Run foodcritic linter against cookbook
* rake test:kitchen\_test  # This is here as a convenience so that the test
  suite will check kitchen as well as the other tests
* rake test:rubocop        # Run rubocop against cookbook ruby files

### config and benchmark\_config attribute generation

There is a convenience script `toml_to_attr.rb` to help generate the config and
benchmark\_config ruby hashes from a default toml file included with influxdb.

If you haven't run `bundle install` for the test suite above you'll probably
need to do so in order to run `toml_to_attr.rb`.

License and Authors
-------------------

### License

The License is the MIT License and can be found in the LICENSE file.

### Authors

* [Daniel Paul Searles (squaresurf)](https://github.com/squaresurf)
