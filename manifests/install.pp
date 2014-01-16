# private class
class port389::install (
  $package_ensure = $port389::package_ensure,
  $package_name   = $port389::package_name,
) {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  ensure_packages(any2array($package_ensure))

  package { $package_name:
    ensure => present,
  }
}
