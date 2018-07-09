class profile::test_launcher (
  $mysql_on_same_host   = undef,
) {

  file { '/opt/talend/':
    ensure => 'directory',
  }

  file { '/opt/talend/tmc/':
    ensure => 'directory',
  }
  file { '/opt/talend/tmc/tests_variables.sh':
    content => "#!/bin/bash
export TMC_URL=${tmc_url}
export SCIM_URL=${scim_url}
export LOGIN_URL=${login_url}
export PSWSEED=${tmc_pswseed}
export REPORT_BUCKET=${report_bucket}
"
  }

}
