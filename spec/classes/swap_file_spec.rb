require 'spec_helper'

describe 'swap_file' do

  context 'supported operating systems' do
    ['Debian', 'RedHat'].each do |osfamily|
      describe "swap_file class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily, :memorysize => '992.65 MB',
        }}

        it { should compile.with_all_deps }

        it { should contain_class('Swap_file::Params') }
        it { should contain_class('Swap_file') }

        it { should contain_exec('Create swap file').
              with_command('/bin/dd if=/dev/zero of=/mnt/swap.1 bs=1M count=1040')
            }
        it { should contain_exec('Attach swap file') }
      end
    end
  end

  context 'unsupported operating system' do
    describe 'swap_file class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'windows',
        :operatingsystem => 'windows',
      }}

      it { expect { should contain_class('swap_file') }.to raise_error(Puppet::Error, /windows not supported/) }
    end
  end
end
