#! /usr/bin/env ruby

# copied (and heavily hacked up) on 2014-01-31 from:
# https://raw2.github.com/puppetlabs/puppet/master/lib/puppet/provider/service/redhat.rb

#
# Unit testing for the RedHat service Provider
#
require 'spec_helper'

provider_class = Puppet::Type.type(:service).provider(:redhat_instance)

describe provider_class, :as_platform => :posix do

  before :each do
    @class = Puppet::Type.type(:service).provider(:redhat_instance)
    @resource = stub 'resource'
    @resource.stubs(:[]).returns(nil)
    @resource.stubs(:[]).with(:name).returns "myinstance"
    @resource.stubs(:[]).with(:control).returns "myservice"
    @provider = provider_class.new
    @resource.stubs(:provider).returns @provider
    @provider.resource = @resource
    @provider.stubs(:get).with(:hasstatus).returns false
    FileTest.stubs(:file?).with('/sbin/service').returns true
    FileTest.stubs(:executable?).with('/sbin/service').returns true
    Facter.stubs(:value).with(:operatingsystem).returns('CentOS')
  end

  [ 'RedHat', 'Suse' ].each do |osfamily|
    it "should not be the default provider on #{osfamily}" do
      #Facter.expects(:value).with(:osfamily).returns(osfamily)
      provider_class.default?.should be_false
    end
  end

  # test self.instances
  describe "when getting all service instances" do
    before :each do
      @services = ['one', 'two', 'three', 'four']
      Dir.stubs(:entries).returns @services
      FileTest.stubs(:directory?).returns(true)
      FileTest.stubs(:executable?).returns(true)
    end

    it "should return instances for all services" do
      (@services).each do |inst|
        @class.expects(:new).with{|hash| hash[:name] == inst && hash[:path] == '/etc/init.d'}.returns("#{inst}_instance")
      end
      results = (@services).collect {|x| "#{x}_instance"}
      @class.instances.should == results
    end

    it "should call service status when initialized from provider" do
      @resource.stubs(:[]).with(:status).returns nil
      @provider.stubs(:get).with(:hasstatus).returns true
      @provider.expects(:execute).with{|command, *args| command == ['/sbin/service', 'myservice', 'status', 'myinstance']}
      @provider.send(:status)
    end
  end

  it "should not have an enabled? method" do
    @provider.should_not respond_to(:enabled?)
  end

  it "should not have an enable method" do
    @provider.should_not respond_to(:enable)
  end

  it "should not have a disable method" do
    @provider.should_not respond_to(:disable)
  end

  [:start, :stop, :status, :restart].each do |method|
    it "should have a #{method} method" do
      @provider.should respond_to(method)
    end
    describe "when running #{method}" do

      it "should use any provided explicit command" do
        @resource.stubs(:[]).with(method).returns "/user/specified/command"
        @provider.expects(:execute).with { |command, *args| command == ["/user/specified/command"] }
        @provider.send(method)
      end

      it "should execute the service script with #{method} when no explicit command is provided" do
        @resource.stubs(:[]).with("has#{method}".intern).returns :true
        @provider.expects(:execute).with { |command, *args| command ==  ['/sbin/service', 'myservice', method.to_s, 'myinstance']}
        @provider.send(method)
      end
    end
  end

  describe "when checking status" do
    describe "when hasstatus is :true" do
      before :each do
        @resource.stubs(:[]).with(:hasstatus).returns :true
      end
      it "should execute the service script with fail_on_failure false" do
        @provider.expects(:texecute).with(:status, ['/sbin/service', 'myservice', 'status', 'myinstance'], false)
        @provider.status
      end
      it "should consider the process running if the command returns 0" do
        @provider.expects(:texecute).with(:status, ['/sbin/service', 'myservice', 'status', 'myinstance'], false)
        $CHILD_STATUS.stubs(:exitstatus).returns(0)
        @provider.status.should == :running
      end
      [-10,-1,1,10].each { |ec|
        it "should consider the process stopped if the command returns something non-0" do
          @provider.expects(:texecute).with(:status, ['/sbin/service', 'myservice', 'status', 'myinstance'], false)
          $CHILD_STATUS.stubs(:exitstatus).returns(ec)
          @provider.status.should == :stopped
        end
      }
    end
    describe "when hasstatus is not :true" do
      it "should consider the service :running if it has a pid" do
        @provider.expects(:getpid).returns "1234"
        @provider.status.should == :running
      end
      it "should consider the service :stopped if it doesn't have a pid" do
        @provider.expects(:getpid).returns nil
        @provider.status.should == :stopped
      end
    end
  end

  describe "when restarting and hasrestart is not :true" do
    it "should stop and restart the process with the server script" do
      @provider.expects(:texecute).with(:stop,  ['/sbin/service', 'myservice', 'stop', 'myinstance'],  true)
      @provider.expects(:texecute).with(:start, ['/sbin/service', 'myservice', 'start', 'myinstance'], true)
      @provider.restart
    end
  end
end
