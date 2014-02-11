# private type
define port389::certs (
  $certdir,
  $nss_password,
  $ssl_nickname,
  $ssl_cert,
  $ssl_key,
  $ssl_ca_certs,
) {
  validate_absolute_path($certdir)
  validate_string($nss_password)
  validate_absolute_path($ssl_cert)
  validate_string($ssl_nickname)
  validate_absolute_path($ssl_key)
  validate_hash($ssl_ca_certs)

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  nsstools::create { $certdir:
    owner          => $::port389::user,
    group          => $::port389::group,
    mode           => '0600',
    password       => $nss_password,
    manage_certdir => false,
  }

  nsstools::add_cert_and_key { $ssl_nickname:
    certdir  => $certdir,
    cert     => $ssl_cert,
    key      => $ssl_key,
  }

  if size(keys($ssl_ca_certs)) > 0 {
    nsstools_add_cert($certdir, $ssl_ca_certs)
  }
}
