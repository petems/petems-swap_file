require 'spec_helper_acceptance'

describe 'swap_file class', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do

  context 'disable stringify_facts' do
    shell('puppet config set stringify_facts true --section=agent', { :acceptable_exit_codes => [0,1] })
    shell('puppet config set stringify_facts true', { :acceptable_exit_codes => [0,1] })
  end

  context 'swap_file' do
    context 'swapfilesize => 100' do
      it 'should work with no errors' do
        pp = <<-EOS
        swap_file::files { 'default':
          ensure          => present,
          swapfilesize    => '100MB',
          resize_existing => true,
        }
        EOS

        # Run it twice and test for idempotency
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes  => true)
      end
      it 'should contain the given swapfile with the correct size (102396/100MB)' do
        shell('/sbin/swapon -s | grep /mnt/swap.1', :acceptable_exit_codes => [0])
        shell('/bin/cat /proc/swaps | grep 102396', :acceptable_exit_codes => [0])
      end
    end
    context 'resize swap file' do
      it 'errors out if stringify_facts is true and resize_existing is true' do
        pp = <<-EOS
        swap_file::files { 'default':
          ensure       => present,
          swapfilesize => '100MB',
          resize_existing => true,
        }
        EOS

        # Run it twice and test for idempotency
        apply_manifest(pp, :expect_failures => true) do |r|
          expect(r.stderr).to match(/stringify_facts was true/)
        end
      end
    end
  end

end
