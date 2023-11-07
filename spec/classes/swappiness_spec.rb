require 'spec_helper'

describe 'swap_file::swappiness' do
  on_supported_os.sort.each do |os, os_facts|
    context "on #{os} with default values for parameters" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('swap_file::swappiness') }
      it { is_expected.to have_resource_count(1) }

      it do
        is_expected.to contain_sysctl('vm.swappiness').with(
          {
            'ensure' => 'present',
            'value'  => 60,
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

    context 'with swappiness set to valid 3' do
      let(:params) { { swappiness: 3 } }

      it { is_expected.to contain_sysctl('vm.swappiness').with_value(3) }
    end

    describe 'variable type and content validations' do
      validations = {
        'Integer[0,100]' => {
          name:    ['swappiness'],
          valid:   [0, 3, 100],
          invalid: [-1, 101, 'string', ['array'], { 'ha' => 'sh' }, 2.42, nil],
          message: 'expects an Integer(\[0, 100\])?',
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
