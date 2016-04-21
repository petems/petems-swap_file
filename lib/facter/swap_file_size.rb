Facter.add('swap_file_size') do
  confine :kernel => :linux
  setcode do
    swap_file_size = 0
    if File.exists?('/proc/swaps')
      File.open('/proc/swaps', 'r').each_line do |line|
        # Find first swapfile entry
        swap_file = $1 if line.match(/^(\/.[\/\-_.A-Za-z0-9]*)/)
        next if swap_file.nil?
        if File.exist?(swap_file)
          size = File.stat(swap_file).size
          swap_file_size = (size / 1073741824.0).round(2) if size
        end
        break if ! swap_file.nil?
      end
    end
    Facter::Memory.scale_number(swap_file_size.to_f, "GB")
  end
end
