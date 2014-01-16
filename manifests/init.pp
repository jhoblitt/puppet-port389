# == Class: port389
#
# simple template
#
# === Examples
#
# include port389
#
class port389(
  $package_ensure = $port389::params::package_ensure,
  $package_name   = $port389::params::package_name,
) inherits port389::params {
  if !(is_string($package_ensure) or is_array($package_ensure)) {
    fail('package_ensure must be a string or an array')
  }
  if !(is_string($package_name) or is_array($package_name)) {
    fail('package_name must be a string or an array')
  }

  anchor { 'port389::begin': } ->
  class { 'port389::install': } ->
  anchor { 'port389::end': }
}
