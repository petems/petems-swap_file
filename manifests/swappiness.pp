# Allows setting the kernel swappiness setting
#
# @example Will set the sysctl setting for swappiness to 75
#   class { '::swap_file::swappiness':
#     swappiness => 75,
#   }
#
# @param [String] swapiness Swapiness level, integer from 0 - 100 inclusive
#
# @author - Peter Souter
#
class swap_file::swappiness (
  Integer[0,100] $swappiness = 60,
) {
  sysctl { 'vm.swappiness':
    ensure => 'present',
    value  => $swappiness,
  }
}
