# == Class: port389
#
# simple template
#
# === Examples
#
# include port389
#
class port389(
  $ensure                     = 'present',
  $package_ensure             = $::port389::params::package_ensure,
  $package_name               = $::port389::params::package_name,
  $enable_tuning              = $::port389::params::enable_tuning,
  $user                       = $::port389::params::user,
  $group                      = $::port389::params::group,
  $admin_domain               = $::port389::params::admin_domain,
  $config_directory_admin_id  = $::port389::params::config_directory_admin_id,
  $config_directory_admin_pwd = $::port389::params::config_directory_admin_pwd,
  $config_directory_ldap_url  = $::port389::params::config_directory_ldap_url,
  $full_machine_name          = $::port389::params::full_machine_name,
  $server_admin_port          = $::port389::params::server_admin_port,
  $server_admin_id            = $::port389::params::server_admin_id,
  $server_admin_pwd           = $::port389::params::server_admin_pwd,
  $server_ipaddress           = $::port389::params::server_ipaddress,
  $root_dn                    = $::port389::params::root_dn,
  $root_dn_pwd                = $::port389::params::root_dn_pwd,
  $server_port                = $::port389::params::server_port,
  $setup_dir                  = $::port389::params::setup_dir,
  $enable_ssl                 = $::port389::params::enable_ssl,
  $enable_server_admin_ssl    = $::port389::params::enable_server_admin_ssl,
  $ssl_server_port            = $::port389::params::ssl_server_port,
  $ssl_cert                   = $::port389::params::ssl_cert,
  $ssl_key                    = $::port389::params::ssl_key,
  $ssl_ca_certs               = $::port389::params::ssl_ca_certs,
) inherits port389::params {
  validate_re($ensure, '^present$|^absent$|^latest$|^purged$')
  if !(is_string($package_ensure) or is_array($package_ensure)) {
    fail('package_ensure must be a string or an array')
  }
  if !(is_string($package_name) or is_array($package_name)) {
    fail('package_name must be a string or an array')
  }
  validate_bool($enable_tuning)
  validate_string($user)
  validate_string($group)
  validate_string($admin_domain)
  validate_string($config_directory_admin_id)
  validate_string($config_directory_admin_pwd)
  validate_string($config_directory_ldap_url)
  validate_string($full_machine_name)
  validate_string($server_admin_port)
  validate_string($server_admin_id)
  validate_string($server_admin_pwd)
  validate_string($server_ipaddress)
  validate_string($root_dn)
  validate_string($root_dn_pwd)
  validate_string($server_port)
  validate_string($setup_dir)
  # ssl
  validate_bool($enable_ssl)
  validate_bool($enable_server_admin_ssl)
  # don't validate ssl_* params unless $enable_ssl or enable_server_admin_ssl
  # == true
  if $enable_ssl or $enable_server_admin_ssl {
    validate_string($ssl_server_port)
    validate_absolute_path($ssl_cert)
    validate_absolute_path($ssl_key)
    validate_hash($ssl_ca_certs)
  }

  anchor { 'port389::begin': }

  case $ensure {
    'present', 'latest': {
      if $enable_tuning {
        Anchor['port389::begin'] ->
        class { 'port389::tune': } ->
        Anchor['port389::end']
      }

      Anchor['port389::begin'] ->
      class { 'port389::install': ensure => $ensure } ->
      file { $setup_dir:
        ensure => directory,
        owner  => $user,
        group  => $group,
        mode   => '0700',
      } ->
      Port389::Instance<| |> ->
      service { 'dirsrv':
        ensure     => 'running',
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
      } ->
      Anchor['port389::end']
    }
    # the global 'dirsrv' service is only managed for uninstall
    # otherwise, each instance manages it's own 'sub' dirsrv service instance
    'absent': {
      Anchor['port389::begin'] ->
      service { 'dirsrv':
        ensure => 'stopped',
        enable => false,
      } ->
      class { 'port389::install': ensure => $ensure } ->
      Anchor['port389::end']
    }
    'purged': {
      Anchor['port389::begin'] ->
      service { 'dirsrv':
        ensure     => 'stopped',
        enable     => false,
        hasstatus  => true,
        hasrestart => true,
      } ->
      class { 'port389::install': ensure => $ensure } ->
      file { $setup_dir:
        ensure => absent,
        force  => true,
      } ->
      Anchor['port389::end']
    }
    default: {} # keep lint happy
  }

  anchor { 'port389::end': }
}
