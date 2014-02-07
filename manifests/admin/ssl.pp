# private class
class port389::admin::ssl (
  $server_admin_pwd,
  $ssl_cert,
  $ssl_key,
  $ssl_ca_certs,
) {
  validate_string($server_admin_pwd)
  validate_absolute_path($ssl_cert)
  validate_absolute_path($ssl_key)
  validate_hash($ssl_ca_certs)

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $certdir = "/etc/dirsrv/admin-serv"

  file { "pin.txt-admin":
    ensure  => file,
    path    => "${certdir}/pin.txt",
    owner   => $::port389::user,
    group   => $::port389::group,
    mode    => '0400',
    content => "internal:${server_admin_pwd}",
  }

  # by default, SSL/TLS is off
  file_line { 'NSSEngine':
    path  => '/etc/dirsrv/admin-serv/nss.conf',
    line  => 'NSSEngine on',
    match => '^.*NSSEngine.*',
  }

  # by default, instances use pin.txt while admin server uses password.conf;
  # make them consistent
  file_line { 'NSSPassPhraseDialog':
    path  => '/etc/dirsrv/admin-serv/nss.conf',
    line  => 'NSSPassPhraseDialog file:/etc/dirsrv/admin-serv/pin.conf',
    match => '^.*NSSPassPhraseDialog.*',
  }

  # by default, instances use 'Server-Cert' while the admin server uses
  # 'server-cert'; make them consistent
  file_line { 'NSSNickname':
    path  => '/etc/dirsrv/admin-serv/nss.conf',
    line  => 'NSSNickname Server-Cert',
    match => '^.*NSSEngine.*',
  }

  port389::certs{ $name:
    certdir      => $certdir,
    nss_password => $server_admin_pwd,
    ssl_cert     => $ssl_cert,
    ssl_key      => $ssl_key,
    ssl_ca_certs => $ssl_ca_certs,
  }
}
