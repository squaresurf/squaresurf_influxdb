require_relative '../spec_helper'

remote_deb_format = 'http://s3.amazonaws.com/influxdb/influxdb_%s_%s.deb'

describe 'squaresurf_influxdb::default' do
  subject { ChefSpec::Runner.new.converge(described_recipe) }

  context 'install once latest influxdb' do
    # This is the default action.
    source = sprintf(remote_deb_format, 'latest', 'amd64')
    it do
      should create_if_missing_remote_file('/opt/influxdb.deb')
        .with(source: source)
    end
  end

  context 'update once latest influxdb' do
    # This is the default action.
    source = sprintf(remote_deb_format, 'latest', 'amd64')

    subject do
      ChefSpec::Runner.new do |node|
        node.set['squaresurf_influxdb']['update_version'] = true
      end.converge(described_recipe)
    end

    it { should create_remote_file('/opt/influxdb.deb').with(source: source) }
  end

  context 'install once specific influxdb version' do
    version = 'arbitrary'
    arch = 'i386'
    source = sprintf(remote_deb_format, version, arch)

    subject do
      ChefSpec::Runner.new do |node|
        node.set['squaresurf_influxdb']['version'] = version
        node.automatic['kernel']['machine'] = arch
      end.converge(described_recipe)
    end

    it do
      should create_if_missing_remote_file('/opt/influxdb.deb')
        .with(source: source)
    end
  end

  context 'update specific influxdb version' do
    version = 'arbitrary'
    arch = 'i386'
    source = sprintf(remote_deb_format, version, arch)

    subject do
      ChefSpec::Runner.new do |node|
        node.set['squaresurf_influxdb']['version'] = version
        node.set['squaresurf_influxdb']['update_version'] = true
        node.automatic['kernel']['machine'] = arch
      end.converge(described_recipe)
    end

    it { should create_remote_file('/opt/influxdb.deb').with(source: source) }
  end

  it do
    should install_dpkg_package('influxdb').with(source: '/opt/influxdb.deb')
  end

end
