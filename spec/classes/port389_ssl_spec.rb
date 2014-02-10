require 'spec_helper'

describe 'port389', :type => :class do
  describe 'on osfamily RedHat' do
    let(:facts) {{ :osfamily => 'RedHat' }}
    let(:params) do
      {
        :ssl_cert     => '/dne/cert.pem',
        :ssl_key      => '/dne/key.pem',
        :ssl_ca_certs => {
          'AlphaSSL CA'        => '/tmp/alphassl_intermediate.pem',
          'GlobalSign Root CA' => '/tmp/globalsign_root.pem',
        }
      }
    end

    # the admin server is initialized by the instance(s) so we need to have a
    # instance defined in the manifest to test the admin server setup.
    let(:pre_condition) { 'port389::instance{ ldap1: }' }

    context 'enable_server_admin_ssl =>' do
      context 'true' do
        before { params[:enable_server_admin_ssl] = true }

        it do
          should contain_file('enable_admin_ssl.ldif').with({
            :ensure => 'file',
            :path   => '/var/lib/dirsrv/setup/enable_admin_ssl.ldif',
            :owner  => 'nobody',
            :group  => 'nobody',
            :mode   => '0600',
            :backup => false,
          })
        end

        it do
          should contain_exec('enable_admin_ssl.ldif').with({
            :path      => [ '/bin', '/usr/bin' ],
            :logoutput => true,
          })
        end

        it do
          should contain_file('admin-pin.txt').with({
            :ensure  => 'file',
            :path    => '/etc/dirsrv/admin-serv/pin.txt',
            :owner   => 'nobody',
            :group   => 'nobody',
            :mode    => '0400',
            :content => 'internal:password',
          })
        end

        %w{ NSSPassPhraseDialog }.each do |name|
          it { should contain_file_line(name).with_path('/etc/dirsrv/admin-serv/nss.conf') }
        end

        %w{ NSSEngine NSSNickname }.each do |name|
          it { should contain_file_line(name).with_path('/etc/dirsrv/admin-serv/console.conf') }
        end

        %w{ ldapurl: }.each do |name|
          it { should contain_file_line(name).with_path('/etc/dirsrv/admin-serv/adm.conf') }
        end
      end # true

      context 'false' do
        before { params[:enable_server_admin_ssl] = false }

        it { should_not contain_file('enable_ssl.ldif') }
        it { should_not contain_exec('enable_admin_ssl.ldif') }
        it { should_not contain_file('admin-pin.txt') }

      end # false

      context '[]' do
        before { params[:enable_server_admin_ssl] = [] }

        it 'should fail' do
          expect {
            should compile
          }.to raise_error(/is not a boolean/)
        end
      end # []
    end # enable_server_admin_ssl =>
  end # on osfamily RedHat
end
