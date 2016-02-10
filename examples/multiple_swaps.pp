node default {
  class { 'swap_file':
    files => {
      'swapfile' => {
        ensure => 'present',
      },
      'use fallocate' => {
        swapfile => '/tmp/swapfile.fallocate',
        cmd      => 'fallocate',
      },
      'remove swap file' => {
        ensure   => 'absent',
        swapfile => '/tmp/swapfile.old',
      },
    },
  }
}
