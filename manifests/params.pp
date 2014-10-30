# == Class swap_file::params
#
# This class is meant to be called from swap_file
# It sets variables according to platform
#
class swap_file::params {
  case $::osfamily {
    'Debian': {

    }
    'RedHat': {

    }
    'windows': {
      fail('Swap files dont work on windows')
    }
    'FreeBSD': {
      fail('FreeBSD is not yet supported')
    }
    default: {
      warning("${::operatingsystem} not officially supported, but should work")
    }
  }
}
