require 'spec_helper'

describe 'role::tic_services_eventlogging' do
  it_behaves_like 'profile::base'
  it_behaves_like 'role::defined', 'tic_services_eventlogging'

	describe package('talend-ipaas-rt-infra') do
    it { should be_installed }
  end

  describe command('/opt/talend/ipaas/rt-infra/bin/shell "wrapper:install --help"') do
    its(:stdout) { should include 'Install the container as a system service in the OS' }
  end

  describe service('karaf') do
    it { should be_enabled }
    it { should be_running.under('systemd') }
  end

  describe port('8180') do
    it { should be_listening }
  end

  describe port('8181') do
    it { should be_listening }
  end

  describe service('nginx') do
    it { should be_enabled }
    it { should be_running.under('systemd') }
  end

  describe 'Nginx configuration' do
    subject { file('/etc/nginx/nginx.conf').content }
    it { should match(/server_tokens.*off;/) }
    it { should match(/keepalive_timeout.*5 5;/) }
    it { should match(/client_body_buffer_size.*128k;/) }
    it { should match(/client_max_body_size.*500M;/) }
    it { should match(/proxy_connect_timeout.*3600;/) }
    it { should match(/proxy_read_timeout.*3600;/) }
    it { should match(/proxy_send_timeout.*3600;/) }
  end

  describe command('/usr/bin/curl http://localhost:8181/services') do
    its(:stdout) { should include 'Service list' }
  end

  describe command('/usr/bin/curl http://localhost:8180/services') do
    its(:stdout) { should include 'Service list' }
  end

  describe 'Service configuration' do
    subject { file('/opt/talend/ipaas/rt-infra/etc/karaf-wrapper.conf').content }
    it { should match /wrapper.jvm_kill.delay\s*=\s*5/ }
    it { should match /wrapper.java.additional.10\s*=\s*-XX:MaxPermSize=256m/ }
    it { should match /wrapper.java.additional.11\s*=\s*-Dcom.sun.management.jmxremote.port=7199/ }
    it { should match /wrapper.java.additional.12\s*=\s*-Dcom.sun.management.jmxremote.authenticate=false/ }
    it { should match /wrapper.java.additional.13\s*=\s*-Dcom.sun.management.jmxremote.ssl=false/ }
    it { should match /wrapper.java.maxmemory\s*=\s*1024/ }
    it { should match /wrapper.disable_restarts\s*=\s*true/ }
  end

  describe 'Additional Java Packages' do
    subject { package('jre-jce') }
    it { should be_installed }
  end

end
