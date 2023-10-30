# A defined type to resize an existing swapfile
#
# @example
#   swap_file::resize { '/mnt/swap.1:
#     swapfile_path          => '/mnt/swap.1',
#     margin                 => '500 MB',
#     expected_swapfile_size => '1 GB,
#   }
#
# @param swapfile_path
#   Path to the swapfile
#
# @param expected_swapfile_size
#   Expected size of the swapfile
#
# @param actual_swapfile_size
#   Actual size of the swapfile
#
# @param margin
#   Margin that is checked before resizing the swapfile
#
# @param verbose
#   Adds a notify to explain why the change was made
#
# @author - Peter Souter
#
define swap_file::resize (
  String  $swapfile_path,
  String  $expected_swapfile_size,
  String  $actual_swapfile_size,
  String  $margin                  = '50MB',
  Boolean $verbose                 = false,
) {
  $margin_bytes                  = to_bytes($margin)
  $existing_swapfile_bytes       = to_bytes("${actual_swapfile_size}kb")
  $expected_swapfile_size_bytes  = to_bytes($expected_swapfile_size)

  if !($expected_swapfile_size_bytes == $existing_swapfile_bytes) {
    if !(difference_within_margin([$existing_swapfile_bytes, $expected_swapfile_size_bytes],$margin_bytes)) {
      if ($verbose) {
        $alert_message = "Existing : ${existing_swapfile_bytes}B\nExpected: ${expected_swapfile_size_bytes}B\nMargin: ${margin_bytes}B"
        notify { "Resizing Swapfile Alert ${swapfile_path}":
          name => $alert_message,
        }
      }
      exec { "Detach swap file ${swapfile_path} for resize":
        command => "/sbin/swapoff ${swapfile_path}",
        onlyif  => "/sbin/swapon -s | grep ${swapfile_path}",
      } -> exec { "Purge ${swapfile_path} for resize":
        command => "/bin/rm -f ${swapfile_path}",
        onlyif  => "test -f ${swapfile_path}",
        path    => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/'],
      }
    }
  }
}
