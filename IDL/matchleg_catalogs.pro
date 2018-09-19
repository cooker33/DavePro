;dir example: 'unsmoothedWhite' or 'final'
;weball copies the x and y of all possible clusters in order. 
;this will allow me to put these on a website to choose good objects.
pro matchleg_catalogs,galaxy,weball=weball

basedir='/scr2/dcook/Legus/ID/AutoExtract/'+galaxy+'/'

if (keyword_set(weball) eq 1) then begin
  readcol,'/scr2/dcook/Legus/ID/AutoExtract/'+galaxy+'/s_extraction/catalog_clusters.txt',$
          f='(d,d)',x_cic,y_cic
  ncic=n_elements(x_cic)
  openw,3,basedir+'cleanregs/clusters_clean.reg'
    for m=0, ncic-1 do begin
      printf,3,x_cic[m],y_cic[m]
    endfor
  close,3
endif else begin


  readcol,basedir+'cleanregs/clusters_clean.reg',f='(f,f)',$
          clustx_clean,clusty_clean
  nclust=n_elements(clustx_clean)

  ;all sources, in case there is an obvious cluster or star that
  ;should be used.
  readcol,basedir+'/s_extraction/R2_wl_dpop_detarea.cat',$
          f='(f,f,f,f,f)',$
          allx,ally,all_fwhm,all_class,all_mag

  openw,1,basedir+'/photometry/isolated_clusters.coo'
  for i=0, nclust-1 do begin
    clustind=closest_2d(clustx_clean[i],clusty_clean[i],allx,ally)
    if n_elements(clustind) gt 1 then stop  ;if it finds more than one nearby source
    ;if the nearest source is gt than 10 pixels away then it is not the correct sourece
    if (sqrt( (clustx_clean[i]-allx[clustind])^2 + $
              (clusty_clean[i]-ally[clustind])^2 ) gt 5.) then clustind=-1
    ;if none found then do nothing
    if (clustind(0) ne -1) then begin
      printf,1,f='(f,f,f,f,f)',allx[clustind],ally[clustind],$
               all_fwhm[clustind],all_class[clustind],all_mag[clustind]  
    endif
  endfor
  close,1

  readcol,basedir+'cleanregs/stars_clean.reg',f='(f,f)',$
          starx_clean,stary_clean
  nstar=n_elements(starx_clean)

  openw,2,basedir+'/photometry/isolated_stars.coo'
  for i=0, nstar-1 do begin
    starind=closest_2d(starx_clean[i],stary_clean[i],allx,ally)
    if n_elements(starind) gt 1 then stop
    if (sqrt( (starx_clean[i]-allx[starind])^2 + $
              (stary_clean[i]-ally[starind])^2 ) gt 5.) then starind=-1
    if (starind(0) ne -1) then begin
      printf,2,f='(f,f,f,f,f)',allx[starind],ally[starind],$
               all_fwhm[starind],all_class[starind],all_mag[starind]
    endif
  endfor
  close,2

endelse


stop
end
