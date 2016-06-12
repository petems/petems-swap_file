# Define: swap_file::freebsd
#
# This is a defined type to create a swap_file on a FreeBSD system
#
# == Parameters
# [*ensure*]
#   Allows creation or removal of swapspace and the corresponding file.
# [*swapfile*]
#   Location of swapfile, defaults to /mnt
# [*swapfilesize*]
#   Size of the swapfile as a string (eg. 10 MB, 1.2 GB).
#   Defaults to $::memorysize fact on the node
# [*timeout*]
#   dd command exec timeout.
#   Defaults to 300
# [*cmd*]
#   What command is used to create the file, dd or fallocate. dd is better tested and safer but fallocate is significantly faster.
#   Defaults to dd
#
# == Examples
#
#   swap_file::files { 'default':
#     ensure   => present,
#     swapfile => '/mnt/swap.55',
#   }
#
# == Authors
#    @petems - Peter Souter
#
define swap_file::freebsd (
  $ensure        = 'present',
  $swapfile      = '/mnt/swap.1',
  $swapfilesize  = $::memorysize,
  $timeout       = 300,
  $cmd           = 'dd',
)
{
  # Parameter validation
  validate_re($ensure, ['^absent$', '^present$'], "Invalid ensure: ${ensure} - (Must be 'present')")
  validate_string($swapfile)
  $swapfilesize_mb = to_bytes($swapfilesize) / 1048576

  if $ensure == 'present' {

    exec { "Create swap file ${swapfile}":
      creates => $swapfile,
      timeout => $timeout,
    }
    case $cmd {
      'dd': {
        Exec["Create swap file ${swapfile}"] { command => "/bin/dd if=/dev/zero of=${swapfile} bs=1M count=${swapfilesize_mb}" }
      }
      default: {
        fail("Invalid cmd: ${cmd} - (Must be 'dd')")
      }
    }

    file { $swapfile:
      owner   => 0,
      group   => 0,
      mode    => '0600',
      require => Exec["Create swap file ${swapfile}"],
    }

    mount { 'none':
      device  => 'md99',
      dump    => '0',
      fstype  => 'swap',
      options => "sw,file=${swapfile}",
      pass    => '0',
      require => File[$swapfile],
    }

    exec { '/sbin/swapon -aq':
      refreshonly => true,
      subscribe   => Mount['none'],
    }
  }
}
