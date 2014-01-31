require 'spec_helper'

describe 'port389_nssdb_add_cert', :type => :puppet_function do
  it 'should fail with < 2 param' do
    expect { subject.call([1]) }.to raise_error(/Wrong number of arguments/)
  end

  it 'should fail with > 2 param' do
    expect { subject.call([1, 2, 3]) }.to raise_error(/Wrong number of arguments/)
  end

  it 'should require first arg to be a string' do
    expect { subject.call([1, 2]) }.to raise_error(/First argument must be a string/)
  end

  it 'should require second arg to be a hash' do
    expect { subject.call(['1', 2]) }.to raise_error(/Second argument must be a hash/)
  end

  it 'should work with reasonable input' do
    should run.with_params(
      '/etc/dirsrv/slapd-ldap1',
      {
        'AlphaSSL CA'        => '/tmp/alphassl_intermediate.pem',
        'GlobalSign Root CA' => '/tmp/globalsign_root.pem',
      }
    )

    alpha = catalogue.resource('Nssdb::Add_cert', '/etc/dirsrv/slapd-ldap1-AlphaSSL CA')
    alpha[:nickname].should eq 'AlphaSSL CA'
    alpha[:certdir].should  eq '/etc/dirsrv/slapd-ldap1'
    alpha[:cert].should     eq '/tmp/alphassl_intermediate.pem'

    global = catalogue.resource('Nssdb::Add_cert', '/etc/dirsrv/slapd-ldap1-GlobalSign Root CA')
    global[:nickname].should eq 'GlobalSign Root CA'
    global[:certdir].should  eq '/etc/dirsrv/slapd-ldap1'
    global[:cert].should     eq '/tmp/globalsign_root.pem'
  end
end
