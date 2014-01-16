require 'spec_helper'

describe 'port389', :type => :class do

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
  end # on osfamily RedHat

  describe 'on an unsupported osfamily' do
    let(:facts) {{ :osfamily => 'Debian', :operatingsystem => 'Debian' }}

    it 'should fail' do
     expect { should contain_class('port389') }.
        to raise_error(Puppet::Error, /not supported on Debian/)
    end
  end # on an unsupported osfamily

end
