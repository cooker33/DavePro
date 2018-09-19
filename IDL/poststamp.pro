;multireg - put multiple regions on the same image

pro poststamp, image, x, y, rad, output, fits=fits, multireg=multireg

    ;setup window sizes
    clustsize=75.
    winsize=500.
    xcen=winsize/2. & ycen=winsize/2.
    ratio=winsize/clustsize
    window,0,XSIZE=winsize, YSIZE=winsize 

    minx=x[0]-clustsize & maxx=x[0]+clustsize 
    miny=y[0]-clustsize & maxy=y[0]+clustsize

    ;display color image
      if (keyword_set(fits) eq 1) then begin
        imcut_color=image[minx:maxx,miny:maxy]
        imexp_color=CONGRID(imcut_color,3,winsize,winsize)        
        tv,imexp_color,/data
      endif else begin
        imcut_color=image[*,minx:maxx,miny:maxy]
        imexp_color=CONGRID(imcut_color,3,winsize,winsize)    
        tv,imexp_color,true=1,/data
      endelse

      tvcircle,rad[0]*ratio/2.,(clustsize/2.)*ratio,(clustsize/2.)*ratio,$
               thick=2,color=cgcolor('yellow'),/device 

      if (keyword_set(tworeg) eq 1) then begin
        nreg=n_elements(x)
        for i=1, nreg-1 do begin
          plotx=(xcen - (x[i]-x[0]) )
          ploty=(ycen - (y[i]-y[0]) )
          tvcircle,rad[i]*ratio/2.,plotx,ploty,$
                   thick=2,color=cgcolor('green'),/device
        endfor
      endif 

      write_jpeg,output, TVRD(/TRUE), /TRUE


end
