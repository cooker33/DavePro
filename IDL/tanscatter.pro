;    |   .
;    |      .
;    |      /90.
;    |     /      .
;   y|    /           .
;    |  z/               .
;    |  /                   .
;    | /                        .
;    |_a_______________________t___
;                 x
;
function tanscatter, x_temp, y_temp, slope, yzero, NAN=NAN

if (keyword_set(nan) eq 1) then begin
  x=x_temp[where(finite(x_temp) ne 0 and finite(y_temp) ne 0)]
  y=y_temp[where(finite(x_temp) ne 0 and finite(y_temp) ne 0)]
endif else begin
  x=x_temp
  y=y_temp
endelse

z=dblarr(2) ;scatter values and rms around line

xline=(y-yzero(0))/slope(0)
yline=slope(0)*x + yzero(0)

del_x=(x-xline)
del_y=(y-yline)

t=atan(del_y/del_x) ;radians

a=90.- !radeg*t  ;degrees

scatter=del_x*cos(a/!radeg) ;radians

rms=sqrt(total(scatter^2.)/( n_elements(scatter)-1 ))

;print,scatter
;print,'RMS=',rms,rms1
;ind=where(scatter eq max(scatter))
;print,x[ind],y[ind],scatter[ind]
;stop

return,rms

end
