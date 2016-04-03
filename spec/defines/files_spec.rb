require 'spec_helper'

describe 'swap_file::files' do
  let(:title) { 'default' }

  let(:facts) do
    {
      :operatingsystem => 'RedHat',
      :osfamily        => 'RedHat',
      :operatingsystemrelease => '7',
      :concat_basedir => '/tmp',
      :memorysize => '1.00 GB'
    }
  end

  # Add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)

  context 'default parameters' do
    it do
      is_expected.to compile.with_all_deps
    end
    it do
      is_expected.to contain_exec('Create swap file /mnt/swap.1').
               with({"command"=>"/bin/dd if=/dev/zero of=/mnt/swap.1 bs=1M count=1024",
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
    it do
      is_expected.to contain_mount('/mnt/swap.1').
               with({"require"=>"Exec[Attach swap file /mnt/swap.1]"})
    end
  end

  context 'custom swapfilesize parameter' do
    let(:params) do
      {
        #:ensure => "present",
        #:swapfile => "/mnt/swap.1",
        :swapfilesize => '4.1 GB',
        #:add_mount => true,
        #:options => "defaults",
      }
    end
    it do
      is_expected.to compile.with_all_deps
    end
    it do
      is_expected.to contain_exec('Create swap file /mnt/swap.1').
      with({"command"=>"/bin/dd if=/dev/zero of=/mnt/swap.1 bs=1M count=4198",
       "creates"=>"/mnt/swap.1"})
    end
  end

  context 'custom swapfilesize parameter with timeout' do
    let(:params) do
      {
        #:ensure => "present",
        :swapfile => "/mnt/swap.2",
        :swapfilesize => '4.1 GB',
        #:add_mount => true,
        #:options => "defaults",
        :timeout => 900,
      }
    end
    it do
      is_expected.to compile.with_all_deps
    end
    it do
      is_expected.to contain_exec('Create swap file /mnt/swap.2').
      with({"command"=>"/bin/dd if=/dev/zero of=/mnt/swap.2 bs=1M count=4198",
       "timeout"=>900,"creates"=>"/mnt/swap.2"})
    end
  end

  context 'custom swapfilesize parameter with timeout' do
    let(:params) do
      {
        :swapfile => "/mnt/swap.2",
        :swapfilesize => '4.1 GB',
        :timeout => 900,
      }
    end
    it do
      is_expected.to compile.with_all_deps
    end
    it do
      is_expected.to contain_exec('Create swap file /mnt/swap.2').
      with({"command"=>"/bin/dd if=/dev/zero of=/mnt/swap.2 bs=1M count=4198",
       "timeout"=>900,"creates"=>"/mnt/swap.2"})
    end
  end

  context 'custom swapfilesize parameter with fallocate' do
    let(:params) do
      {
        :swapfile => "/mnt/swap.3",
        :swapfilesize => '4.1 GB',
        :cmd => 'fallocate',
      }
      it do
        is_expected.to compile.with_all_deps
      end
      is_expected.to contain_exec('Create swap file /mnt/swap.3').
        with(
          {"command"=>"/usr/bin/fallocate -l 4198M /mnt/swap.3",
            "creates"=>"/mnt/swap.3"}
        )
    end
  end

  context 'with cmd set to invalid value' do
    let(:params) do
      {
        :cmd => 'invalid',
      }
    end
    it 'should fail' do
      expect { should contain_class(subject) }.to raise_error(Puppet::Error, /Invalid cmd: invalid - \(Must be \'dd\' or \'fallocate\'\)/)
    end
  end
end
