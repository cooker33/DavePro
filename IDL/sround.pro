;usage> result=sround(input,place)
;input is a float or double
;place is the number of "decimal" places you want to round to
;ex. round
;x=54.362
;print,sround(x,0)  --> 54.00
;print,sround(x,1)  --> 54.40
;print,sround(x,2)  --> 54.36

function sround,input,place  
  
  result=dblarr(n_elements(input))
  nanind=where(finite(input) eq 0)
  if (nanind(0) ne -1) then begin
    input[nanind]=0. ;NaNs; set to zero
  endif
    
  if (place eq 0) then begin
    result=round(input)
  endif else if (place lt 0) then begin
    print,'cannot use negative decimal places'
    stop
  endif else begin
    shift=input*10.^place
    temp=round(shift)
    result=temp/10.^place
  endelse
   
return,result
end
