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

    it('should import') { should contain_class('port389') }

    it('should include package dependency') { should contain_package('httpd') }
    [
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
    ].each do |pkg|
      it('should include package') { should contain_package(pkg) }
    end

    context 'enable_tuning' do
      context '=> true' do
        let(:params) {{ :enable_tuning => true }}

        it { should contain_class('port389::tune') }
        it_should_behave_like 'been_tuned'
      end

      context '=> false' do
        let(:params) {{ :enable_tuning => false }}

        it { should_not contain_class('port389::tune') }
      end

      context '=> []' do
        let(:params) {{ :enable_tuning =>[] }}

        it 'should fail' do
          expect {
            should contain_class('port389')
          }.to raise_error(/is not a boolean/)
        end
      end
    end
  end # on osfamily RedHat

  describe 'on an unsupported osfamily' do
    let(:facts) {{ :osfamily => 'Debian', :operatingsystem => 'Debian' }}

    it 'should fail' do
     expect { should contain_class('port389') }.
        to raise_error(Puppet::Error, /not supported on Debian/)
    end
  end # on an unsupported osfamily

end
