# swap_file::files - Used for managing swapfiles and their mounts
#
# @author Peter Souter and petems-swap_file contributors. Based on the original work by Matt Dainty
#
# @param ensure  [String] Allows creation or removal of swapspace and the corresponding file.
# @param swapfile [String]   Location of swapfile, defaults to /mnt
# @param swapfilesize [Integer]  Size of the swapfile as a string (eg. 10 MB, 1.2 GB). Defaults to $::memorysize fact on the node
# @param add_mount [Boolean] Add a mount to the swapfile so it persists on boot
# @param options [String] Mount options for the swapfile, defaults to 'defaults'
# @param timeout [Integer] Timeout time for the dd command to create a file, defaults to 300 seconds
#
# @example Default - This will by create a swapfile with the default size of the $::memorysize fact
#   swap_file::files { 'default':
#     ensure   => present,
#   }
#
# @example Change the swapfile location
#   swap_file::files { 'tmp location':
#     ensure   => present,
#     swapfile => '/tmp/swap_file',
#   }
#
# @example Change the swapfile size
#   swap_file::files { '512MB Swap':
#     ensure       => present,
#     swapfilesize => '512mb',
#   }
#
define swap_file::files (
  $ensure        = 'present',
  $swapfile      = '/mnt/swap.1',
  $swapfilesize  = $::memorysize,
  $add_mount     = true,
  $options       = 'defaults',
  $timeout       = 300
)
{

  # Parameter validation
  validate_re($ensure, ['^absent$', '^present$'], "Invalid ensure: ${ensure} - (Must be 'present' or 'absent')")
  validate_string($swapfile)
  $swapfilesize_mb = to_bytes($swapfilesize) / 1000000
  validate_bool($add_mount)

  if $ensure == 'present' {
    exec { "Create swap file ${swapfile}":
      command => "/bin/dd if=/dev/zero of=${swapfile} bs=1M count=${swapfilesize_mb}",
      creates => $swapfile,
      timeout => $timeout,
    }
    file { $swapfile:
      owner   => root,
      group   => root,
      mode    => '0600',
      require => Exec["Create swap file ${swapfile}"],
    }
    exec { "Attach swap file ${swapfile}":
      command => "/sbin/mkswap ${swapfile} && /sbin/swapon ${swapfile}",
      require => File[$swapfile],
      unless  => "/sbin/swapon -s | grep ${swapfile}",
    }
    if $add_mount {
      mount { $swapfile:
        ensure  => present,
        fstype  => swap,
        device  => $swapfile,
        options => $options,
        dump    => 0,
        pass    => 0,
        require => Exec["Attach swap file ${swapfile}"],
      }
    }
  }
  elsif $ensure == 'absent' {
    exec { "Detach swap file ${swapfile}":
      command => "/sbin/swapoff ${swapfile}",
      onlyif  => "/sbin/swapon -s | grep ${swapfile}",
    }
    file { $swapfile:
      ensure  => absent,
      backup  => false,
      require => Exec["Detach swap file ${swapfile}"],
    }
    mount { $swapfile:
      ensure => absent,
      device => $swapfile,
    }
  }

}
