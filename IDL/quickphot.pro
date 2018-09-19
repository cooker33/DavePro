pro quickphot,image,x,y,ap,an,dan,center=center

im=readfits(image,head)

min=min(im)
max=max(im)

exptime=sxpar(head,'EXPTIME')
gain=sxpar(head,'GAIN')
if gain eq 0 then gain=1.

if (keyword_set(center) eq 1) then begin
  GCNTRD,im,x,y,xcen,ycen,3.
endif else begin
  xcen=x & ycen=y
endelse


APER,im,xcen,ycen,flux,fluxerr,sky,skyerr,gain*exptime,$
     ap,[an,an+dan],[min,max],/flux,/meanback,/nan,/exact,/silent
     
print,'#################################################'
print,'     X','        Y','        Sky','          Flux'
print,f='(5x,f6.3,3x,f6.3,2x,f5.2,2x,f6.3,2x,a,2x,f6.3)',$
       xcen,ycen,sky,flux,'+/-',fluxerr
print,'#################################################'
     
stop
end
