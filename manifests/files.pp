# Define: swap_file::files
#
# This is a defined type to create a swap_file
#
# @param ensure
#   Allows creation or removal of swapspace and the corresponding file.
#
# @param swapfile
#   Location of swapfile, defaults to /mnt
#
# @param swapfilesize
#   Size of the swapfile as a string (eg. 10 MB, 1.2 GB).
#   Defaults to $::memorysize fact on the node
#
# @param add_mount
#   Add a mount to the swapfile so it persists on boot
#
# @param options
#   Mount options for the swapfile
#
# @param timeout
#   dd command exec timeout.
#   Defaults to 300
#
# @param cmd
#   What command is used to create the file, dd or fallocate. dd is better tested and safer but fallocate is significantly faster.
#   Defaults to dd
#
# @param resize_existing
#   Boolean to choose if existing swap files should get resized.
#
# @param resize_margin
#   Margin that is checked before resizing the swapfile.
#
# @param resize_verbose
#   Boolean to choose if a notify message to explain the change should be added.
#
# @examples
#   swap_file::files { 'default':
#     ensure   => present,
#     swapfile => '/mnt/swap.55',
#   }
#
# @author
#    @petems - Peter Souter
#
define swap_file::files (
  Enum['present', 'absent'] $ensure          = 'present',
  Stdlib::Absolutepath      $swapfile        = '/mnt/swap.1',
  String[1]                 $swapfilesize    = $facts['memory']['system']['total'],
  Boolean                   $add_mount       = true,
  String[1]                 $options         = 'defaults',
  Integer                   $timeout         = 300,
  Enum['dd', 'fallocate']   $cmd             = 'dd',
  Boolean                   $resize_existing = false,
  String[1]                 $resize_margin   = '50MB',
  Boolean                   $resize_verbose  = false,
) {
  $swapfilesize_mb = to_bytes($swapfilesize) / 1048576

  if $ensure == 'present' {
    # Check for resizing the swap file
    if $resize_existing and $facts['swapfile_sizes'] {
      # use $swapfile_sizes for new or $swapfile_sizes_csv as fallback for old Puppet clients
      $existing_swapfile_size = swap_file_size_from_csv($swapfile,$facts['swapfile_sizes_csv'])
      if $swapfile in $facts['swapfile_sizes'] {
        $actual_swapfile_size = $facts['swapfile_sizes'][$swapfile]
      } elsif $existing_swapfile_size {
        $actual_swapfile_size = $existing_swapfile_size
      } else {
        $actual_swapfile_size = undef
      }

      if $actual_swapfile_size {
        swap_file::resize { $swapfile:
          swapfile_path          => $swapfile,
          margin                 => $resize_margin,
          expected_swapfile_size => $swapfilesize,
          actual_swapfile_size   => $actual_swapfile_size,
          verbose                => $resize_verbose,
          before                 => Exec["Create swap file ${swapfile}"],
        }
      }
    }

    # Determine the command based on $cmd
    case $cmd {
      'dd':    { $csf_command = "/bin/dd if=/dev/zero of=${swapfile} bs=1M count=${swapfilesize_mb}" }
      default: { $csf_command = "/usr/bin/fallocate -l ${swapfilesize_mb}M ${swapfile}" }
    }

    # Determine $swapfile_seltype based on SELinux status
    case $facts['os']['selinux']['enabled'] {
      true:    { $swapfile_seltype = 'swapfile_t' }
      default: { $swapfile_seltype = undef }
    }

    # Create the swap file
    exec { "Create swap file ${swapfile}":
      command => $csf_command,
      creates => $swapfile,
      timeout => $timeout,
    }

    file { $swapfile:
      owner   => root,
      group   => root,
      mode    => '0600',
      seltype => $swapfile_seltype,
      require => Exec["Create swap file ${swapfile}"],
    }

    swap_file { $swapfile:
      ensure  => 'present',
      require => File[$swapfile],
    }

    # Add mount if required
    if $add_mount {
      mount { $swapfile:
        ensure  => present,
        fstype  => swap,
        device  => $swapfile,
        options => $options,
        dump    => 0,
        pass    => 0,
        require => Swap_file[$swapfile],
      }
    }
  } else {
    # Remove the swap file, file, and mount
    swap_file { $swapfile:
      ensure  => 'absent',
    }

    file { $swapfile:
      ensure  => absent,
      backup  => false,
      require => Swap_file[$swapfile],
    }

    mount { $swapfile:
      ensure => absent,
      device => $swapfile,
    }
  }
}
