require 'spec_helper_acceptance'

describe 'swap_file', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do

  context 'apt::source' do
    context 'ensure => present' do
      it 'should work with no errors' do
        pp = <<-EOS
        class { 'swap_file': }
        EOS

        # Run it twice and test for idempotency
        expect(apply_manifest(pp).exit_code).to_not eq(1)
        expect(apply_manifest(pp).exit_code).to eq(0)
      end
    end
  end
end
