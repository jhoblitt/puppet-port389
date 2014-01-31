Puppet::Type.type(:service).provide :redhat_instance, :parent => :redhat do
  desc <<-EOS
Manage odd RedHat services (specifially, 389 Directory Server) that use a
single /etc/init.d script to manage multiple instances of a service.
Start/stop uses /sbin/service.  Does not allow enable/disable as this would
globally control all instances of the service.

The service type's little used `control` parameter is abused to set the name of
the service script name while the namevar indidicates the service instance
name.

*Example:*

Given a init.d scritpt that behaves like:

    /etc/init.d/<script> <command> <instance name>

Eg.:

    $ sudo /etc/init.d/dirsrv status 
    dirsrv ldap1 is stopped
    dirsrv ldap2 (pid 5604) is running...
    $ sudo /etc/init.d/dirsrv status ldap1
    dirsrv ldap1 is stopped
    $ sudo /etc/init.d/dirsrv status ldap2
    dirsrv ldap2 (pid 5604) is running...

One might desire a manifest as so:

    notify { 'bogus': }

    service { 'ldap1':
      control    => 'dirsrv',
      ensure     => 'stopped',
      enable     => true,      # <= ignored
      hasstatus  => true,
      hasrestart => true,
      provider   => redhat_instance,
      subscribe  => Notify['bogus'],
    }

    service { 'ldap2':
      control    => 'dirsrv',
      ensure     => 'running',
      enable     => true,      # <= ignored
      hasstatus  => true,
      hasrestart => true,
      provider   => redhat_instance,
      subscribe  => Notify['bogus'],
    }
EOS

  # disable this provider matching the service types's feature :enableable
  undef_method :enable
  undef_method :disable
  undef_method :enabled?
  
  # this provider should never be the default
  # XXX unsure of the "proper" way to remove the defaultfor from the base class
  # undef_method :defaultfor
  # defaultfor :osfamily => :dne
  # @defaults = {}
  def self.default?
    false
  end

  def statuscmd
    ((@resource.provider.get(:hasstatus) == true) || (@resource[:hasstatus] == :true)) && [command(:service), @resource[:control], "status", @resource[:name]]
  end

  def restartcmd
    (@resource[:hasrestart] == :true) && [command(:service), @resource[:control], "restart", @resource[:name]]
  end

  def startcmd
    [command(:service), @resource[:control], "start", @resource[:name]]
  end

  def stopcmd
    [command(:service), @resource[:control], "stop", @resource[:name]]
  end
end
