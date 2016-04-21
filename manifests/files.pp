# Define: swap_file::files
#
# This is a defined type to create a swap_file
#
# == Parameters
# [*ensure*]
#   Allows creation or removal of swapspace and the corresponding file.
# [*swapfile*]
#   Location of swapfile, defaults to /mnt
# [*swapfilesize*]
#   Size of the swapfile as a string (eg. 10 MB, 1.2 GB).
#   Defaults to $::memorysize fact on the node
# [*add_mount*]
#   Add a mount to the swapfile so it persists on boot
# [*options*]
#   Mount options for the swapfile
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
#
# == Authors
#    @petems - Peter Souter
#
define swap_file::files (
  $ensure        = 'present',
  $swapfile      = '/mnt/swap.1',
  $swapfilesize  = $::memorysize,
  $add_mount     = true,
  $options       = 'defaults',
  $timeout       = 300,
  $cmd           = 'dd',
)
{
  # Parameter validation
  validate_re($ensure, ['^absent$', '^present$'], "Invalid ensure: ${ensure} - (Must be 'present' or 'absent')")
  validate_string($swapfile)
  $swapfilesize_mb = to_bytes($swapfilesize) / 1048576
  validate_bool($add_mount)

  if $ensure == 'present' {
    unless defined(Exec["Create swap file ${swapfile}"]) {
      exec { "Create swap file ${swapfile}":
        creates => $swapfile,
        timeout => $timeout,
      }
    }
    case $cmd {
      'dd': {
        Exec["Create swap file ${swapfile}"] { command => "/bin/dd if=/dev/zero of=${swapfile} bs=1M count=${swapfilesize_mb}" }
      }
      'fallocate': {
        Exec["Create swap file ${swapfile}"] { command => "/usr/bin/fallocate -l ${swapfilesize_mb}M ${swapfile}" }
      }
      default: {
        fail("Invalid cmd: ${cmd} - (Must be 'dd' or 'fallocate')")
      }
    }
    # Check if swapfile needs resize
    unless $::swap_file_size == 0 {
      if $::swap_file_size != $swapfilesize {
        # Only attempt resize if swapfile is unused
        if $::swapfree == $::swapsize {
          unless defined(Notify['Swap is unused, continuing to resize swapfile']) {
            notify {'Swap is unused, continuing to resize swapfile':
              before  => Exec["Detach swap file ${swapfile} for resize"],
            }
          }
          exec { "Detach swap file ${swapfile} for resize":
            command => "/sbin/swapoff ${swapfile}",
            onlyif  => "/sbin/swapon -s | grep ${swapfile}",
          }
          exec { "Purge ${swapfile} for resize":
            command => "/bin/rm -f ${swapfile}",
            onlyif  => "/bin/test -f ${swapfile}",
            require => Exec["Detach swap file ${swapfile} for resize"],
            before  => Exec["Create swap file ${swapfile}"],
          }
          notify {"${swapfile} will now be created with new size: ${swapfilesize_mb}":
            require => Exec["Purge ${swapfile} for resize"],
            before  => Exec["Create swap file ${swapfile}"],
          }
          unless defined(Exec["Create swap file ${swapfile}"]) {
            exec { "Create swap file ${swapfile}":
              creates => $swapfile,
              timeout => $timeout,
              require => Exec["Purge ${swapfile} for resize"],
            }
          }
        } else {
          notify {"${swapfile} is currently in use and cannot be resized!": }
        }
      }
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
