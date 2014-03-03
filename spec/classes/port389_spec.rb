require 'spec_helper'

describe 'port389', :type => :class do
  shared_examples 'been_tuned' do
    it { should contain_class('limits').with({ :purge_limits_d_dir => false }) }
    it { should contain_sysctl('fs.file-max') }
    it { should contain_limits__limits('all_both_nofile') }
    it { should contain_limits__limits('nobody_soft_nofile') }
    it { should contain_limits__limits('nobody_hard_nofile') }
    it { should contain_limits__limits('nobody_soft_nproc') }
    it { should contain_limits__limits('nobody_hard_nproc') }
    it { should contain_sysctl('net.ipv4.ip_local_port_range') }
  end

  describe 'on osfamily RedHat' do
    let(:facts) {{ :osfamily => 'RedHat' }}

    redhat_packages = [
      '389-admin',
      '389-admin-console',
      '389-admin-console-doc',
      #'389-admin-debuginfo',
      '389-adminutil',
      #'389-adminutil-debuginfo',
      '389-adminutil-devel',
      '389-console',
      '389-ds',
      '389-ds-base',
      '389-ds-base-devel',
      '389-ds-base-libs',
      '389-ds-console',
      '389-ds-console-doc',
      '389-dsgw',
      #'389-dsgw-debuginfo',
    ]

    context 'param defaults' do
      it { should_not contain_class('port389::tune') }
      it('should include package dependency') { should contain_package('httpd') }
      redhat_packages.each do |pkg|
        it('should include package') { should contain_package(pkg) }
      end
      it 'should manage setup dir' do
        should contain_file('/var/lib/dirsrv/setup').with({
          :ensure => 'directory',
          :owner  => 'nobody',
          :group  => 'nobody',
          :mode   => '0700',
        })
      end
      it 'should enable dirsrv' do
        should contain_service('dirsrv').with({
          :ensure => 'running',
          :enable => true,
        }).that_comes_before('Anchor[port389::end]')
      end
    end # param defaults

    context 'ensure =>' do
      context 'present' do
        let(:params) {{ :ensure => 'present' }}

        it { should_not contain_class('port389::tune') }
        redhat_packages.each do |pkg|
          it { should contain_package(pkg).with_ensure('present') }
        end
        it do
          should contain_file('/var/lib/dirsrv/setup').with({
            :ensure => 'directory',
            :owner  => 'nobody',
            :group  => 'nobody',
            :mode   => '0700',
          })
        end
      end # present

      context 'latest' do
        let(:params) {{ :ensure => 'latest' }}

        it { should_not contain_class('port389::tune') }
        redhat_packages.each do |pkg|
          it { should contain_package(pkg).with_ensure('latest') }
        end
        it do
          should contain_file('/var/lib/dirsrv/setup').with({
            :ensure => 'directory',
            :owner  => 'nobody',
            :group  => 'nobody',
            :mode   => '0700',
          })
        end
      end # latest

      context 'absent' do
        let(:params) {{ :ensure => 'absent' }}

        it { should_not contain_class('port389::tune') }
        it do
          # XXX implimentation specific
          should contain_service('dirsrv').with({
            :ensure => 'stopped',
            :enable => false,
          }).that_comes_before('Class[port389::install]')
        end
        redhat_packages.each do |pkg|
          it { should contain_package(pkg).with_ensure('absent') }
        end
        it { should_not contain_file('/var/lib/dirsrv/setup') }
      end # absent

      context 'purged' do
        let(:params) {{ :ensure => 'purged' }}

        it { should_not contain_class('port389::tune') }
        it do
          # XXX implimentation specific
          should contain_service('dirsrv').with({
            :ensure => 'stopped',
            :enable => false,
          }).that_comes_before('Class[port389::install]')
        end
        redhat_packages.each do |pkg|
          it { should contain_package(pkg).with_ensure('absent') }
        end
        [
          'rm -f /etc/sysconfig/dirsrv*',
          'rm -rf /etc/dirsrv/',
          'rm -rf /usr/lib64/dirsrv/',
          'rm -rf /var/log/dirsrv/',
          'rm -rf /var/lib/dirsrv/',
          'rm -rf /var/lock/dirsrv/',
          'rm -rf /usr/share/dirsrv/',
          'rm -f /etc/selinux/targeted/modules/active/modules/dirsrv-admin.pp',
          'rm -f /etc/selinux/targeted/modules/active/modules/dirsrv.pp',
          'rm -f /usr/share/selinux/devel/include/services/dirsrv-admin.if',
          'rm -f /usr/share/selinux/devel/include/services/dirsrv.if',
          'rm -f /usr/share/selinux/targeted/dirsrv-admin.pp.bz2',
          'rm -f /usr/share/selinux/targeted/dirsrv.pp.bz2',
        ].each do |cmd|
          it { should contain_exec(cmd) }
        end
        it do
          # XXX implimentation specific
          should contain_file('/var/lib/dirsrv/setup').with({
            :ensure => 'absent',
            :force  => true,
          }).that_requires('Class[port389::install]')
        end
      end # purged

      context 'foo' do
        let(:params) {{ :ensure => 'foo' }}

        it 'should fail' do
          expect {
            should compile
          }.to raise_error(/"foo" does not match/)
        end
      end # foo
    end # ensure =>

    context 'enable_tuning =>' do
      context 'true' do
        let(:params) {{ :enable_tuning => true }}

        it { should contain_class('port389::tune') }
        it_should_behave_like 'been_tuned'
      end # true

      context 'false' do
        let(:params) {{ :enable_tuning => false }}

        it { should_not contain_class('port389::tune') }
      end # false

      context '[]' do
        let(:params) {{ :enable_tuning =>[] }}

        it 'should fail' do
          expect {
            should compile
          }.to raise_error(/is not a boolean/)
        end
      end # []
    end # enable_tuning =>
  end # on osfamily RedHat

  describe 'on an unsupported osfamily' do
    let(:facts) {{ :osfamily => 'Debian', :operatingsystem => 'Debian' }}

    it 'should fail' do
     expect { should compile }.
        to raise_error(/not supported on Debian/)
    end
  end # on an unsupported osfamily

end
