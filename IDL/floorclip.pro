;do a sigma clipping on a mean where only high values are not correct.
function floorclip,input,sig=sig,std=std

if n_elements(sig) eq 0 then sig=3.

data=input
average=avg(data,/nan)
std=stddev(data,/nan)

for i=0, 20 do begin
  badind=where(data-average gt std*sig,COMPLEMENT=goodind)
  ;print,average,std
  ;stop
  
  if (badind(0) eq -1) then begin   
    result=average
    goto,loop
  endif else begin
    average=avg(data[goodind],/nan)
    std=stddev(data[goodind],/nan)
    data=data[goodind]
  endelse
endfor
loop:
yhist=histogram(input,locations=xhist,bin=(max(input,/nan)-min(input,/nan))/20.,min=min(input,/nan)-5.,max=max(input,/nan)-5.)

if abs(xhist[where(yhist eq max(yhist))]-result) gt std*3. then begin
  print,'Histogram peak does not match with clipped average. Look at the histogram to confirm:'
  plothist,input,/nan,bin=(max(input,/nan)-min(input,/nan))/20.
  stop
endif 
return,result
end
