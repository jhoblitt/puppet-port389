
#### [Current]

####
 * [435a443](../../commit/435a443) - __(Joshua Hoblitt)__ Update README.md
 * [c305f77](../../commit/c305f77) - __(Joshua Hoblitt)__ Update README.md
 * [49b24b6](../../commit/49b24b6) - __(Joshua Hoblitt)__ add additional details to README
 * [85d55f5](../../commit/85d55f5) - __(Joshua Hoblitt)__ manage dirsrv (non-instance) service

The dirsrv service defaults to being disabled so no 389 instances will
automatically start on boot.

 * [ae69463](../../commit/ae69463) - __(Joshua Hoblitt)__ convert whitespace in net.ipv4.ip_local_port_range to a tab

To match the output from sysctl to avoid:

    Notice: /Stage[main]/Port389::Tune/Sysctl[net.ipv4.ip_local_port_range]/value:
    changed live value from '1024   65000' to '1024 65000'

 * [46d5fd7](../../commit/46d5fd7) - __(Joshua Hoblitt)__ disable system tuning by default
 * [94bffa9](../../commit/94bffa9) - __(Joshua Hoblitt)__ fill in README
 * [376d79e](../../commit/376d79e) - __(Joshua Hoblitt)__ add dep on jhoblitt/nsstools >= 1.0.2
 * [05cd337](../../commit/05cd337) - __(Joshua Hoblitt)__ modify redhat_instance provider tests to work with 2.7.x

The init service provider in older puppet releases didn't auto-magically
exclude service sysv init script names.  The redhat_instance service
provider isn't intended to be general purposes so testing for the
service name blacklisting can be safely removed.

 * [ba78c67](../../commit/ba78c67) - __(Joshua Hoblitt)__ update rspec to work with ruby 1.8.7
 * [799be3f](../../commit/799be3f) - __(Joshua Hoblitt)__ replace usage of port389_nsstools_add_cert() with nsstools_add_cert()
 * [f2c31d2](../../commit/f2c31d2) - __(Joshua Hoblitt)__ remove port389_nsstools_add_cert() function

Exported and renamed to nsstools_add_cert() in:

    https://github.com/jhoblitt/puppet-nsstools/commit/58cf67dadade00a7ebe19a31d5d01e72d4fa5570

 * [93e211f](../../commit/93e211f) - __(Joshua Hoblitt)__ adapt to nssdb -> nstools rename + API changes
 * [91aac90](../../commit/91aac90) - __(Joshua Hoblitt)__ resolve or suppress lint warnings
 * [22f7644](../../commit/22f7644) - __(Joshua Hoblitt)__ remove rspec-system boilerplate
 * [fe451e5](../../commit/fe451e5) - __(Joshua Hoblitt)__ add rspec coverage of admin server ssl setup

XXX need to test admin service resource but it's not obvious if this
should be tested under the port389 class or the port389::instance type.

 * [b94efdc](../../commit/b94efdc) - __(Joshua Hoblitt)__ change default password(s) to 'password'

To match the example password used in the documentation.

 * [3fd51c6](../../commit/3fd51c6) - __(Joshua Hoblitt)__ simplify instance ssl setup and tidy file ownership/permissions
 * [e143e1b](../../commit/e143e1b) - __(Joshua Hoblitt)__ update admin server ssl support

This should be almost a complete implementation now but it's not in a
working state as sslv2/sslv3 handshakes to port 9830 are hanging.

 * [3b4e9de](../../commit/3b4e9de) - __(Joshua Hoblitt)__ change Modulefile dep on mcanevet/openldap to camptocamp/openldap

It appears that this module maybe be in the process of being renamed:

    https://github.com/mcanevet/puppet-openldap/issues/17

 * [6357541](../../commit/6357541) - __(Joshua Hoblitt)__ add admin server ssl support
 * [36d5e18](../../commit/36d5e18) - __(Joshua Hoblitt)__ add all instance ssl params to port389 base class

