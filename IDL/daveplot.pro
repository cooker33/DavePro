pro daveplot, file=file, blank=blank, close=close,$
              x=x, y=y, pdf=pdf, thick2=thick2, _EXTRA=extra

if (keyword_set(close) eq 1) then begin
  !P.thick=1
  !P.charthick=1
  !x.thick=1
  !y.thick=1
  !x.charsize=1
  !y.charsize=1
  device,/close
  set_plot,'x'
endif else if (keyword_set(blank) eq 1) then begin
  plot,[-99,-99],[-99,-99],psym=3,_EXTRA=extra
endif else begin
  if (keyword_set(thick2) eq 1) then begin
    !P.thick=2
    !P.charthick=2
    !P.charsize=1.1
    !x.thick=2
    !y.thick=2
    !x.charsize=1.3
    !y.charsize=1.3
    ;!P.font=0  ;this makes it very thick
  endif
  ;if (n_elements(file) eq 0) then print,'you must enter a file name...' & stop
  if (n_elements(x) eq 0) then x=7 
  if (n_elements(y) eq 0) then y=5 
  
  set_plot,'ps'
  device,filename=file,/color,ysize=y,xsize=x,/inches
endelse

end


