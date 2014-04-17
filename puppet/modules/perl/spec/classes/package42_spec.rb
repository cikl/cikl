require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'perl' do

  let(:title) { 'perl' }
  let(:node) { 'rspec.example42.com' }
  let(:facts) { { :ipaddress => '10.42.42.42' } }

  describe 'Test minimal installation' do
    it { should contain_package('perl').with_ensure('present') }
  end

  describe 'Test installation of a specific version' do
    let(:params) { {:version => '1.0.42' } }
    it { should contain_package('perl').with_ensure('1.0.42') }
  end

  describe 'Test decommissioning - absent' do
    let(:params) { {:absent => true } }
    it 'should remove Package[perl]' do should contain_package('perl').with_ensure('absent') end 
  end

  describe 'Test noops mode' do
    let(:params) { {:noops => true} }
    it { should contain_package('perl').with_noop('true') }
  end

end
