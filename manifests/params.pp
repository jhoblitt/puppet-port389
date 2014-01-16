# private class
class port389::params {
  case $::osfamily {
    'redhat': {}
    default: {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }

  # console also requires java
  $package_name = [
    '389-admin',
    '389-admin-console',
    '389-admin-console-doc',
    #'389-admin-debuginfo',
    '389-adminutil',
    #'389-adminutil-debuginfo',
    '389-adminutil-devel',
    '389-console',
    '389-ds',
    '389-ds-base',
    '389-ds-base-devel',
    '389-ds-base-libs',
    '389-ds-console',
    '389-ds-console-doc',
    '389-dsgw',
    #'389-dsgw-debuginfo',
  ]

  # console requires /usr/sbin/httpd.worker provided by `httpd`
  # we need to ensure the presence of this package but do not want 'ownership'
  # of it
  $package_ensure = 'httpd'
}
