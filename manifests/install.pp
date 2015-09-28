# private class
class port389::install (
  $ensure         = 'present',
  $package_ensure     = $port389::package_ensure,
  $package_name       = $port389::package_name,
  $package_name_admin = $port389::package_name_admin,
  $package_name_base  = $port389::package_name_base,
  $install_admin      = $port389::install_admin,
) {
  validate_re($ensure, '^present$|^absent$|^latest$|^purged$')
  if !(is_string($package_ensure) or is_array($package_ensure)) {
    fail('package_ensure must be a string or an array')
  }
  if !(is_string($package_name) or is_array($package_name)) {
    fail('package_name must be a string or an array')
  }

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  # As of puppet 3.4.2, the yum provider for the package type does not handle
  # 'purged' correctly and shows activity on every run.
  if $::osfamily == 'RedHat' {
    $safe_ensure = $ensure ? {
      'purged' => 'absent',
      default  => $ensure,
    }
  } else {
    $safe_ensure = $ensure
  }

  if ! empty($package_name) {
    # if someone was setting package_name, use this instead of newer parameters
    # that break up admin and base packages
    package { $package_name:
      ensure => $safe_ensure,
    }
  } elsif ($install_admin) {
    package { $package_name_admin:
      ensure => $safe_ensure,
    }
    package { $package_name_base:
      ensure => $safe_ensure,
    }
  } else {
    package { $package_name_base:
      ensure => $safe_ensure,
    }
  }


  case $ensure {
    'present', 'latest': {
      ensure_packages(any2array($package_ensure))
    }
    'purged': {
      exec { $::port389::purge_commands:
        path        => '/bin',
        logoutput   => true,
        refreshonly => true,
        subscribe   => Package[$package_name],
      }
    }
    default: {} # keep linter happy
  }
}
