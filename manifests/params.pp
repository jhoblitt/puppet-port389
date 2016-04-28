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

  # this should be off by default due to it's intrusiveness
  $enable_tuning = false

  # uid/gid
  $user  = 'nobody'
  $group = $user

  # general section defaults
  $admin_domain               = $::domain
  $config_directory_admin_id  = 'admin'
  $config_directory_admin_pwd = 'password'
  $config_directory_ldap_url  = "ldap://${::fqdn}:389/o=NetscapeRoot"
  $full_machine_name          = $::fqdn

  # admin section defaults
  $server_admin_port = '9830'
  $server_admin_id   = 'admin'
  $server_admin_pwd  = 'password'
  $server_ipaddress  = '0.0.0.0'

  # slapd section defaults
  $root_dn     = 'cn=Directory Manager'
  $root_dn_pwd = 'password'
  $server_port = '389'

  # the dir under which setup-ds-admin.pl .inf files will be created and stored
  # note that /var/lib/dirsrv/ is created by the 389-ds-base package
  $setup_dir = '/var/lib/dirsrv/setup'

  # ssl
  $enable_ssl              = false
  $ssl_server_port         = '636'
  $ssl_cert                = undef
  $ssl_key                 = undef
  $ssl_ca_certs            = {}
  $enable_server_admin_ssl = false

  $purge_commands = [
    'rm -f /etc/sysconfig/dirsrv*',
    'rm -rf /etc/dirsrv/',
    'rm -rf /usr/lib64/dirsrv/',
    'rm -rf /var/log/dirsrv/',
    'rm -rf /var/lib/dirsrv/',
    'rm -rf /var/lock/dirsrv/',
    'rm -rf /usr/share/dirsrv/',
    'rm -f /etc/selinux/targeted/modules/active/modules/dirsrv-admin.pp',
    'rm -f /etc/selinux/targeted/modules/active/modules/dirsrv.pp',
    'rm -f /usr/share/selinux/devel/include/services/dirsrv-admin.if',
    'rm -f /usr/share/selinux/devel/include/services/dirsrv.if',
    'rm -f /usr/share/selinux/targeted/dirsrv-admin.pp.bz2',
    'rm -f /usr/share/selinux/targeted/dirsrv.pp.bz2',
  ]
}