To allow them to all be set globally.

 * [a9ddc1a](../../commit/a9ddc1a) - __(Joshua Hoblitt)__ validate private class/type params
 * [fd6113d](../../commit/fd6113d) - __(Joshua Hoblitt)__ facter nssdb setup into it's own type

Split the nssdb setup out of the port389::instance::ssl type into it's
own port389::certs type.

 * [ff24ac3](../../commit/ff24ac3) - __(Joshua Hoblitt)__ add .bundle to .gitignore
 * [e8ea305](../../commit/e8ea305) - __(Joshua Hoblitt)__ add service resource management
 * [6112159](../../commit/6112159) - __(Joshua Hoblitt)__ update Gemfile rspec-puppet to point to upstream git

The patch needed to properly test the port389_nssd_add_cert() function
has been merged:

https://github.com/rodjek/rspec-puppet/pull/155
https://github.com/rodjek/rspec-puppet/commit/03e94422fb9bbdd950d5a0bec6ead5d76e06616b

 * [5f97fe9](../../commit/5f97fe9) - __(Joshua Hoblitt)__ add redhat_instance service type provider

This provider is a subclass of the core redhat service provider.  It is
of limited use and is intended for service scripts that support managing
multiple service instances via additional arguments to the init script.

This is needed to function with 389's sysvinit script.  It appears that
this type of kluedge will not be nessicary for the systemd service
files.

 * [b5f5e99](../../commit/b5f5e99) - __(Joshua Hoblitt)__ add initial per instance ssl configuration

These params have been addded to the port389::instance define
* ssl_server_port
* ssl_cert
* ssl_key
* ssl_ca_certs

 * [dbb1c5e](../../commit/dbb1c5e) - __(Joshua Hoblitt)__ add work around for broken package yum provider on RedHat

As of puppet 3.4.2, the yum provider for the package type does not
handle 'purged' correctly and shows activity on every run.

 * [bb7c059](../../commit/bb7c059) - __(Joshua Hoblitt)__ add warning() when an instance is defined but base class is set to absent
 * [546cba1](../../commit/546cba1) - __(Joshua Hoblitt)__ add ensure param to port389 class

Controls package installation state via these values:
 * {present, latest, absent, purge }

On el6.x, the purg statee will manually `rm -f` all [known] 389 related
files as this is not handled by the 389 rpms.

 * [c58e434](../../commit/c58e434) - __(Joshua Hoblitt)__ add schema_file param to port389::instance define

This param controls SchemaFile entrie(s) in the setup.inf file.

 * [1361895](../../commit/1361895) - __(Joshua Hoblitt)__ remove datacat module from .fixtures.yml (unused)
 * [7df13c2](../../commit/7df13c2) - __(Joshua Hoblitt)__ add initial implementation port389::instance define

The rspec coverage of this define is unfortunately light as is both has
many parameters and required many to be added to the port389 class.

 * [7369ad4](../../commit/7369ad4) - __(Joshua Hoblitt)__ add port389_domain2dn function

Converts a DNS style domain string into a string suitable for use as a
LDAP DN
by constructing 'dc=' elements for each domain component.

*Example:*

    foo.example.org

Would become:

    dc=foo,dc=example,dc=org

 * [c2ff177](../../commit/c2ff177) - __(Joshua Hoblitt)__ convert .fixtures.yml to use all https URLs

Travis CI is choking on ssh+git style repo URLs

 * [a547d03](../../commit/a547d03) - __(Joshua Hoblitt)__ add port389::tune class

This class sets recommending 389/RedHat Directory Server tuning
limits.d and sysctl values.

 * [e984464](../../commit/e984464) - __(Joshua Hoblitt)__ add basic port389::install class
 * [2374d20](../../commit/2374d20) - __(Joshua Hoblitt)__ Merge puppet-module_skel
 * [80d1393](../../commit/80d1393) - __(Joshua Hoblitt)__ first commit
