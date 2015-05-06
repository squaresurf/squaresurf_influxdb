require 'serverspec_helper'
require 'influxdb_helper'

describe 'default recipe' do
  describe command('which influxdb') do
    its(:exit_status) { should eq 0 }
  end

  describe service('influxdb') do
    it { should be_enabled }
    it { should be_running }
  end

  describe "default cluster admin 'root' shouldn't exist" do
    name_exists_in_list(list_cluster_admins, 'testerton')
  end

  describe 'cluster admin testerton should exist and authenticate' do
    cmd = http_code('cluster_admins/authenticate?u=testerton&p=yupper')
    describe command(cmd) do
      its(:stdout) { should eq '200' }
    end
  end

  describe 'config should exist' do
    describe file('/opt/influxdb/shared/config.toml') do
      it { should be_file }
    end
  end

  describe 'benchmark config should exist' do
    describe file('/opt/influxdb/shared/benchmark_config.toml') do
      it { should be_file }
    end
  end
end
