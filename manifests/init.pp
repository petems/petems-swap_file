# Class: swap
class swap_file (
    $ensure         = 'present',
    $swapfile       = '/mnt/swap.1',
    $swapfilesize   = to_bytes($::memorysize) / 1000000
) inherits swap_file::params {
    if $ensure == 'present' {
        exec { 'Create swap file':
            command     => "/bin/dd if=/dev/zero of=${swapfile} bs=1M count=${swapfilesize}",
            creates     => $swapfile,
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