require 'spec_helper_acceptance'

describe 'swap_file::freebsd defined type', :if => fact('osfamily') == 'FreeBSD' do

  context 'swap_file::freebsd' do
    context 'ensure => present' do
      it 'should work with no errors' do
        pp = <<-EOS
        swap_file::freebsd { 'default':
          ensure   => present,
        }
        EOS

        # Run it twice and test for idempotency
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes  => true)
      end
      it 'should contain the default swapfile' do
        shell('/usr/sbin/swapinfo | grep /dev/md99', :acceptable_exit_codes => [0])
      end
      it 'should contain the default fstab setting' do
        shell('cat /etc/fstab | grep /mnt/swap.1', :acceptable_exit_codes => [0])
      end
    end
  end
end
