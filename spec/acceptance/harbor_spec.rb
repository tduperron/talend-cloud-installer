require 'spec_helper'

describe 'role::harbor' do
    it_behaves_like 'profile::base'

    describe package('docker-engine') do
        it { is_expected.to be_installed }
    end

    describe command('which docker-compose') do
        its(:stdout) { should match /.*\/bin\/docker-compose/ }
        its(:stderr) { should be_empty }
    end

    describe file('/opt/harbor') do
        it { should be_directory }
    end

    describe file('/opt/harbor/harbor.cfg') do
        it { should exist }
    end

    # Check that vmware harbor images are loaded
    describe command('docker images | grep vmware | wc -l') do
        its(:stdout) { should match /7/ }
    end

end
