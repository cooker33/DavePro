function getpixscale,head

  cd1=SXPAR(head,'CD1_1')
  cd2=SXPAR(head,'CD1_2')
  
  if (cd1 eq 0 and cd2 eq 0) then begin
    cdel=SXPAR(head,'CDELT1')
    if (cdel eq 0.) then begin
      ;head=headfits(dir,exten=1)
      ;cdel=SXPAR(head,'CDELT1')
      ;pixscale=ABS(cdel)*3600. 
      print,'No Header, try extension 1'
      return,pixscale
      stop
    endif else begin
      pixscale=abs(cdel)*3600.
    endelse   
  endif else begin
    pixscale=SQRT(cd1^2. + cd2^2.)*3600.
  endelse

return,pixscale
end
