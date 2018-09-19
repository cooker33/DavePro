; docformat='IDL'
function densityim, x0, y0, drange=drange, dlog=dlog, dsize=dsize, $
  ct=ct, ps_white=ps_white, $
  contour=contour, flevels=flevels, $
  xlog=xlog, ylog=ylog, _extra = _extra, $
  overplot=overplot,cx=cx,cy=cy
;+
; This procedure shows the density of points in an x-y plot.
;
; This procedure shows the density of points in an x-y plot.
; This is mainly useful in cases where so many points are being plotted 
; that they merge together into a large flat splotch when plotted with 
; the usual PLOT,X,Y,PSYM=3. 
;
; INPUT
; x0 = array of x-positions
; y0 = array of y-positions
; OPTIONAL INPUT 
; drange = [min,max] range for shading density of data points 
;          (default = [min,max] of density range)
; dlog = keyword to set use of logarithmic scaling within drange
; dsize = [dx,dy] size of density plot in pixels (default is size of plot 
;          within the given X-window. If a different dsize is used, the 
;          resulting density image is resizezed to still fit within the same
;          plot window.
; xlog = keyword to set use of logarithmic x-axis
; ylog = keyword to set use of logarithmic y-axis
; ct = number of standard IDL color table to use. [0:40]
;       -1 => inverted grayscale (good for PS output).
; ps_white = force a white background for PS color tables instead of color=255
; contour = set this keyword to overplot contours. 
; flevels = contour levels specified as the franction of data outside 
;         the contour. These should be in the range [0,1], in increasing value.
; _extra = allows use of any other keywords applicable to PLOT (and CONTOUR) 
;        commands e.g. XTITLE, YTITLE, TITLE, CHARSIZE, COLOR, LEVELS, ...
;
; DENSITY is used much like the PLOT command, but with a few extra keywords
; to control the display range for the density (DRANGE, DLOG), the scale 
; for the binning of the data (DSIZE), and optional contouring.
;
; This procedure does work with "PS" devices, but you may 
; need to adjust the color table to distinguish the axes (color = 0) from
; the lowest density portion of the image (color = 1).
; This is less of a problem with 'X' devices because in that case the 
; axes are drawn with color = 255 (not 0).
;
; The CT keyword specifies which of the standard IDL color tables (LOADCT)
; will be used in the plot. With the additional option that CT = -1 will
; use a white-to-black color table (i.e. and interted version of the 
; default greyscale).
;
; The PS_WHITE keyword can be set to force a white background color in a
; 'PS' version of a density plot in cases where the loaded color table results
; in a background of another color. 
;
; The CONTOUR keyword overplots contour lines. For potentially grainy plots
; (when DSIZE[1] > 100) the data are automatically smoothed before contouring
; is done. By default, the values of the contour LEVELS are not especially 
; meaningful unless DSIZE is carefully set so that the displayed density is in 
; physically relevant units.
; The FLEVELS parameter allows the selection of contours that exclude 
; (not enclose) the designated fraction of the data. You'll need to use
; the C_ANNOTATION parameter to label the contours appropriately.
; Note: the contours may not be precise in some cases (because of smoothing) 
; may appear shifted if XRANGE or YRANGE is specified without setting 
; XSTYLE or YSTYLE to force the exact plot range.
;
; EXAMPLE:
; Density plot of a gaussian distribution (with contours):
; IDL> x = randomn(seed,1e6)
; IDL> y = randomn(seed,1e6)
; IDL> density,x,y,ct=39,/contour,flev=[0.01,0.1,0.5],$
; IDL>     c_annot=['0.01','0.1','0.5'],xtitle='random x',ytitle='random y'

; R. Arendt (SSAI) rick.arendt@gsfc.nasa.gov
; Version 1.1 -- 2006/01/22 addded PS plotting to original version.
; Version 1.2 -- 2006/01/28 fixed PS plotting for lag axes, added PS color stuff
; Version 1.3 -- 2006/01/31 fixed plotting for cases with inverted axes
; Version 1.4 -- 2006/10/05 fixed default (unspecified) plot ranges
;                           added optional color table specification
;                           added optional contouring
;-


; 
if (n_params() eq 1) then begin 
  y = x0
  x = findgen(n_elements(y))
endif else begin
  y = y0
  x = x0
endelse

; load color table if specified 
if (n_elements(ct) eq 1) then begin
  if (ct ge 0 and ct le 40) then loadct,ct,/silent
  if (ct eq -1) then begin
    ramp = 255B-bindgen(256)
    if (!d.name eq 'PS') then begin
      ps_white = 1
      ramp[0] = 0
    endif
    ;tvlct,ramp,ramp,ramp
  endif
endif

; Set PS for 8 bit color and fiddle with color table.
if (!d.name eq 'PS') then begin
  ;device,/color,bits=8
  tvlct,/get,r0,g0,b0
  r = r0
  g = g0
  b = b0
  r[1] = keyword_set(ps_white) ? 255 : r[255]
  g[1] = keyword_set(ps_white) ? 255 : g[255]
  b[1] = keyword_set(ps_white) ? 255 : b[255]
  ;tvlct,r,g,b
endif

; initial plot of axes to define the plot region.
minx = min(x,max=maxx)
miny = min(y,max=maxy)
;plot, [minx,maxx], [miny,maxy], /nodata, xlog=xlog, ylog=ylog, _extra=_extra

; determine the size of an image to fill the plot.
dsize0 = round([(!x.window[1]-!x.window[0])*!d.x_size,$
  (!y.window[1]-!y.window[0])*!d.y_size])
if (!d.name eq 'PS') then dsize0 = dsize0/24
if (n_elements(dsize) ne 2) then dsize = dsize0

; z = the [i,j] position of each datum, translated into a sequential pixel 
; number within the density image  z = i + j*dsize[0]
; (alternate case for log axes)
if (not(keyword_set(xlog)) and not(keyword_set(ylog))) then $
  z = long(dsize[0]*(x-!x.crange[0])/(!x.crange[1]-!x.crange[0])) + $
    long(dsize[1]*(y-!y.crange[0])/(!y.crange[1]-!y.crange[0]))*dsize[0]

if (   (keyword_set(xlog)) and not(keyword_set(ylog))) then $
  z = long(dsize[0]*(alog10(x)-!x.crange[0])/(!x.crange[1]-!x.crange[0])) + $
    long(dsize[1]*(y-!y.crange[0])/(!y.crange[1]-!y.crange[0]))*dsize[0]

if (not(keyword_set(xlog)) and    (keyword_set(ylog))) then $
  z = long(dsize[0]*(x-!x.crange[0])/(!x.crange[1]-!x.crange[0])) + $
    long(dsize[1]*(alog10(y)-!y.crange[0])/(!y.crange[1]-!y.crange[0]))*dsize[0]

if (   (keyword_set(xlog)) and    (keyword_set(ylog))) then $
  z = long(dsize[0]*(alog10(x)-!x.crange[0])/(!x.crange[1]-!x.crange[0])) + $
    long(dsize[1]*(alog10(y)-!y.crange[0])/(!y.crange[1]-!y.crange[0]))*dsize[0]

; remove all data that were outside the xrange, yrange
if (not(keyword_set(xlog)) and not(keyword_set(ylog))) then $
  h = where(x gt min(!x.crange) and x lt max(!x.crange) and $
  y gt min(!y.crange) and y lt max(!y.crange),nh)
if (   (keyword_set(xlog)) and not(keyword_set(ylog))) then $
  h = where(x gt 10.^min(!x.crange) and x lt 10.^max(!x.crange) and $
  y gt min(!y.crange) and y lt max(!y.crange),nh)
if (not(keyword_set(xlog)) and    (keyword_set(ylog))) then $
  h = where(x gt min(!x.crange) and x lt max(!x.crange) and $
  y gt 10.^min(!y.crange) and y lt 10.^max(!y.crange),nh)
if (   (keyword_set(xlog)) and    (keyword_set(ylog))) then $
  h = where(x gt 10.^min(!x.crange) and x lt 10.^max(!x.crange) and $
  y gt 10.^min(!y.crange) and y lt 10.^max(!y.crange),nh)

; create density image by using HISTOGRAM to count the number of data at each 
; pixel z 
im = fltarr(dsize[0],dsize[1])
if (nh ge 1) then begin 
  im = histogram(z[h],binsize=1,min=0,nbins=product(dsize))
  im = reform(im,dsize[0],dsize[1])
endif

; scale density image and display it within the plotted axes
if (n_elements(drange) ne 2) then drange = minmax(im)
if (!d.name ne 'PS') then begin
  if not(keyword_set(dlog)) then $
    ;tv,bytscl(congrid(im,dsize0[0],dsize0[1]),drange[0],drange[1],top=254)+1,$
    ;  !x.window[0]*!d.x_size,!y.window[0]*!d.y_size
  if (keyword_set(dlog)) then begin
    log_im = alog10(im>0.1)
    ldrange = alog10(drange>0.1)
    ;tv,bytscl(congrid(log_im,dsize0[0],dsize0[1]),ldrange[0],ldrange[1]),$
    ;  !x.window[0]*!d.x_size,!y.window[0]*!d.y_size
  endif
endif else begin
  if not(keyword_set(dlog)) then $
    ;tv,bytscl(im,drange[0],drange[1],top=254)+1,!x.window[0],!y.window[0],$
    ;  xsize=(!x.window[1]-!x.window[0]),ysize=(!y.window[1]-!y.window[0]),/norm
  if (keyword_set(dlog)) then begin
    log_im = alog10(im>0.1)
    ldrange = alog10(drange>0.1)
    ;tv,bytscl(log_im,ldrange[0],ldrange[1],top=254)+1,!x.window[0],!y.window[0],$
    ;  xsize=(!x.window[1]-!x.window[0]),ysize=(!y.window[1]-!y.window[0]),/norm
  endif
endelse

; redraw axes because the density image obscured the tick marks
if (!p.multi[1]  gt 1 or !p.multi[2] gt 1) then !p.multi[0] = !p.multi[0]+1
if keyword_set(contour) then begin
  if (dsize[1] gt 100) then begin
     kern = exp(-0.5*dist(20)^2/5.^2)
     kern = kern/total(kern,/double)
     im = convol(float(im),kern,/edge_wrap)
  endif
  cx = findgen((size(im))[1]) + 0.5
  cy = findgen((size(im))[2]) + 0.5
  if keyword_set(xlog) then begin
     cx = 10.^(cx/n_elements(cx)*(!x.crange[1]-!x.crange[0])+!x.crange[0])
  endif else begin
     cx = cx/n_elements(cx)*(!x.crange[1]-!x.crange[0])+!x.crange[0]
  endelse
  if keyword_set(ylog) then begin
     cy = 10.^(cy/n_elements(cy)*(!y.crange[1]-!y.crange[0])+!y.crange[0])
  endif else begin
     cy = cy/n_elements(cy)*(!y.crange[1]-!y.crange[0])+!y.crange[0]
  endelse
  if (n_elements(flevels) ge 1) then begin
    levels = fltarr(n_elements(flevels))
    sim = im[sort(im)]
    cim = total(sim,/cumulative)/total(sim)
    for i=0,n_elements(levels)-1 do levels[i] = sim[0>min(where(cim ge flevels[i]))]
    ;contour,im,cx,cy,/noerase,xlog=xlog,ylog=ylog,$
    ;  levels=levels,_extra=_extra,xsty=5,ysty=5,/overplot
  endif else begin
    ;contour,im,cx,cy,/noerase,xlog=xlog,ylog=ylog,_extra=_extra,xsty=5,ysty=5,/overplot
  endelse
endif
;plot,[minx,maxx],[miny,maxy],/nodata,/noerase,xlog=xlog,ylog=ylog,_extra=_extra
;if (!p.multi[1]  gt 1 or !p.multi[2] gt 1) then !p.multi[0] = !p.multi[0]-1

; Reset original color table.
;if (!d.name eq 'PS') then begin
;  tvlct,r0,g0,b0
;endif

return,im
end


