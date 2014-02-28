# private class
class port389::tune {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  class { 'limits':
    purge_limits_d_dir => false,
  }

  # per
  # https://access.redhat.com/site/documentation/en-US/Red_Hat_Directory_Server/9.0/html/Performance_Tuning_Guide/system-tuning.html

  # echo vm.min_free_kbytes=1024 >> /etc/sysctl.conf

  # > fs.file-max = 64000
  sysctl { 'fs.file-max':
    ensure => present,
    value  => '100000',
  }

  # echo vm.swappiness=10 >> /etc/sysctl.conf
  # not setting swappiness as this is often set to 0 on VMs

  # *        -        nofile        8192
  limits::limits { 'all_both_nofile':
    ensure     => present,
    user       => '*',
    limit_type => 'nofile',
    both       => 8192,
  }

  # nobody               soft        nofile          4096
  limits::limits { 'nobody_soft_nofile':
    ensure     => present,
    user       => 'nobody',
    limit_type => 'nofile',
    soft       => 4096,
  }

  # nobody               hard        nofile          63536
  limits::limits { 'nobody_hard_nofile':
    ensure     => present,
    user       => 'nobody',
    limit_type => 'nofile',
    hard       => 63536,
  }

  # nobody      soft      nproc      2047
  limits::limits { 'nobody_soft_nproc':
    ensure     => present,
    user       => 'nobody',
    limit_type => 'nproc',
    soft       => 2047,
  }

  # nobody      hard      nproc      16384
  limits::limits { 'nobody_hard_nproc':
    ensure     => present,
    user       => 'nobody',
    limit_type => 'nproc',
    hard       => 16384,
  }

  # echo "1024 65000" > /proc/sys/net/ipv4/ip_local_port_range
  sysctl { 'net.ipv4.ip_local_port_range':
    ensure => present,
    value  => "1024\t65000",
  }
}
