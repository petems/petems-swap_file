require 'spec_helper'

describe 'swap_file::resize' do
  let(:title) { 'dummy' }

  on_supported_os.sort.each do |os, os_facts|
    context "on #{os} with default values for parameters when mandatory parameter require no change" do
      let(:facts) { os_facts }
      let(:params) do
        {
          swapfile_path:          '/mnt/swap.1',
          expected_swapfile_size: '1 GB',
          actual_swapfile_size:   '1 GB',
        }
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to have_resource_count(1) }
      it { is_expected.to contain_swap_file__resize('dummy') }
    end

    context "on #{os} with default values for parameters when mandatory parameter require a change" do
      let(:params) do
        {
          swapfile_path:          '/mnt/swap.1',
          expected_swapfile_size: '3 GB',
          actual_swapfile_size:   '1 GB',
        }
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to have_resource_count(3) }
      it { is_expected.to contain_swap_file__resize('dummy') }

      it do
        is_expected.to contain_exec('Detach swap file /mnt/swap.1 for resize').only_with(
          {
            'command' => '/sbin/swapoff /mnt/swap.1',
            'onlyif'  => '/sbin/swapon -s | grep /mnt/swap.1',
            'before'  => 'Exec[Purge /mnt/swap.1 for resize]',
          },
        )
      end

      it do
        is_expected.to contain_exec('Purge /mnt/swap.1 for resize').only_with(
          {
            'command' => '/bin/rm -f /mnt/swap.1',
            'onlyif'  => 'test -f /mnt/swap.1',
            'path'    => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
          },
        )
      end
    end
  end

  # The following tests are OS independent, so we only test one
  example = {
    supported_os: [
      {
        'operatingsystem'        => 'RedHat',
        'operatingsystemrelease' => ['7'],
      },
    ],
  }

  on_supported_os(example).each do |_os, os_facts|
    let(:facts) { os_facts }

    context 'with swapfile_path set to valid /test/ing when mandatory parameter require a change' do
      let(:params) do
        {
          swapfile_path:          '/test/ing',
          expected_swapfile_size: '3 GB',
          actual_swapfile_size:   '1 GB',
        }
      end

      it do
        is_expected.to contain_exec('Detach swap file /test/ing for resize').only_with(
          {
            'command' => '/sbin/swapoff /test/ing',
            'onlyif'  => '/sbin/swapon -s | grep /test/ing',
            'before'  => 'Exec[Purge /test/ing for resize]',
          },
        )
      end

      it do
        is_expected.to contain_exec('Purge /test/ing for resize').only_with(
          {
            'command' => '/bin/rm -f /test/ing',
            'onlyif'  => 'test -f /test/ing',
            'path'    => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
          },
        )
      end
    end

    context 'with verbose is set to valid true when mandatory parameter require a change' do
      let(:params) do
        {
          verbose:                true,
          swapfile_path:          '/mnt/swap.1',
          expected_swapfile_size: '2 GB',
          actual_swapfile_size:   '1 GB',
        }
      end

      it do
        is_expected.to contain_notify('Resizing Swapfile Alert /mnt/swap.1').only_with(
          {
            'name' => "Existing : 1073741824B\nExpected: 2147483648B\nMargin: 52428800B",
          },
        )
      end

      it { is_expected.to contain_exec('Detach swap file /mnt/swap.1 for resize') }
      it { is_expected.to contain_exec('Purge /mnt/swap.1 for resize') }
    end

    context 'with verbose is set to valid true when margin is set to 242MB and mandatory parameter require a change' do
      let(:params) do
        {
          verbose:                true,
          margin:                 '242MB',
          swapfile_path:          '/mnt/swap.1',
          expected_swapfile_size: '2 GB',
          actual_swapfile_size:   '1 GB',
        }
      end

      it do
        is_expected.to contain_notify('Resizing Swapfile Alert /mnt/swap.1').only_with(
          {
            'name' => "Existing : 1073741824B\nExpected: 2147483648B\nMargin: 253755392B",
          },
        )
      end

      it { is_expected.to contain_exec('Detach swap file /mnt/swap.1 for resize') }
      it { is_expected.to contain_exec('Purge /mnt/swap.1 for resize') }
    end

    context 'with verbose is set to valid true when mandatory parameter require no change' do
      let(:params) do
        {
          verbose:                true,
          swapfile_path:          '/mnt/swap.1',
          expected_swapfile_size: '1 GB',
          actual_swapfile_size:   '1 GB',
        }
      end

      it { is_expected.to have_notify_resource_count(0) }
      it { is_expected.to have_exec_resource_count(0) }
    end
  end
end
