;this will check to see if a number (aka, flag) has the bit (aka bit)
;in it. This works via an AND operation:
;16 8  4  2  1                 
;#  #  #  #  #                 
;0  0  0  0  1  = the number 1 
;0  0  0  1  1  = 0*16 + 0*8 + 0*4 + 1*2 + 1*1 = 3 
;1  0  0  1  0  = 18
;
;AND operation
;0  0  1  0  1  (#=5)
;0  0  1  1  0  (#=6)
;-------------  AND
;0  0  1  0  0  = 4
;
;if one of the the numbers in the AND operation is a binary bit (i.e., 1,2,4,8,16, etc))
;the AND operation will return that bit if it is a base bit of the other number.
;ex:
;0  1  0  0  0  (#=8)
;1  1  0  1  1  (#=27)
;-------------  AND
;0  1  0  0  0  = 8
;
;usage:
;result=bit_check(flag,bit)
;
;bit - the bit to be checked against a flag number 
;(ex: check to see if flag 27 contains the bit 8)
;
;result=1 if the flag contains the bit and result=0 if not

function bit_check,flag,bit
  ;flag and bit need to be integers
  if (size(bit,/type) ne 2 and size(bit,/type) ne 3 and size(bit,/type) ne 12 and size(bit,/type) ne 13 and size(bit,/type) ne 14 and size(bit,/type) ne 15) then begin
    print,'please pass an integer bit input...Try again.'
    stop
  endif
  if (size(flag,/type) ne 2 and size(flag,/type) ne 3 and size(flag,/type) ne 12 and size(flag,/type) ne 13 and size(flag,/type) ne 14 and size(flag,/type) ne 15) then begin
    print,'please pass an integer flag input...Try again.'
    stop
  endif
  
  ;in case of an array of flags
  nflag=n_elements(flag)
  bit_in=bit
  bit=intarr(nflag)+bit_in(0)

  return,(flag AND bit) EQ bit

end
