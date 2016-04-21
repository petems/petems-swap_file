require "spec_helper"

describe Facter::Util::Fact do
  before {
    Facter.clear
  }

  describe 'swap_files' do
    context 'returns swap_files when present' do
      before do
        Facter.fact(:kernel).stubs(:value).returns("Linux")
        File.stubs(:exists?)
        File.expects(:exists?).with('/proc/swaps').returns(true)
        Facter::Util::Resolution.stubs(:exec)
      end
      it do
        proc_swap_output = <<-EOS
Filename        Type    Size  Used  Priority
/mnt/swap.1                             file    1019900 0 -1
/tmp/swapfile.fallocate                 file    1019900 0 -2
        EOS
        Facter::Util::Resolution.expects(:exec).with('cat /proc/swaps').returns(proc_swap_output)
        expect(Facter.value(:swap_file_sizes)).to eq(
          {
            "/mnt/swap.1"=>"1019900",
            "/tmp/swapfile.fallocate"=>"1019900"
          }
        )
      end
    end

  end
end
