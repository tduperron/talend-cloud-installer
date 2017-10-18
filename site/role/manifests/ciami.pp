#
# Basic setup for CI servers required for AMI creation
#
class role::ciami {

  #include ::profile::base

  #include ::profile::cibase
  #include ::profile::ciami

  role::register_role { 'ciami': }
}
