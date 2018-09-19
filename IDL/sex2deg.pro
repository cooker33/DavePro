;usage:
;sex2deg,['12:15:51.7','44:21:13.2']
;sex2deg,'radec_deg.dat',/file

pro sex2deg,input,file=file

if (input eq !NULL) then begin
    print,'####################################'
    print,'usage: idl> sex2deg,[198.032,28.32]'
    print,'or'
    print,"idl> sex2deg,'radec_deg.dat',/file"
    print,'####################################'
    stop
endif

if (keyword_set(file) eq 1) then begin
    readcol,input,rah,ram, ras, decd,decm , decs
endif else begin
    rah=(strsplit(input[0],':',/extract))(0)
    ram=(strsplit(input[0],':',/extract))(1)
    ras=(strsplit(input[0],':',/extract))(2)
    decd=(strsplit(input[1],':',/extract))(0)
    decm=(strsplit(input[1],':',/extract))(1)
    decs=(strsplit(input[1],':',/extract))(2)
endelse

ra, dec, rah,ram, ras, decd,decm , decs

forprint,textout=2,rah,ram, ras, decd,decm , decs,$
         f='(i02,1x,i02,1x,f05.2,2x,i02,1x,i02,1x,f04.1)'


stop
end
