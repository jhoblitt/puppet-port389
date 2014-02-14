Puppet port389 Module
=====================

[![Build Status](https://travis-ci.org/jhoblitt/puppet-port389.png)](https://travis-ci.org/jhoblitt/puppet-port389)

#### Table of Contents

1. [Overview](#overview)
2. [Description](#description)
3. [Usage](#usage)
    * [Example](#Example)
    * [Classes](#classes)
    * [Types](#types)
    * [Functions](#functions)
4. [Limitations](#limitations)
    * [Tested Platforms](#tested-platforms)
5. [Versioning](#versioning)
6. [Support](#support)
7. [See Also](#see-also)


Overview
--------

Manages the port 389 Directory Server


Description
-----------

This is a module for the management of the `389 Directory Server` aka `389 DS` aka `port
389` aka `Fedora Directory Server` aka `Red Hat Directory Server`.  It aims to
cover most common initial provisioning needs but replication is not yet
support.


Usage
-----

As the typical installation of `389 DS` is done with the `setup-ds-admin.pl`
script, this module attemps to provide an API that's highly analogus to the
keys in the `.inf` that may optionally be passed to the configuration script
for so called unattneded installs.

##Example

```puppet
# java is needed if you want to use the 389-console, no needed for installation
include java

# augeasprovides must be in a working state to enable server tuning
include augeas

class { 'port389':
  enable_tuning              => true,
  admin_domain               => 'example.org',
  config_directory_admin_pwd => 'password',
  server_admin_pwd           => 'password',
  root_dn_pwd                => 'password',
  enable_ssl                 => true,
  enable_server_admin_ssl    => false,
  ssl_cert                   => '/tmp/example.org.pem',
  ssl_key                    => '/tmp/example.org.key',
  ssl_ca_certs               => {
    'AlphaSSL CA'        => '/var/sdm/certificates/alphassl/alphassl_intermediate.pem',
    'GlobalSign Root CA' => '/var/sdm/certificates/alphassl/globalsign_root.pem',
  },
  require                    => Class['augeas']],
}

port389::instance { 'ldap1':
  schema_file => '/tmp/mycustomschema.ldif',
}
```

##Classes

```puppet
# defaults
class { 'port389':
  ensure                     => 'present',
  package_ensure             => 'httpd',
  package_name               => [
    '389-admin',
    '389-admin-console',
    '389-admin-console-doc',
    '389-adminutil',
    '389-adminutil-devel',
    '389-console',
    '389-ds',
    '389-ds-base',
    '389-ds-base-devel',
    '389-ds-base-libs',
    '389-ds-console',
    '389-ds-console-doc',
  ],
  enable_tuning              => true,
  user                       => 'nobody',
  group                      => 'nobody',
  admin_domain               => $::domain,
  config_directory_admin_id  => 'admin',
  config_directory_admin_pwd => 'password',
  config_directory_ldap_url  => "ldap://${::fqdn}:389/o=NetscapeRoot",
  full_machine_name          => $::fqdn,
  server_admin_port          => '9830',
  server_admin_id            => 'admin',
  server_admin_pwd           => 'password',
  server_ipaddress           => '0.0.0.0',
  root_dn                    => 'cn=Directory Manager',
  root_dn_pwd                => 'password',
  server_port                => '389',
  setup_dir                  => '/var/lib/dirsrv/setup',
  enable_ssl                 => false,
  enable_server_admin_ssl    => false,
  ssl_server_port            => '636',
  ssl_cert                   => undef,
  ssl_key                    => undef,
  ssl_ca_certs               => {},
}
```

 * `ensure`

    `String` defaults to `present`

    Must be one of `present`, `absent`, `latest`, `purged`.  Provides typical
    package ensurable semantics with the exception of the `purge` value which
    will attempt to delete all 389 associated data and configuration from your
    system.

 * `package_ensure`

    `String|Array` defaults to `httpd`

    A list of packages to ensure the existance of with the `ensure_packages()`
    function from stdlib.  This is neeeded because the 389 admin server packages
    from EL do not have a dependency on apache.

 * `package_name`

    `Array` defaults to [ '389-admin', ... ]

    The list of packages to manage as providing 389 ds.

 * `enable_tuning`

    `Bool` defaults to `true`

    Enables/disable automatically tuning the system per the RedHat Directory Server 9.0 Performance Tuning Guide section on [Optimizing System Performance](https://access.redhat.com/site/documentation/en-US/Red_Hat_Directory_Server/9.0/html/Performance_Tuning_Guide/system-tuning.html).

 * `user`

    `String` defaults to `nobody`

    The role user account that owns the DS files and the slapd daemons are run
    as.

 * `group`

    `String` defaults to `nobody`

    The role group.

The following parameters directly control values in the `.inf` file passed to
`setup-ds-admin.pl` to create directory service instances.  CamelCase `.inf` keys are represented as lowercase parameters names with `_`s between words.  Eg. `AdminDomain` is transliterated to the `admin_domain` parameter.

See the Red Hat Directory Server 9.0 Installation Guide's section on [Silent
Setup](https://access.redhat.com/site/documentation/en-US/Red_Hat_Directory_Server/9.0/html/Installation_Guide/Advanced_Configuration-Silent.html)
for a listing of all `.inf` file keys.

 * `admin_domain`
 * `config_directory_admin_id`
 * `config_directory_admin_pwd`
 * `config_directory_ldap_url`
 * `full_machine_name`
 * `server_admin_port`
 * `server_admin_id`
 * `server_admin_pwd`
 * `server_ipaddress`
 * `root_dn`
 * `root_dn_pwd`
 * `server_port`

 * `setup_dir`

    `String`/aboslute path defaults to `/var/lib/dirsrv/setup`

    The path used by the module for it's internal state files.

 * `enable_ssl`

    `Bool` defaults to `false`

    Enables/disables setup of SSL/TLS connections to the directory server.

    If set, these paramters are manadatory:

        * `ssl_server_port`
        * `ssl_cert`
        * `ssl_key`
        * `ssl_ca_certs`

 * `enable_server_admin_ssl`

    `Bool` defaults to `false`

    __XXX__ This feature appears to be broken, either in terms of the setup
    done by this module or in the current release of `389 DS` server itselfs and/or
    the interaction with it's dependency.

    Enables/disables the usage of SSL/TLS connections between the admin server and the directory instances.

    If set, these paramters are manadatory:

        * `enable_ssl`
        * `ssl_server_port`
        * `ssl_cert`
        * `ssl_key`
        * `ssl_ca_certs`

The following parameters are ignored unless `enable_ssl` or
`enable_server_admin_ssl` is `true`.

 * `ssl_server_port`

    `String` defaults to `636`

    Sets the port used for `LDAPS` connections.

 * `ssl_cert`

    `String`/aboslute path defaults to `undef`

    Path to the `.pem` format certificate to use for SSL/TLS connections.

 * `ssl_key`

    `String`/aboslute path defaults to `undef`

    Path to the `.pem` format key to use for SSL/TLS connections.

 * `ssl_ca_certs`

    `Hash` defaults to `{}`

    Nickname / absolute path pairs to any chained certificate authority (CA)
    certs that may be needed.

    ```
    {
      'AlphaSSL CA'        => '/tmp/alphassl_intermediate.pem',
      'GlobalSign Root CA' => '/tmp/globalsign_root.pem',
    }
    ```

##Types

```puppet
port389::instance { <title>:
  $admin_domain               = $::port389::admin_domain,
  $config_directory_admin_id  = $::port389::config_directory_admin_id,
  $config_directory_admin_pwd = $::port389::config_directory_admin_pwd,
  $config_directory_ldap_url  = $::port389::config_directory_ldap_url,
  $root_dn                    = $::port389::root_dn,
  $root_dn_pwd                = $::port389::root_dn_pwd,
  $server_port                = $::port389::server_port,
  $enable_ssl                 = $::port389::enable_ssl,
  $ssl_server_port            = $::port389::ssl_server_port,
  $ssl_cert                   = $::port389::ssl_cert,
  $ssl_key                    = $::port389::ssl_key,
  $ssl_ca_certs               = $::port389::ssl_ca_certs,
  $schema_file                = undef,
  $suffix                     = port389_domain2dn($::port389::admin_domain),
}

```

 * `admin_domain`
 * `config_directory_admin_id`
 * `config_directory_admin_pwd`
 * `config_directory_ldap_url`
 * `root_dn`
 * `root_dn_pwd`
 * `server_port`
 * `enable_ssl`
 * `ssl_server_port`
 * `ssl_cert`
 * `ssl_key`
 * `ssl_ca_certs`
 * `schema_file`
 * `suffix`

Functions
---------

###port389_domain2dn

Converts a DNS style domain string into a string suitable for use as a LDAP DN
by constructing 'dc=' elements for each domain component.

Example:

    foo.example.org

Would become:

    dc=foo,dc=example,dc=org


Limitations
-----------

### Tested Platforms


Versioning
----------

This module is versioned according to the [Semantic Versioning
2.0.0](http://semver.org/spec/v2.0.0.html) specification.


Support
-------

Please log tickets and issues at
[github](https://github.com/jhoblitt/puppet-port389/issues)


See Also
--------

