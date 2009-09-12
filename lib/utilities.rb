require 'iconv'

module Utilities
  
  def self.decode_string(string)
    case string
      when /^\xEF\xBB\xBF/
        string = string.sub("\xEF\xBB\xBF", '')
      when /^\xFE\xFF/
        arr = string.unpack('n*')
        arr.shift
        string = arr.pack('U*')
      when /^\xFF\xFE/
        arr = string.unpack('v*')
        arr.shift
        string = arr.pack('U*')
      when /^\x00B/i
        string = string.unpack('n*').pack('U*')
      when /^B\x00/i
        string = string.unpack('v*').pack('U*')
    end
    string
  end
  
end

class String
  
  def to_iso
    Iconv.conv('ISO-8859-1', 'utf-8', self)
  end
  
end