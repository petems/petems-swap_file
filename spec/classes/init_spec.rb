require 'spec_helper'

describe 'swap_file' do
  on_supported_os.sort.each do |os, os_facts|
    context "on #{os} with default values for parameters" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('swap_file') }
      it { is_expected.to have_resource_count(0) }
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

    context 'with files set to valid hash' do
      let(:params) do
        {
          files: {
            'swap' => {
              'ensure' => 'present',
            },
            'test' => {
              'swapfile' => '/mnt/test',
            },
          }
        }
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('swap_file') }
      it { is_expected.to have_resource_count(10) } # subclass swap_file::files adds 4 resources for each given file

      it { is_expected.to have_swap_file__files_resource_count(2) }
      it { is_expected.to contain_swap_file__files('swap').with_ensure('present') }
      it { is_expected.to contain_swap_file__files('test').with_swapfile('/mnt/test') }

      # only here to reach 100% resource coverage
      it { is_expected.to contain_exec('Create swap file /mnt/swap.1') }
      it { is_expected.to contain_exec('Create swap file /mnt/test') }
      it { is_expected.to contain_file('/mnt/swap.1') }
      it { is_expected.to contain_file('/mnt/test') }
      it { is_expected.to contain_mount('/mnt/swap.1') }
      it { is_expected.to contain_mount('/mnt/test') }
      it { is_expected.to contain_swap_file('/mnt/swap.1') }
      it { is_expected.to contain_swap_file('/mnt/test') }
    end

    # Add these two lines in a single test block to enable puppet and hiera debug mode
    # Puppet::Util::Log.level = :debug
    # Puppet::Util::Log.newdestination(:console)

    describe 'with hiera provides data for swap_file::files in multiple hiera levels' do
      let(:facts) do
        super().merge({ fqdn: 'files', parameter_tests: 'files_hiera_merge' })
      end

      context 'when files_hiera_merge is set to the valid value false (default)' do
        let(:params) { { files_hiera_merge: false } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('swap_file') }
        it { is_expected.to have_resource_count(5) }

        it do
          is_expected.to contain_swap_file__files('resource_name').with(
            {
              'ensure'   => 'present',
              'swapfile' => '/mnt/swap',
            },
          )
        end

        # only here to reach 100% resource coverage
        it { is_expected.to contain_exec('Create swap file /mnt/swap') }
        it { is_expected.to contain_file('/mnt/swap') }
        it { is_expected.to contain_mount('/mnt/swap') }
        it { is_expected.to contain_swap_file('/mnt/swap') }
      end

      context 'when files_hiera_merge is set to valid value true' do
        let(:params) { { files_hiera_merge: true } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('swap_file') }
        it { is_expected.to have_resource_count(15) }

        it do
          is_expected.to contain_swap_file__files('resource_name').with(
            {
              'ensure'   => 'present',
              'swapfile' => '/mnt/swap',
            },
          )
        end

        it do
          is_expected.to contain_swap_file__files('swap1').with(
            {
              'ensure'       => 'present',
              'swapfile'     => '/mnt/swap.1',
              'swapfilesize' => '1 GB',
            },
          )
        end

        it do
          is_expected.to contain_swap_file__files('swap2').with(
            {
              'ensure'       => 'present',
              'swapfile'     => '/mnt/swap.2',
              'swapfilesize' => '2 GB',
              'cmd'          => 'fallocate',
            },
          )
        end

        # only here to reach 100% resource coverage
        it { is_expected.to contain_exec('Create swap file /mnt/swap.2') }
        it { is_expected.to contain_file('/mnt/swap.2') }
        it { is_expected.to contain_mount('/mnt/swap.2') }
        it { is_expected.to contain_swap_file('/mnt/swap.2') }
      end
    end

    describe 'variable type and content validations' do
      validations = {
        'Boolean' => {
          name:    ['files_hiera_merge'],
          valid:   [true, false],
          invalid: ['string', 'false', ['array'], { 'ha' => 'sh' }, 3, 2.42, nil],
          message: 'expects a Boolean',
        },
        'Hash' => {
          name:    ['files'],
          valid:   [{ 'swap' => { 'ensure' => 'present' } }],
          invalid: ['string', ['array'], 3, 2.42, false, nil],
          message: 'expects a Hash',
        },
      }

      validations.sort.each do |type, var|
        var[:name].each do |var_name|
          var[:params] = {} if var[:params].nil?
          var[:valid].each do |valid|
            context "when #{var_name} (#{type}) is set to valid #{valid} (as #{valid.class})" do
              let(:params) { [var[:params], { "#{var_name}": valid, }].reduce(:merge) }

              it { is_expected.to compile }
            end
          end

          var[:invalid].each do |invalid|
            context "when #{var_name} (#{type}) is set to invalid #{invalid} (as #{invalid.class})" do
              let(:params) { [var[:params], { "#{var_name}": invalid, }].reduce(:merge) }

              it 'fail' do
                expect { is_expected.to contain_class(:subject) }.to raise_error(Puppet::Error, %r{#{var[:message]}})
              end
            end
          end
        end # var[:name].each
      end # validations.sort.each
    end # describe 'variable type and content validations'
  end
end
