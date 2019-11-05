#
# Nginx service profile
#
# Setup a proxypass to ActiveMQ filtering messages by size
#
class profile::nginx_amq_reverseproxy (

  $client_max_body_size = '50M',

){

  profile::register_profile{ 'nginx_amq_reverseproxy': }

  class { 'nginx':
    client_body_buffer_size => false,
    client_max_body_size    => $client_max_body_size,
    gzip                    => 'off',
    http_tcp_nodelay        => 'on',
    http_tcp_nopush         => 'on',
    keepalive_timeout       => 65,
    proxy_buffers           => undef,
    proxy_buffer_size       => undef,
    proxy_connect_timeout   => '10s',
    proxy_read_timeout      => '60s',
    proxy_redirect          => 'off',
    proxy_send_timeout      => '35s',
    proxy_set_header        => [],
    types_hash_max_size     => 2048,
    worker_connections      => 8192,
    worker_processes        => 'auto',
    worker_rlimit_nofile    => 102000,
  }

  nginx::resource::vhost { 'jetty':
    listen_port    => 80,
    proxy          => 'http://localhost:8080',
    server_name    => ['_'],
    listen_options => 'default_server',
    index_files    => []
  }

}
