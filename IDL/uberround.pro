function uberround,input,place,string=string
  compile_opt idl2

  if n_params() lt 2 then begin
     print,' '
     print,'  ERROR: MUST INPUT SCALAR OR ARRAY'
     print,'  AND THE DECIMAL PLACE THAT THE ARRAY'
     print,'  SHOULD BE ROUNDED TO.'
     print,' '
     res=-99
  endif else begin
     if place le 0 then begin
        print,' '
        print,'  ERROR: THE DECIMAL PLACE THAT THE'
        print,'  INPUT ARRAY SHOULD BE ROUNDED TO'
        print,'  MUST BE AN INTEGER GREATER THAN 0.'
        print,' '
        res=-99
     endif
     arr=strtrim(string(double(input)),2)
     res=dblarr(n_elements(arr))
     for i=0, n_elements(arr)-1 do begin
        dec=strpos(arr,'.')
        tmp=double(strmid(arr[i],dec+place,1))
        if tmp ge 0 and tmp le 4 then begin
           res[i]=double(strmid(strtrim(string(arr[i]),2),0,dec+place+1))+10.^(-place)
        endif else begin
           res[i]=double(strmid(strtrim(string(arr[i]),2),0,dec+place+1))
        endelse
     endfor
  endelse
  if keyword_set(string) then begin
     res=strtrim(string(res),2)
     for i=0,n_elements(res)-1 do begin
        dec=strpos(res[i],'.')
        res[i]=strmid(res[i],0,dec+place+1)
     endfor
  endif
  return,res

end
