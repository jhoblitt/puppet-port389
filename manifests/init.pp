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
      Anchor['port389::end']
    }
    'absent': {
      Anchor['port389::begin'] ->
      class { 'port389::install': ensure => $ensure } ->
      Anchor['port389::end']
    }
    'purged': {
      Anchor['port389::begin'] ->
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
