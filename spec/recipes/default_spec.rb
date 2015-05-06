require_relative '../spec_helper'

describe 'squaresurf_influxdb::default' do
  subject { ChefSpec::SoloRunner.new.converge(described_recipe) }

  it { should include_recipe 'squaresurf_influxdb::install' }
  it { should include_recipe 'squaresurf_influxdb::configure' }
end
