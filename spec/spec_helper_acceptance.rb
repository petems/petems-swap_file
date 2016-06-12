require 'beaker-rspec'

unless ENV['RS_PROVISION'] == 'no'
  hosts.each do |host|
    if host.is_pe?
      install_pe
    else
      if host['platform'] =~ /freebsd/
        # Beaker tries to install sysutils/puppet
        # It's now been renamed to sysutils/puppet38
        host.install_package('sysutils/puppet38')
      else
        install_puppet
      end
      on host, "mkdir -p #{host['distmoduledir']}"
    end
  end
end

# Most tests wont work on FreeBSD, make 1 specific FreeBSD spec
UNSUPPORTED_PLATFORMS = ['windows','freebsd']

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'swap_file')
    hosts.each do |host|
      shell('puppet module install puppetlabs-stdlib --version 4.7.0', { :acceptable_exit_codes => [0] })
      shell('puppet module install fiddyspence-sysctl --version 1.1.0', { :acceptable_exit_codes => [0] })
    end
  end
end
