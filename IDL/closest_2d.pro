;+
; NAME:
;       MATCH_2D
;
; PURPOSE:



; CALLING SEQUENCE:
;
; 	match=closest_2d(position_x,position_y,array_x,array_y,MATCH_DISTANCE=)
; INPUTS:
; KEYWORD PARAMETERS:
;
;       MATCH_DISTANCE: On output, the distances between the matches
;          and the returned coordinate from the set [x1,y1]
;          (<=search_radius), is returned.
;
; OUTPUTS:
;
;       match: A 1D vector of length n1 containing the indices of x2
;          and y2 for the closest match to each [x1,y1], within the
;          search_radius. If no match was found within the search
;          radius, -1 is returned at that location.
;
; caution: complement doesn't work if input is not found in array
;
; EXAMPLE:
;
;	x=40,y=40 
; 	match=closest_2d(x_phot,y_phot,fuv_x,fuv_y,MATCH_DISTANCE=min_dist)


function closest_2d,position_x,position_y,array_x,array_y,$
         MATCH_DISTANCE=min_dist,tolerance=tol,$
         COMPLEMENT=indcomp

  ;if (finite(position_x) eq 0 or finite(position_y) eq 0) then begin
  ;  print,'Your position has a -Nan'
  ;  stop
  ;endif
  
  nx=n_elements(position_x)
  narray=n_elements(array_x)
  index=intarr(nx)
  min_dist=dblarr(nx)
  
  for i=0, nx-1 do begin
    dist=sqrt((position_x[i]-array_x)^2. +  (position_y[i]-array_y)^2.)

    index[i]=where(dist eq min(dist))
    
    if (n_elements(tol) ne 0) then begin
      if (min(dist) gt tol) then begin
        index[i]=-1
        print,'im here############################'
        ;print,index
        ;stop
      endif
    endif

    min_dist[i]=min(dist)
    
  endfor

  if (arg_present(indcomp)) then begin
    indcomp=intarr(narray-nx)
    k=0
    indarray=where(array_x)
    for m=0, narray-1 do begin
        junk=where(indarray[m] eq index)
        if junk eq -1 then begin
          indcomp[k]=m
          k=k+1
        endif
    endfor
  endif
  
  return,index
end
