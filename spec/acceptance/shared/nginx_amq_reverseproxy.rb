shared_examples 'profile::nginx_amq_reverseproxy' do

  it_behaves_like 'profile::defined', 'nginx_amq_reverseproxy'
  it_behaves_like 'profile::common::packagecloud_repos'

  describe service('nginx') do
      it { should be_enabled }
      it { should be_running }
  end

  describe port(80) do
      it { should be_listening }
  end

  describe package('nginx') do
    it { should be_installed }
  end

  describe file('/etc/nginx/nginx.conf') do
    its(:content) { should match /client_max_body_size\s+50m;/ }
  end

  describe file('/etc/nginx/sites-enabled/jetty.conf') do
    its(:content) { should match /proxy_pass\s+http:\/\/localhost:8080;/ }
  end

  describe 'Prepares a 100KB payload' do
    subject { command('/usr/bin/dd if=/dev/zero of=/tmp/100K.dump bs=100K count=1') }
    its(:exit_status) { should eq 0 }
  end

  describe 'Prepares a 100MB payload' do
    subject { command('/usr/bin/dd if=/dev/zero of=/tmp/100M.dump bs=100M count=1') }
    its(:exit_status) { should eq 0 }
  end

  describe 'Expects an error 500 by requesting 100KB payload' do
    subject { command('/usr/bin/curl -s -o /dev/null -w "%{http_code}" --data-binary @/tmp/100K.dump http://localhost/') }
    its(:stdout) { should eq '500' }
  end

  describe 'Expects an error 413 by requesting 100MB payload' do
    subject { command('/usr/bin/curl -s -o /dev/null -w "%{http_code}" --data-binary @/tmp/100M.dump http://localhost/') }
    its(:stdout) { should eq '413' }
  end

end
