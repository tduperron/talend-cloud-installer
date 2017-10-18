class profile::cibase () {

  include docker
  #include profile::common::cloudwatch
  #include docker::run_instance
  #include packer
  #include ci::jq

  # profile::register_profile { 'cibase': }
}
