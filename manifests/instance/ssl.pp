# private type
define port389::instance::ssl (
  $root_dn,
  $root_dn_pwd,
  $server_port,
  $ssl_server_port,
  $ssl_cert,
  $ssl_key,
  $ssl_ca_certs,
) {
  validate_string($root_dn)
  validate_string($root_dn_pwd)
  validate_string($server_port)
  validate_string($ssl_server_port)
  validate_absolute_path($ssl_cert)
  validate_absolute_path($ssl_key)
  validate_hash($ssl_ca_certs)

  if $caller_module_name != $module_name {
    fail("Use of private type ${name} by ${caller_module_name}")
  }

  # we need the openldap client tools to configure the 389 server for SSL
  include openldap::client

  # based on SSL setup instructions from:
  # http://directory.fedoraproject.org/wiki/Howto:SSL#Starting_the_Server_with_SSL_enabled
  # and
  # https://access.redhat.com/site/documentation/en-US/Red_Hat_Directory_Server/9.0/html/Administration_Guide/Managing_SSL.html

  # how to change default ssl port
  # https://access.redhat.com/site/documentation/en-US/Red_Hat_Directory_Server/9.0/html/Administration_Guide/Configuring_LDAP_Parameters-Changing_DS_Port_Numbers.html#changing-ssl-ports

  ensure_resource('file', 'ssl_enable.ldif', {
    ensure => file,
    path   => "${::port389::setup_dir}/ssl_enable.ldif",
    owner  => 'root',
    group  => 'root',
    mode   => '0640',
    source => "puppet:///modules/${module_name}/ssl_enable.ldif",
    backup => false,
  })

  ensure_resource('file', 'addRSA.ldif', {
    ensure => file,
    path   => "${::port389::setup_dir}/addRSA.ldif",
    owner  => 'root',
    group  => 'root',
    mode   => '0640',
    source => "puppet:///modules/${module_name}/addRSA.ldif",
    backup => false,
  })

  file { "set_secureport_${name}.ldif":
    ensure  => file,
    path    => "${::port389::setup_dir}/set_secureport_${name}.ldif",
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template("${module_name}/set_secureport.ldif.erb"),
    backup  => false,
  }

  $ldap_connect = "-x -H \"ldap://localhost:${server_port}\" -D \"${root_dn}\" -w \"${root_dn_pwd}\""

  exec { "ssl_enable.ldif-${name}":
    path      => ['/bin', '/usr/bin'],
    command   => "ldapmodify ${ldap_connect} -f ${::port389::setup_dir}/ssl_enable.ldif",
    unless    => "ldapsearch ${ldap_connect} -b cn=encryption,cn=config \"nsSSL3=on\" nsSSL3 | grep \"nsSSL3: on\"",
    logoutput => true,
    require   => [Class['openldap::client'], File['ssl_enable.ldif']],
  } ->
  exec { "addRSA.ldif-${name}":
    path      => ['/bin', '/usr/bin'],
    command   => "ldapmodify ${ldap_connect} -f ${::port389::setup_dir}/addRSA.ldif",
    unless    => "ldapsearch ${ldap_connect} -b cn=RSA,cn=encryption,cn=config \"nsSSLActivation=on\" nsSSLActivation | grep \"nsSSLActivation: on\"",
    logoutput => true,
    require   => [Class['openldap::client'], File['addRSA.ldif']],
  } ->
  exec { "set_secureport_${name}.ldif":
    path      => ['/bin', '/usr/bin'],
    command   => "ldapmodify ${ldap_connect} -f ${::port389::setup_dir}/set_secureport_${name}.ldif",
    unless    => "ldapsearch ${ldap_connect} -b cn=config \"nsslapd-secureport=${ssl_server_port}\" nsslapd-secureport | grep \"nsslapd-secureport: ${ssl_server_port}\"",
    logoutput => true,
    require   => [Class['openldap::client'], File["set_secureport_${name}.ldif"]],
  }

  $certdir = "/etc/dirsrv/slapd-${name}"

  file { "pin.txt-${name}":
    ensure  => file,
    path    => "${certdir}/pin.txt",
    owner   => $::port389::user,
    group   => $::port389::group,
    mode    => '0400',
    content => "Internal (Software) Token:${root_dn_pwd}",
  }

  port389::certs{ $name:
    certdir      => $certdir,
    nss_password => $root_dn_pwd,
    ssl_nickname => 'Server-Cert',
    ssl_cert     => $ssl_cert,
    ssl_key      => $ssl_key,
    ssl_ca_certs => $ssl_ca_certs,
  }
}
