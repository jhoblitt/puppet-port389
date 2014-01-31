module Puppet::Parser::Functions
  newfunction(:port389_nssdb_add_cert, :doc => <<-EOS
Iterates over a hash of cert nickname/path pairs (key/value) and creates
nssdb::add_cert resources.

*Example:*

  port389_nssdb_add_cert(
    '/etc/dirsrv/slapd-ldap1',
    {
      'AlphaSSL CA'        => '/tmp/alphassl_intermediate.pem',
      'GlobalSign Root CA' => '/tmp/globalsign_root.pem',
    }
  )

Would effectively define these resources:

  nssdb::add_cert { 'AlphaSSL CA':
    certdir  => '/etc/dirsrv/slapd-ldap1',
    nickname => 'AlphaSSL CA',
    cert     => '/tmp/alphassl_intermediate.pem',
  }

  nssdb::add_cert { 'GlobalSign Root CA':
    certdir  => '/etc/dirsrv/slapd-ldap1',
    nickname => 'GlobalSign Root CA',
    cert     => '/tmp/globalsign_root.pem',
  }

  EOS
  ) do |args|
    unless args.size == 2
      raise(Puppet::ParseError, ":port389_nssdb_add_cert(): " +
        "Wrong number of arguments given #{args.size} for 2")
    end

    certdir = args[0]
    certs   = args[1]

    unless certdir.is_a?(String)
      raise(Puppet::ParseError, ":port389_nssdb_add_cert(): " +
        "First argument must be a string")
    end

    unless certs.is_a?(Hash)
      raise(Puppet::ParseError, ":port389_nssdb_add_cert(): " +
        "Second argument must be a hash")
    end
    
    # we need to managle the resource name so multiple instances (and/or the
    # admin server) can reuse the same certs
    certs.each_pair do |nickname, cert|
      function_create_resources(['nssdb::add_cert', {
        "#{certdir}-#{nickname}" => {
          'certdir'  => certdir,
          'nickname' => nickname,
          'cert'     => cert,
        }
      }])
    end    
  end
end
