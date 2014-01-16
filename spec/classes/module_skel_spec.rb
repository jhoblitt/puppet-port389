require 'spec_helper'

describe 'port389', :type => :class do

  describe 'for osfamily RedHat' do
    it { should contain_class('port389') }
  end

end
