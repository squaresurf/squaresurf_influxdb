require_relative '../spec_helper'
require_relative '../../libraries/influxdb.rb'

def chef_opts(log_level = :warn)
  {
    step_into: %w(
      squaresurf_influxdb_user
      squaresurf_influxdb_database
      squaresurf_influxdb_cluster_admin
    ),
    log_level: log_level
  }
end

# Setup default test attributes and merge them with the extra_params
def attributes(extra_params)
  {
    check_missing_node: false,
    check_unknown_port: false,
    check_cluster_admin_delete: false,
    check_set_cluster_admin_as_database_user: false,
    check_missing_password_cluster_admin_create: false,
    check_missing_password_database_user_create: false
  }.merge(extra_params)
end

def let_chef_run(extra_params, log_level = :warn)
  let(:chef_run) do
    ChefSpec::Runner.new chef_opts(log_level) do |node|
      attributes(extra_params).each do |key, value|
        node.set['squaresurf_influxdb'][key] = value
      end
    end.converge(described_recipe)
  end
end

def should_fail(extra_params)
  let_chef_run(extra_params.merge('fail_on_error' => true))
end

def should_not_fail(extra_params)
  let_chef_run(extra_params.merge('fail_on_error' => false), :fatal)
end

def expect_error
  it do
    expect do
      chef_run
    end.to raise_error(SquaresurfInfluxDB::Error)
  end
end

describe 'squaresurf_influxdb::test_exceptions' do
  subject { ChefSpec::Runner.new.converge(described_recipe) }

  describe 'should fail' do

    context 'when library is missing node attributes' do
      should_fail('check_missing_node' => true)
      expect_error
    end

    context 'when influxdb port is unknown' do
      should_fail('check_unknown_port' => true)
      expect_error
    end

    context 'when recipe attempts to delete main cluster admin' do
      should_fail('check_cluster_admin_delete' => true)
      expect_error
    end

    context 'when recipe creates cluster admin with no password' do
      should_fail('check_missing_password_cluster_admin_create' => true)
      expect_error
    end

    context 'when recipe creates database user with no password' do
      should_fail('check_missing_password_database_user_create' => true)
      expect_error
    end

    context 'when recipe creates database user with cluster admin username' do
      should_fail('check_set_cluster_admin_as_database_user' => true)
      expect_error
    end

  end

  describe 'should log and not fail' do

    context 'when library is missing node attributes' do
      should_not_fail('check_missing_node' => true)
      it { chef_run }
    end

    context 'when influxdb port is unknown' do
      should_not_fail('check_unknown_port' => true)
      it { chef_run }
    end

    context 'when recipe attempts to delete main cluster admin' do
      should_not_fail('check_cluster_admin_delete' => true)
      it { chef_run }
    end

    context 'when recipe attempts to delete main cluster admin' do
      should_not_fail('check_missing_password_cluster_admin_create' => true)
      it { chef_run }
    end

    context 'when recipe creates database user with no password' do
      should_not_fail('check_missing_password_database_user_create' => true)
      it { chef_run }
    end

    context 'when recipe creates database user with cluster admin username' do
      should_not_fail('check_set_cluster_admin_as_database_user' => true)
      it { chef_run }
    end

  end

end
