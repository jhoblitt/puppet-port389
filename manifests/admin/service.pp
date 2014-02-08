# private class
class port389::admin::service {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  service { 'dirsrv-admin':
    enable     => true,
    ensure     => 'running',
    hasstatus  => true,
    hasrestart => true,
  }
}
