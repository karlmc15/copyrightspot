# Buffer structure.
#
class Tidybuf

  # Mimic TidyBuffer.
  # 
  # This Hack is needed for the 64-bit tidy lib on debian has different structure then all other versions
  TidyBuffer = struct [
    "int* allocator",
    "byte* bp",
    "uint size",
    "uint allocated",
    "uint next"
  ]

end
