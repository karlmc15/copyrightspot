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
  
  def to_ascii
    # split in muti-byte aware fashion and translate characters over 127
    # and dropping characters not in the translation hash
    self.chars.split('').collect { |c| (c[0] <= 127) ? c : translation_hash[c[0]] }.join
  end
  
  protected
  
  def translation_hash
    @@translation_hash ||= setup_translation_hash      
  end
  
  def setup_translation_hash
    accented_chars   = "ÀÁÂÃÄÅÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝàáâãäåçèéêëìíîïñòóôõöøùúûüý".chars.split('')
    unaccented_chars = "AAAAAACEEEEIIIIDNOOOOOxOUUUUYaaaaaaceeeeiiiinoooooouuuuy".split('')

    translation_hash = {}
    accented_chars.each_with_index { |char, idx| translation_hash[char[0]] = unaccented_chars[idx] }
    translation_hash["Æ".chars[0]] = 'AE'
    translation_hash["æ".chars[0]] = 'ae'
    translation_hash
  end
  
end