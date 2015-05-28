require 'spec_helper'

describe 'swap_file::files' do
  # by default the hiera integration uses hirea data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  #include_context :hiera

  let(:title) { 'default' }

  # below is the facts hash that gives you the ability to mock
  # facts on a per describe/context block.  If you use a fact in your
  # manifest you should mock the facts below.
  let(:facts) do
    {
      :memorysize => '8.00 GB'
    }
  end
  # below is a list of the resource parameters that you can override.
  # By default all non-required parameters are commented out,
  # while all required parameters will require you to add a value
  let(:params) do
    {
      :ensure => "present",
      :swapfile => "/mnt/swap.1",
      :swapfilesize => '1GB',
      :add_mount => true,
      :options => "defaults",
    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  it do
    is_expected.to contain_exec('Create swap file /mnt/swap.1').
             with({"command"=>"/bin/dd if=/dev/zero of=/mnt/swap.1 bs=1M count=1073",
                   "creates"=>"/mnt/swap.1"})
  end
  it do
    is_expected.to contain_file('/mnt/swap.1').
             with({"owner"=>"root",
                   "group"=>"root",
                   "mode"=>"0600",
                   "require"=>"Exec[Create swap file /mnt/swap.1]"})
  end
  it do
    is_expected.to contain_exec('Attach swap file /mnt/swap.1').
             with({"command"=>"/sbin/mkswap /mnt/swap.1 && /sbin/swapon /mnt/swap.1",
                   "require"=>"File[/mnt/swap.1]",
                   "unless"=>"/sbin/swapon -s | grep /mnt/swap.1"})
  end
end
