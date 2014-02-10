# private class
class port389::admin::ssl {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  Class['port389::admin::ssl']{ notify => Class['port389::admin::service'] }

  # per
  # http://directory.fedoraproject.org/wiki/Howto:SSL#Admin_Server_SSL_Information

  $admindir = '/etc/dirsrv/admin-serv'
  $certdir  = $admindir
  # note that the nickname is all lowercase, unlike for the slapd instances
  $nickname = 'server-cert'

  port389::certs{ 'admin':
    certdir      => $certdir,
    nss_password => $::port389::server_admin_pwd,
    ssl_cert     => $::port389::ssl_cert,
    ssl_nickname => $nickname,
    ssl_key      => $::port389::ssl_key,
    ssl_ca_certs => $::port389::ssl_ca_certs,
  }

  file { 'enable_admin_ssl.ldif':
    ensure  => file,
    path    => "${::port389::setup_dir}/enable_admin_ssl.ldif",
    owner   => $::port389::user,
    group   => $::port389::group,
    mode    => '0600',
    content => template("${module_name}/enable_admin_ssl.ldif.erb"),
    backup  => false,
  }

  $ssl_server_port = $::port389::ssl_server_port
  $ldap_connect = "-x -H \"ldap://localhost:${::port389::server_port}\" -D \"${::port389::root_dn}\" -w \"${::port389::root_dn_pwd}\""

  exec { 'enable_admin_ssl.ldif':
    path      => ['/bin', '/usr/bin'],
    command   => "ldapmodify ${ldap_connect} -f ${::port389::setup_dir}/enable_admin_ssl.ldif",
    unless    => "ldapsearch ${ldap_connect} -b \"cn=slapd-ldap1,cn=389 Directory Server,cn=Server Group,cn=main.vm,ou=sdm.noao.edu,o=NetscapeRoot\" nsServerSecurity nsServerSecurity | grep \"nsServerSecurity: on\"",
    logoutput => true,
    require   => [Class['openldap::client'], File['enable_admin_ssl.ldif']],
  } ->

  #
  # nss.conf
  #
  file { 'admin-pin.txt':
    ensure  => file,
    path    => "${certdir}/pin.txt",
    owner   => $::port389::user,
    group   => $::port389::group,
    mode    => '0400',
    content => "internal:${::port389::server_admin_pwd}",
  }

  # by default, instances use pin.txt while admin server uses password.conf;
  # make them consistent
  file_line { 'NSSPassPhraseDialog':
    path  => "${admindir}/nss.conf",
    line  => 'NSSPassPhraseDialog file:/etc/dirsrv/admin-serv/pin.txt',
    match => '^.*NSSPassPhraseDialog.*',
  }

  #
  # console.conf
  #

  #  NSSEngine [off|on] - set to on to enable the Admin Server to use https
  #  (SSL/TLS) instead of http, off otherwise
  file_line { 'NSSEngine':
    path  => "${admindir}/console.conf",
    line  => 'NSSEngine on',
    match => '^.*NSSEngine.*',
  }

  # NSSNickname [server-cert] - this is the nickname of the Admin Server cert
  # in it's cert/key database - server-cert is the default and the one created
  # by the script above
  file_line { 'NSSNickname':
    path  => "${admindir}/console.conf",
    line  => "NSSNickname ${nickname}",
    match => '^.*NSSNickname.*',
  }

  #
  # adm.conf
  #
  file_line { 'ldapurl:':
    path  => "${admindir}/adm.conf",
    line  => "ldapurl: ldaps://${::port389::full_machine_name}:${::port389::ssl_server_port}/o=NetscapeRoot",
    match => '^.*ldapurl:.*',
  }
}
