# private class
class port389::install (
  $ensure         = 'present',
  $package_ensure = $port389::package_ensure,
  $package_name   = $port389::package_name,
) {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  validate_re($ensure, '^present$|^absent$|^latest$|^purged$')

  package { $package_name:
    ensure => $ensure,
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
