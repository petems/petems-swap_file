if File.exists?('/proc/swaps')
  swap_file_hash = {}

  swap_file_output = Facter::Util::Resolution.exec('cat /proc/swaps')

    # Sample Output
    # Filename                                Type    Size  Used  Priority
    # /mnt/swap.1                             file    1019900 0 -1
    # /tmp/swapfile.fallocate                 file    1019900 0 -2
    swap_file_output_array = swap_file_output.split("\n")

    # Remove the header line
    swap_file_output_array.shift

    swap_file_output_array.each do |line|

      swap_file_line_array = line.gsub(/\s+/m, ' ').strip.split(" ")

      swap_file_hash[swap_file_line_array[0]] = swap_file_line_array[2]

    end

    Facter.add('swapfile_sizes') do
      confine :kernel => 'Linux'
      setcode do
        swap_file_hash
      end
    end

end
