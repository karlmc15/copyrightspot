module Hpricot
  module Traverse
    
    oper_procs =
      {'='      => proc { |a,b| a == b },
       '!='     => proc { |a,b| a != b },
       '~='     => proc { |a,b| a.split(/\s+/).include?(b) },
       '|='     => proc { |a,b| a =~ /^#{Regexp::quote b}(-|$)/ },
       '^='     => proc { |a,b| a.index(b) == 0 },
       '$='     => proc { |a,b| a =~ /#{Regexp::quote b}$/ },
       '*='     => proc { |a,b| idx = a.index(b) },
       ':='     => proc { |a,b| a =~ /#{Regexp::quote b}(-|$)/ }}
    
  end
end