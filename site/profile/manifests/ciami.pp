#
class profile::ciami () {

    
    #include ci::jenkins
    #include ci::build_tools
    #include resizeroot

    #include profile::java

    #include sbt # removes error "class sbt has not been evaluated"

    # ci::jenkins { 'set':
    #   role => 'jenkins_dist'
    # }

    #include ci::jenkins

    include ::profile::common::concat
    profile::register_profile { 'ciami': }
}
