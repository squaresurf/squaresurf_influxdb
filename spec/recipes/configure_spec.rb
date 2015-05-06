require_relative '../spec_helper'

describe 'squaresurf_influxdb::configure' do
  subject { ChefSpec::Runner.new.converge(described_recipe) }

  it { should create_file('/opt/influxdb/shared/config.toml') }

  it { should create_file('/opt/influxdb/shared/benchmark_config.toml') }

  it do
    should enable_service('influxdb').with(
      supports: { restart: true, reload: false, status: true }
    )
  end

  it { should start_service('influxdb') }

  it do
    should create_squaresurf_influxdb_cluster_admin('root')
      .with(password: 'root', username: 'root')
  end
  it { should_not delete_squaresurf_influxdb_cluster_admin('root') }

  context 'alternate admin username' do
    subject do
      ChefSpec::Runner.new do |node|
        node.set['squaresurf_influxdb']['admin_username'] = 'testerton'
        node.set['squaresurf_influxdb']['admin_password'] = 'yah'
      end.converge(described_recipe)
    end

    it do
      should create_squaresurf_influxdb_cluster_admin('testerton')
        .with(password: 'yah', username: 'testerton')
    end
    it do
      should delete_squaresurf_influxdb_cluster_admin('root-delete')
        .with(username: 'root')
    end
  end
end
