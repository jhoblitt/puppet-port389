# private class
class port389::admin::service {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  service { 'dirsrv-admin':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
