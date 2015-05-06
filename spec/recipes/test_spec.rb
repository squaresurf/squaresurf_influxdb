require_relative '../spec_helper'

describe 'squaresurf_influxdb::test' do
  subject { ChefSpec::Runner.new.converge(described_recipe) }

  # For serverspecs to work properly
  it { should install_package('curl') }

  it { should include_recipe('squaresurf_influxdb::default') }

  it { should create_squaresurf_influxdb_database('testdb') }

  it { should create_squaresurf_influxdb_database('testdb2') }
  it do
    should delete_squaresurf_influxdb_database('testdb2-delete')
      .with(database: 'testdb2')
  end

  it do
    should create_squaresurf_influxdb_cluster_admin('tester_cluster_admin')
      .with(password: 'tester')
  end

  it do
    should create_squaresurf_influxdb_cluster_admin('tester_cluster_admin2')
      .with(password: 'tester')
  end
  it do
    should delete_squaresurf_influxdb_cluster_admin(
      'tester_cluster_admin2-delete')
      .with(username: 'tester_cluster_admin2')
  end

  it do
    should create_squaresurf_influxdb_user('tester_db_user')
      .with(password: 'tester', database: 'testdb')
  end

  it do
    should create_squaresurf_influxdb_user('tester_db_user2')
      .with(password: 'tester', database: 'testdb')
  end
  it do
    should delete_squaresurf_influxdb_user('tester_db_user2-delete')
      .with(database: 'testdb', username: 'tester_db_user2')
  end

  it do
    should create_squaresurf_influxdb_user('tester_db_admin')
      .with(password: 'tester', database: 'testdb', admin: true)
  end

  it do
    should create_squaresurf_influxdb_user('tester_db_admin2')
      .with(password: 'tester', database: 'testdb', admin: true)
  end
  it do
    should delete_squaresurf_influxdb_user('tester_db_admin2-delete')
      .with(database: 'testdb', username: 'tester_db_admin2')
  end

  it do
    should create_squaresurf_influxdb_user('tester_read_only_user')
      .with(password: 'tester', database: 'testdb', write_to: ' ')
  end

  it do
    should create_squaresurf_influxdb_user('tester_read_only_user2')
      .with(password: 'tester', database: 'testdb', write_to: ' ')
  end
  it do
    should delete_squaresurf_influxdb_user('tester_read_only_user2-delete')
      .with(database: 'testdb', username: 'tester_read_only_user2')
  end

  it do
    should create_squaresurf_influxdb_user('tester_write_only_user')
      .with(password: 'tester', database: 'testdb', read_from: ' ')
  end

  it do
    should create_squaresurf_influxdb_user('tester_write_only_user2')
      .with(password: 'tester', database: 'testdb', read_from: ' ')
  end
  it do
    should delete_squaresurf_influxdb_user('tester_write_only_user2-delete')
      .with(database: 'testdb', username: 'tester_write_only_user2')
  end
end
