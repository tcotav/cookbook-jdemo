require 'spec_helper'

describe 'jdemo::default' do
  let(:chef_run) { ChefSpec::Runner.new(:platform => 'ubuntu', :version => '12.04').converge(described_recipe) }

  it 'runs base recipe' do
    expect(chef_run).to include_recipe "jdemo::default"
  end

  it 'installs java' do
    expect(chef_run).to include_recipe "java::default"
  end
end