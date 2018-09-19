function linfitex, p, x=x, y=y, $
                   sigma_y=sigma_y, $
                   _EXTRA=extra

  a = p[0]   ;; Intercept
  b = p[1]   ;; Slope

  f = a + b*x

  resid = (y - f)/(sigma_y)

  return, resid
end

function lfgen,lumin,lumerrin,XBIN=XBIN,YBIN=YBIN,ERR=ERR, $
         NPERBIN=NPERBIN,NTOT=NTOT,Lmax=Lmax,Lmin=Lmin,$
         XHIST=xhist,yhist=yhist,maxhist=maxhist,binsize=binsize,$
         nbinhist=nbinhist,fiterr=fiterr,fitall=fitall
  
  if (n_elements(nbinhist) ne 0 and n_elements(binsize) ne 0) then begin
    print,'cannot have both binsize and nbin...choose only one'
  endif

  lum=lumin[where(finite(lumin) ne 0)]    &   lumerr=lumerrin[where(finite(lumin) ne 0)]
  nsrc=n_elements(lum)
  lumsort=reverse(lum[sort(lum)]); ordered highest L first
  lumsorterr=reverse(lumerr[sort(lum)])
  nbin=sround(nsrc/sqrt(nsrc),0)
  remainder=nsrc mod nbin
  nperbin=(nsrc-remainder)/nbin

  if (remainder ne 0) then begin ;put the leftover sources in the last bin
    nbin=nbin+1
  endif 
  bincen=dblarr(nbin)
  dndl=dblarr(nbin)
  dndlerr=dblarr(nbin)

  for m=0, nbin-1 do begin  

    if (m eq nbin-1 and remainder ne 0) then begin ;last bin
      numbin=remainder
    endif else begin
      numbin=nperbin
    endelse

    indbin=indgen(numbin) + m*nperbin ;first however many indices in the bin
    lumbin=lumsort[indbin]
    lumerrbin=lumsorterr[indbin]

    lummax=double(max(lumbin))
    lummin=min(lumbin)
    bincen[m]=(lummax+lummin)/2.

    if (numbin eq 1 or lummax eq lummin) then begin
      dndl[m]=alog10(numbin/(lummax*0.9))
    endif else begin
      dndl[m]=alog10(numbin/(lummax - lummin))
      if finite(dndl[m]) eq 0 then stop
    endelse
    dndlerr[m]=[1./(numbin*alog(10.))] * sqrt(numbin); poisson statistcs
  endfor

  ;find max in histogram
  if n_elements(binsize) eq 0 then binsize=0.1
  if (n_elements(nbinhist) ne 0) then begin
    y=histogram(alog10(lum),nbin=nbinhist,locations=x)  
  endif else begin
    y=histogram(alog10(lum),bin=binsize,locations=x)
  endelse
  ;histogram locations gives the bin starting location, not the center
  x=x+(binsize/2.)
  maxhist=x[where(y eq max(y))]

  ;find closest lum bin with a higher luminosity
  ;indfit=CLOSEST(alog10(bincen),maxhist(0))
  indfit=where(alog10(bincen) gt maxhist[0])
  indfit=indfit[n_elements(indfit)-1]
  
  ;manually set max luminosity to fit power-law
  if (n_elements(Lmax) ne 0) then begin
    indLmax=CLOSEST(alog10(bincen),lmax)
  endif else begin
    indLmax=0
  endelse

  ;manually set min luminosity to fit power-law
  if (n_elements(Lmin) ne 0) then begin
    indLmin=CLOSEST(alog10(bincen),Lmin)
    indfit=indLmin
  endif else begin
    ;nothing. use the max histogram luminosity
  endelse

  if (nbin eq 2) then begin ; you have to fit all if only two bins....
    xfit=alog10(bincen)
    yfit=dndl
    yfiterr=dndlerr
  endif else begin
    if (fitall eq 1) then begin ;keyword to fit all points
      xfit=alog10(bincen[*])
      yfit=dndl[*]
      yfiterr=dndlerr[*] 
    endif else begin
      xfit=alog10(bincen[indLmax:indfit])
      yfit=dndl[indLmax:indfit]
      yfiterr=dndlerr[indLmax:indfit]
    endelse
  endelse

  ;fit LF
  parinfo = replicate({value:0.D,fixed:0.D,limits:[0.D,0.D],limited:[0.D,0.D],$
                     mpmaxstep:[0.D]},2)

  fit=mpfit('LINFITEX',PARINFO=PARINFO,BESTNORM=BESTNORM,PERROR=PERROR,xtol=1.d-3,/quiet,$
            FUNCTARGS={x:xfit,y:yfit,sigma_y:yfiterr})
 
  if arg_present(XBIN) then XBIN=bincen
  if arg_present(YBIN) then YBIN=dndl
  if arg_present(ERR) then ERR=dndlerr
  if arg_present(NPERBIN) then NPERBIN=nperbin
  if arg_present(NTOT) then NTOT=nsrc
  if arg_present(MAXHIST) then MAXHIST=maxhist
  if arg_present(XHIST) then XHIST=x
  if arg_present(YHIST) then YHIST=Y
  if arg_present(fiterr) then fiterr=perror

  return,fit
end
