shared_examples 'profile::common::cloudwatch' do
  describe file('/opt/cloudwatch-agent/metrics.yaml') do
    its(:content) { should include '  metrics:' }
    its(:content) { should include '    DiskSpace:' }
  end

  describe file('/var/spool/cron/cloudwatch-agent') do
    its(:content) { should include '# Puppet Name: CloudWatch Agent' }
    its(:content) { should include '/opt/cloudwatch-agent/cw_agent.py --metrics /opt/cloudwatch-agent/metrics.yaml' }
  end
end
