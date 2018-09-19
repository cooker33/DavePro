;usage:
;deg2sex,[198.032,28.32]
;deg2sex,'radec_deg.dat',/file

pro deg2sex,input,file=file

if (input eq !NULL) then begin
    print,'####################################'
    print,'usage: idl> deg2sex,[198.032,28.32]'
    print,'or'
    print,"idl> deg2sex,'radec_deg.dat',/file"
    print,'####################################'
    stop
endif

if (keyword_set(file) eq 1) then begin
  readcol,input,ra,dec
endif else begin
  ra=input[0]
  dec=input[1]
endelse

radec, ra, dec, rah,ram, ras, decd,decm , decs

forprint,textout=2,rah,ram, ras, decd,decm , decs,$
         f='(i02,1x,i02,1x,f05.2,2x,i02,1x,i02,1x,f04.1)'


stop
end
