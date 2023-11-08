require 'spec_helper'

describe 'swap_file::files' do
  let(:title) { 'dummy' }

  on_supported_os.sort.each do |os, os_facts|
    context "on #{os} with default values for parameters" do
      let(:facts) do
        # use fixed value for facts['memory']['system']['total'] that otherwise changes between different OS families/flavours
        os_facts.merge({ memory: { system: { total: '1.00 GB' } } })
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to have_resource_count(5) }

      it { is_expected.to contain_swap_file__files('dummy') }

      it do
        is_expected.to contain_exec('Create swap file /mnt/swap.1').only_with(
          {
            'command' => '/bin/dd if=/dev/zero of=/mnt/swap.1 bs=1M count=1024',
            'creates' => '/mnt/swap.1',
            'timeout' => 300,
          },
        )
      end

      seltype = if os_facts[:os]['selinux']['enabled'] == true
                  'swapfile_t'
                else
                  nil
                end

      it do
        is_expected.to contain_file('/mnt/swap.1').only_with(
          {
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0600',
            'require' => 'Exec[Create swap file /mnt/swap.1]',
            'seltype' => seltype,
          },
        )
      end

      it do
        is_expected.to contain_mount('/mnt/swap.1').only_with(
          {
            'ensure'  => 'present',
            'fstype'  => 'swap',
            'device'  => '/mnt/swap.1',
            'options' => 'defaults',
            'dump'    => 0,
            'pass'    => 0,
            'require' => 'Swap_file[/mnt/swap.1]',
          },
        )
      end

      it do
        is_expected.to contain_swap_file('/mnt/swap.1').only_with(
          {
            'ensure'  => 'present',
            'require' => 'File[/mnt/swap.1]',
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

    context 'with ensure set to valid absent' do
      let(:params) { { ensure: 'absent' } }

      it { is_expected.to contain_swap_file__files('dummy') }
      it { is_expected.to contain_swap_file('/mnt/swap.1').only_with_ensure('absent') }

      it do
        is_expected.to contain_file('/mnt/swap.1').only_with(
          {
            'ensure'  => 'absent',
            'backup'  => false,
            'require' => 'Swap_file[/mnt/swap.1]',
          },
        )
      end

      it do
        is_expected.to contain_mount('/mnt/swap.1').only_with(
          {
            'ensure'  => 'absent',
            'device'  => '/mnt/swap.1',
          },
        )
      end
    end

    context 'with swapfile set to valid /test/ing' do
      let(:params) { { swapfile: '/test/ing' } }

      it { is_expected.to contain_file('/test/ing').with_require('Exec[Create swap file /test/ing]') }
      it { is_expected.to contain_swap_file('/test/ing').with_require('File[/test/ing]') }

      it do
        is_expected.to contain_exec('Create swap file /test/ing').with(
          {
            'creates' => '/test/ing',
            'command' => '/bin/dd if=/dev/zero of=/test/ing bs=1M count=7823',
          },
        )
      end

      it do
        is_expected.to contain_mount('/test/ing').with(
          {
            'device'  => '/test/ing',
            'require' => 'Swap_file[/test/ing]',
          },
        )
      end
    end

    context 'with swapfile set to valid /test/ing when ensure is set to valid absent' do
      let(:params) { { swapfile: '/test/ing', ensure: 'absent' } }

      it { is_expected.to contain_swap_file('/test/ing') }
      it { is_expected.to contain_file('/test/ing').with_require('Swap_file[/test/ing]') }
      it { is_expected.to contain_mount('/test/ing').with_device('/test/ing') }
    end

    context 'with swapfilesize set to valid 2.42 GB' do
      let(:params) { { swapfilesize: '2.42 GB' } }

      it { is_expected.to contain_exec('Create swap file /mnt/swap.1').with_command('/bin/dd if=/dev/zero of=/mnt/swap.1 bs=1M count=2478') }
    end

    context 'with swapfilesize set to valid 2.42 GB when cmd is set to valid fallocate' do
      let(:params) { { swapfilesize: '2.42 GB', cmd: 'fallocate' } }

      it { is_expected.to contain_exec('Create swap file /mnt/swap.1').with_command('/usr/bin/fallocate -l 2478M /mnt/swap.1') }
    end

    context 'with add_mount set to valid false' do
      let(:params) { { add_mount: false } }

      it { is_expected.not_to contain_mount('/mnt/swap.1') }
    end

    context 'with options set to valid testing' do
      let(:params) { { options: 'testing' } }

      it { is_expected.to contain_mount('/mnt/swap.1').with_options('testing') }
    end

    context 'with timeout set to valid 242' do
      let(:params) { { timeout: 242 } }

      it { is_expected.to contain_exec('Create swap file /mnt/swap.1').with_timeout(242) }
    end

    context 'with cmd set to valid fallocate' do
      let(:params) { { cmd: 'fallocate' } }

      it { is_expected.to contain_exec('Create swap file /mnt/swap.1').with_command('/usr/bin/fallocate -l 7823M /mnt/swap.1') }
    end

    context 'with resize_existing set to valid true when swapfile_sizes facts is a a valid hash' do
      let(:facts) do
        # add swapfile_sizes fact with a valid hash value
        os_facts.merge({ swapfile_sizes: { '/mnt/swap.1' => '204796' } })
      end
      let(:params) { { resize_existing: true } }

      it { is_expected.to have_swap_file__resize_resource_count(1) }

      it do
        is_expected.to contain_swap_file__resize('/mnt/swap.1').only_with(
          {
            'swapfile_path'          => '/mnt/swap.1',
            'margin'                 => '50MB',
            'expected_swapfile_size' => '7.64 GiB',
            'actual_swapfile_size'   => '204796',
            'verbose'                => false,
            'before'                 => 'Exec[Create swap file /mnt/swap.1]',
          },
        )
      end

      # only here to reach 100% resource coverage
      it { is_expected.to contain_exec('Detach swap file /mnt/swap.1 for resize') }
      it { is_expected.to contain_exec('Purge /mnt/swap.1 for resize') }
    end

    context 'with resize_existing set to valid true when swapfile_sizes_csv facts is a a valid string' do
      let(:facts) do
        # add swapfile_sizes fact with a valid string value
        os_facts.merge({ swapfile_sizes_csv: '/mnt/swap.1||204796', swapfile_sizes: '/mnt/swap.resizeme204796' })
      end
      let(:params) { { resize_existing: true } }

      it { is_expected.to have_swap_file__resize_resource_count(1) }

      it do
        is_expected.to contain_swap_file__resize('/mnt/swap.1').only_with(
          {
            'swapfile_path'          => '/mnt/swap.1',
            'margin'                 => '50MB',
            'expected_swapfile_size' => '7.64 GiB',
            'actual_swapfile_size'   => '204796',
            'verbose'                => false,
            'before'                 => 'Exec[Create swap file /mnt/swap.1]',
          },
        )
      end
    end

    context 'with resize_existing set to valid true when swapfile_sizes does not exists' do
      let(:params) { { resize_existing: true } }

      it { is_expected.to have_swap_file__resize_resource_count(0) }
      it { is_expected.not_to contain_swap_file__resize('/mnt/swap.1') }
    end

    context 'with resize_existing set to valid true when file does not match' do
      let(:facts) do
        # add swapfile_sizes fact with a valid hash value
        os_facts.merge({ swapfile_sizes: { '/mnt/swap.other' => '204796' } })
      end
      let(:params) { { resize_existing: true } }

      it { is_expected.to have_swap_file__resize_resource_count(0) }
      it { is_expected.not_to contain_swap_file__resize('/mnt/swap.1') }
      it { is_expected.to contain_exec('Create swap file /mnt/swap.1') }
    end

    context 'with resize_margin set to valid string when resize_existing set to valid true' do
      let(:facts) do
        # add swapfile_sizes fact with a valid hash value
        os_facts.merge({ swapfile_sizes: { '/mnt/swap.1' => '204796' } })
      end
      let(:params) { { resize_margin: '242MB', resize_existing: true } }

      it { is_expected.to have_swap_file__resize_resource_count(1) }
      it { is_expected.to contain_swap_file__resize('/mnt/swap.1').with_margin('242MB') }
    end

    context 'with resize_verbose set to valid true when resize_existing set to valid true' do
      let(:facts) do
        # add swapfile_sizes fact with a valid hash value
        os_facts.merge({ swapfile_sizes: { '/mnt/swap.1' => '204796' } })
      end
      let(:params) { { resize_verbose: true, resize_existing: true } }

      it { is_expected.to have_swap_file__resize_resource_count(1) }
      it { is_expected.to contain_swap_file__resize('/mnt/swap.1').with_verbose(true) }
    end
  end
end
