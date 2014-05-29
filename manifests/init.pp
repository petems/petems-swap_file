# Class: swap_file
#
# This class manages swapspace on a node.
#
# == Parameters
# [*ensure*]
#   Allows creation or removal of swapspace and the corresponding file.
# [*swapfile*]
#   Location of swapfile, defaults to /mnt
# [*swapfilesize*]
#   Size of the swapfile in MB. Defaults to $::memorysize fact on the node
#
# Actions:
#   Creates and mounts a swapfile.
#   Umounts and removes a swapfile.
#
# Requires:
#   memorysizeinbytes fact - See:
#   https://blog.kumina.nl/2011/03/facter-facts-for-memory-in-bytes/
#
# == Examples
#
#   include swap_file
#
#   class { 'swap_file':
#     ensure => present,
#   }
#
#   class { 'swap_file':
#     swapfile => '/mount/swapfile',
#     swapfilesize => '100 MB',
#   }
#
# == Authors
#    @petems - Peter Souter
#    @Yggdrasil
class swap_file (
  $ensure        = 'present',
  $swapfile      = '/mnt/swap.1',
  $swapfilesize  = to_bytes($::memorysize) / 1000000
) inherits swap_file::params {
  if $ensure == 'present' {
      exec { 'Create swap file':
        command => "/bin/dd if=/dev/zero of=${swapfile} bs=1M count=${swapfilesize}",
        creates => $swapfile,
      }
      exec { 'Attach swap file':
        command => "/sbin/mkswap ${swapfile} && /sbin/swapon ${swapfile}",
        require => Exec['Create swap file'],
        unless  => "/sbin/swapon -s | grep ${swapfile}",
      }
    }
  elsif $ensure == 'absent' {
    exec { 'Detach swap file':
      command => "/sbin/swapoff ${swapfile}",
      onlyif  => "/sbin/swapon -s | grep ${swapfile}",
    }
    file { $swapfile:
      ensure  => absent,
      require => Exec['Detach swap file'],
    }
  }
}