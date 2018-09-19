function change_name,input_name

;execute: name_new=change_name(input_name)

ngal=n_elements(input_name)
input_name_new=input_name

for i=0, ngal-1 do begin
  
  if (strmatch(input_name[i],'*__') eq 1) then begin
    input_name[i]=(strsplit(input_name[i],'_',/extract))(0)
    input_name_new[i]=(strsplit(input_name[i],'_',/extract))(0)
  endif
  
  if strmatch(input_name[i],'K*__*',/fold_case) then begin
    print,input_name[i],input_name_new[i]
    stop
  endif
  if (strmatch(input_name[i],'ngc*',/fold_case)) then begin
    length=strlen( strtrim(input_name[i],2))
    num=strsplit(input_name[i],'ngc',/extract,/regex,/fold_case)
    if (length eq 6) then begin
      ;print,input_name[i],'NGC0'+num
      input_name_new[i]='NGC0'+num
    endif
    if (length eq 5) then begin
      ;print,input_name[i],'NGC00'+num
      input_name_new[i]='NGC00'+num
    endif   
  endif
  
  if (strmatch(input_name[i],'ugc*',/fold_case) eq 1) then begin

    if (strmatch(input_name[i],'ugca*',/fold_case)) then begin
      length=strlen( strtrim(input_name[i],2))
      num=strsplit(input_name[i],'ugca',/extract,/regex,/fold_case)
      if (length eq 6) then begin
        ;print,input_name[i],'UGCA0'+num
        input_name_new[i]='UGCA0'+num
      endif
      if (length eq 5) then begin
        ;print,input_name[i],'UGCA00'+num
        input_name_new[i]='UGCA00'+num
      endif
       
    endif else begin
      length=strlen( strtrim(input_name[i],2))
      num=strsplit(input_name[i],'ugc',/extract,/regex,/fold_case)
      if (length eq 7) then begin
        ;print,input_name[i],'UGC0'+num
        input_name_new[i]='UGC0'+num
      endif
      if (length eq 6) then begin
        ;print,input_name[i],'UGC00'+num
        input_name_new[i]='UGC00'+num
      endif
      if (length eq 5) then begin
        ;print,input_name[i],'UGC000'+num
        input_name_new[i]='UGC000'+num
      endif  
       
    endelse

  endif
  
  if (strmatch(input_name[i],'*fm*',/fold_case)) then begin
    input_name_new[i]='FM2000-1'
  endif

  if (strmatch(input_name[i],'am*1001*',/fold_case)) then begin
    input_name_new[i]='AM1001-270'
  endif

  if (strmatch(input_name[i],'*hs*',/fold_case)) then begin
    input_name_new[i]='HS98-117'
  endif

  if (strmatch(input_name[i],'*kk*208*',/fold_case)) then begin
      input_name_new[i]='KK98-208'
  endif
  
  if (strmatch(input_name[i],'*kk*230*',/fold_case)) then begin
      input_name_new[i]='KK98-230'
  endif
  
  if (strmatch(input_name[i],'kkh*',/fold_case)) then begin
    num=strsplit(input_name[i],'kkh',/extract,/regex,/fold_case)
    length=strlen( strtrim(input_name[i],2))
    if (length eq 5) then begin
      input_name_new[i]='KKH0'+num
    endif else begin
      input_name_new[i]='KKH'+num      
    endelse
  endif

  if (strmatch(input_name[i],'bk*',/fold_case)) then begin
    num=strsplit(input_name[i],'bk',/extract,/regex,/fold_case)
    length=strlen( strtrim(input_name[i],2))
    if (length eq 4) then begin
      input_name_new[i]='BK0'+STRUPCASE(num)
    endif
  endif

  if (strmatch(input_name[i],'*kdg*',/fold_case)) then begin
    num=strsplit(input_name[i],'0',/extract,/regex,/fold_case)
    
    if (strmatch(input_name[i],'*kdg*52*',/fold_case) eq 1 or strmatch(input_name[i],'*m*81*d*',/fold_case) eq 1) then begin
      input_name_new[i]='M81dwA'    
    endif else if (n_elements(num) eq 1) then begin
      ;name is correct
    endif else begin
      input_name_new[i]=num(0)+num(1)
    endelse
  endif

  if (strmatch(input_name[i],'m*104*',/fold_case)) then begin
    input_name_new[i]='NGC4594'
  endif

  if (strmatch(input_name[i],'m*81*',/fold_case) eq 1 and strmatch(input_name[i],'*m*81*d*',/fold_case) eq 0) then begin
    input_name_new[i]='NGC3031'
  endif

  if (strmatch(input_name[i],'m*82*',/fold_case)) then begin
    input_name_new[i]='NGC3034'
  endif

  if (strmatch(input_name[i],'sculptor*',/fold_case)) then begin
    input_name_new[i]='Sculptor-dE1'
  endif
  
  if (strmatch(input_name[i],'*m33*',/fold_case)) then begin
    input_name_new[i]='NGC0598'
  endif
  
  if (strmatch(input_name[i],'*sex*b*',/fold_case)) then begin
    input_name_new[i]='UGC05373'
  endif
  
  if (strmatch(input_name[i],'*sex*a*',/fold_case)) then begin
    input_name_new[i]='SextansA'
  endif
  
  if (strmatch(input_name[i],'*gr8*',/fold_case)) then begin
    input_name_new[i]='UGC08091'
  endif
  
  if (strmatch(input_name[i],'*hoIX',/fold_case) eq 1) then begin
    input_name_new[i]='UGC05336'    
  endif
  
  if (strmatch(input_name[i],'*hoII',/fold_case) eq 1 or $
      strmatch(input_name[i],'*ho2',/fold_case) eq 1) then begin
    input_name_new[i]='UGC04305'    
  endif
  
  if (strmatch(input_name[i],'*hoI',/fold_case) eq 1 or $
      strmatch(input_name[i],'*ho1',/fold_case) eq 1) then begin
    input_name_new[i]='UGC05139'    
  endif
  
  if (strmatch(input_name[i],'*arp*loop*',/fold_case)) then begin
    input_name_new[i]='Arpsloop'
  endif
  
  if (strmatch(input_name[i],'*antlia*',/fold_case)) then begin
    input_name_new[i]='AM1001-270'
  endif
  
  if (strmatch(input_name[i],'*ddo*06*',/fold_case)) then begin
    input_name_new[i]='UGCA015'
  endif
  
  if (strmatch(input_name[i],'*ddo*82*',/fold_case)) then begin
    input_name_new[i]='UGC05692'
  endif
  
  if (strmatch(input_name[i],'*ddo*226*',/fold_case)) then begin
    input_name_new[i]='IC1574'
  endif
  
  if (strmatch(input_name[i],'*ddo*78*',/fold_case)) then begin
    input_name_new[i]='DDO078'
  endif
  
  if (strmatch(input_name[i],'*ddo*113*',/fold_case)) then begin
    input_name_new[i]='UGCA276'
  endif
  
  if (strmatch(input_name[i],'*ddo*126*',/fold_case)) then begin
    input_name_new[i]='UGC07559'
  endif
  
  if (strmatch(input_name[i],'*ddo*154*',/fold_case)) then begin
    input_name_new[i]='UGC08024'
  endif
  
  if (strmatch(input_name[i],'*ddo*168*',/fold_case)) then begin
    input_name_new[i]='UGC08320'
  endif
  
  if (strmatch(input_name[i],'*ddo*183*',/fold_case)) then begin
    input_name_new[i]='UGC08760'
  endif
  
  if (strmatch(input_name[i],'*ddo*210*',/fold_case)) then begin
    input_name_new[i]='DDO210'
  endif
  
  if (strmatch(input_name[i],'*ic*559*',/fold_case)) then begin
    input_name_new[i]='IC0559'
  endif
  
  if (strmatch(input_name[i],'*kkr*3*',/fold_case)) then begin
    input_name_new[i]='KK98-230'
  endif
  
  if (strmatch(input_name[i],'*mrk*475*',/fold_case)) then begin
    input_name_new[i]='MRK475'
  endif

  if (strmatch(input_name[i],'*mrk*206*',/fold_case)) then begin
    input_name_new[i]='UGCA280'
  endif

  if (strmatch(input_name[i],'*mrk*025*',/fold_case)) then begin
    input_name_new[i]='UGC05408'
  endif

  if (strmatch(input_name[i],'*mrk*33*',/fold_case)) then begin
    input_name_new[i]='UGC05720'
  endif

  if (strmatch(input_name[i],'*leoA*',/fold_case)) then begin
    input_name_new[i]='UGC05364'
  endif

  if (strmatch(input_name[i],'*pegasus*',/fold_case)) then begin
    input_name_new[i]='UGC12613'
  endif

  if (strmatch(input_name[i],'*MCG9-20-131*',/fold_case)) then begin
    input_name_new[i]='CGCG269-049'
  endif

  if (strmatch(input_name[i],'*IC1613*',/fold_case)) then begin
    input_name_new[i]='UGC00668'
  endif

  if (strmatch(input_name[i],'*ddo*053*',/fold_case)) then begin
    input_name_new[i]='UGC04459'
  endif

  if (strmatch(input_name[i],'*IC2574*',/fold_case)) then begin
    input_name_new[i]='UGC05666'
  endif

  if (strmatch(input_name[i],'*IC3687*',/fold_case)) then begin
    input_name_new[i]='UGC07866'
  endif

  if (strmatch(input_name[i],'*IC4182*',/fold_case)) then begin
    input_name_new[i]='UGC08188'
  endif

  if (strmatch(input_name[i],'*DDO165*',/fold_case)) then begin
    input_name_new[i]='UGC08201'
  endif

  if (strmatch(input_name[i],'*DDO181*',/fold_case)) then begin
    input_name_new[i]='UGC08651'
  endif

  if (strmatch(input_name[i],'*M81DwB*',/fold_case)) then begin
    input_name_new[i]='UGC05423'
  endif

  if (strmatch(input_name[i],'*zw*18*',/fold_case)) then begin
    input_name_new[i]='UGCA166'
  endif

  if (strmatch(input_name[i],'*II*zw*40*',/fold_case)) then begin
    input_name_new[i]='UGCA116'
  endif

  if (strmatch(input_name[i],'*UM462*',/fold_case)) then begin
    input_name_new[i]='UGC06850'
  endif

  if (strmatch(input_name[i],'*UM448*',/fold_case)) then begin
    input_name_new[i]='UGC06665'
  endif

  if (strmatch(input_name[i],'*kdg2*',/fold_case)) then begin
    input_name_new[i]='ESO540-G030'
  endif

  if (strmatch(input_name[i],'*kk77*',/fold_case)) then begin
    input_name_new[i]='LEDA166101'
  endif

  if (strmatch(input_name[i],'*m81da*',/fold_case)) then begin
    input_name_new[i]='M81dwA'
  endif

  if (strmatch(input_name[i],'*ic342*',/fold_case) or $
      strmatch(input_name[i],'*ic0342*',/fold_case)) then begin
    input_name_new[i]='UGC02847'
  endif

endfor

return,input_name_new
end
