require 'spec_helper'

describe 'port389_domain2dn', :type => :puppet_function do
  it 'should fail with > 1 param' do
    should_not run.with_params([1,2]).and_raise_error(Puppet::ParseError)
  end

  it 'work with reasonable input' do
    should run.with_params('foo.example.org').
      and_return('dc=foo,dc=example,dc=org')
  end
end
