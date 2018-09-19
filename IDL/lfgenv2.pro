;Requires Luminosities

;if you want to do magnitudes simply do: 10.^mag and 10^magerr for your input luminosities

function linfitex, p, x=x, y=y, $
                   sigma_y=sigma_y, $
                   _EXTRA=extra

  a = p[0]   ;; Intercept
  b = p[1]   ;; Slope

  f = a + b*x

  resid = (y - f)/(sigma_y)

  return, resid
end

function lfgenv2,lumin,lumerrin,XBIN=XBIN,YBIN=YBIN,ERR=ERR, $
         NPERBIN=NPERBIN,NTOT=NTOT,Lmax=Lmax,Lmin=Lmin,$
         XHIST=xhist,yhist=yhist,maxhist=maxhist,binsize=binsize,$
         nbinhist=nbinhist,fiterr=fiterr,fitall=fitall,eqbin=eqbin,$
	 fixedslope=fixedslope
  
  if (n_elements(nbinhist) ne 0 and n_elements(binsize) ne 0) then begin
    print,'cannot have both binsize and nbin...choose only one'
  endif
  
  lumin=double(lumin) & lumerrin=double(lumerrin)
  lum=lumin[where(finite(lumin) ne 0)]    &   lumerr=lumerrin[where(finite(lumin) ne 0)]
  nsrc=n_elements(lum)
  lumsort=reverse(lum[sort(lum)]); ordered highest L first
  lumsorterr=reverse(lumerr[sort(lum)])
  nbin=sround(nsrc/sqrt(nsrc),0)
  remainder=nsrc mod nbin
  nperbin=(nsrc-remainder)/nbin
  
  ;put the leftover sources in the last bin; only for equal Num binning
  if (remainder ne 0 and keyword_set(eqbin) eq 0) then begin 
    nbin=nbin+1
  endif 
  bincen=dblarr(nbin)
  dndl=dblarr(nbin)
  dndlerr=dblarr(nbin)
  
  maxall=double(max(lumsort,/nan))
  minall=double(min(lumsort,/nan))
  lfbinsize=( alog10(maxall)-alog10(minall) )/nbin

  for m=0, nbin-1 do begin  
    ;###################################equal sized bins
    if (keyword_set(eqbin) eq 1) then begin 
      
      minbin=double(alog10(minall)+(m*lfbinsize))
      maxbin=double(minbin+lfbinsize) ;double precesion required for # > 1e36-ish
      indbin=where(alog10(lumsort) ge minbin and alog10(lumsort) le maxbin)  ;locate objects inside the equal sized bins
      lummax=10.^maxbin
      lummin=10.^minbin
      bincen[m]=( alog10(lummax)+alog10(lummin) )/2.
      ;bincen[m]=avg(alog10(lumsort[indbin]))
      
      if (indbin[0] eq -1) then begin ;no sources in this Lum bin
        ;print,'No sources in this bin! Figure out what to do in this case'
        ;stop
        numbin=0
        lumbin=0./0.
        lumerrbin=0./0.
        dndl[m]=0./0.
        dndlerr[m]=0./0.
      endif else begin
        numbin=n_elements(indbin)
        lumbin=lumsort[indbin]
        lumerrbin=lumsorterr[indbin]
        dndl[m]=alog10(numbin/(lummax - lummin))
        if finite(dndl[m]) eq 0 then stop
        dndlerr[m]=[1./(numbin*alog(10.))] * sqrt(numbin); poisson statistcs
      
      endelse
    ;###################################equal number bins
    endif else begin 
      if (m eq nbin-1 and remainder ne 0) then begin ;last bin
        numbin=remainder
      endif else begin
        numbin=nperbin
      endelse

      indbin=indgen(numbin) + m*nperbin ;first however many indices in the bin
      lumbin=lumsort[indbin]
      lumerrbin=lumsorterr[indbin]

      lummax=double(max(lumbin))
      lummaxerr=lumerrbin[where(lumbin eq max(lumbin))]
      lummin=min(lumbin)
      bincen[m]=( alog10(lummax)+alog10(lummin) )/2.
      ;bincen[m]=median(alog10(lumsort[indbin]))   ;don't use, this causes a systematic deviation in the slope

      if (numbin le 2 or lummax eq lummin) then begin
        dndl[m]=alog10(numbin/(lummaxerr))
      endif else begin
        dndl[m]=alog10(numbin/(lummax - lummin))
        if finite(dndl[m]) eq 0 then stop
      endelse
      dndlerr[m]=[1./(numbin*alog(10.))] * sqrt(numbin); poisson statistcs
    endelse
  endfor
  
  ;find max in histogram
  if n_elements(binsize) eq 0 then binsize=0.1
  if (n_elements(nbinhist) ne 0) then begin
    y=histogram(alog10(lum),nbin=nbinhist,locations=x,/nan)  
  endif else begin
    y=histogram(alog10(lum),bin=binsize,locations=x,/nan)
  endelse
  ;histogram locations gives the bin starting location, not the center
  x=x+(binsize/2.)
  maxhist=x[where(y eq max(y))]

  ;find closest lum bin with a higher luminosity
  ;indfit=CLOSEST(alog10(bincen),maxhist(0))
  indfit=where(bincen gt maxhist[0])
  indLmin=indfit[0]
  indLmax=indfit[n_elements(indfit)-1]
  
  ;manually set min and/or max luminosity to fit power-law
  if (n_elements(Lmin) ne 0 and n_elements(Lmax) ne 0) then begin
    indfit=where(bincen gt Lmin and bincen le Lmax)
    maxhist=Lmin
  endif else if (n_elements(Lmin) ne 0 and n_elements(Lmax) eq 0) then begin
    indfit=where(bincen gt Lmin)
    maxhist=Lmin
  endif else if (n_elements(Lmin) eq 0 and n_elements(Lmax) ne 0) then begin
    indfit=where(bincen le Lmax and bincen gt maxhist[0])
  endif 
  
  if (nbin eq 2) then begin ; you have to fit all if only two bins....
    xfit=bincen
    yfit=dndl
    yfiterr=dndlerr
  endif else begin
    if (fitall eq 1) then begin ;keyword to fit all points
      xfit=bincen[*]
      yfit=dndl[*]
      yfiterr=dndlerr[*] 
    endif else begin
      ;indfit=indfit[1:n_elements(indfit)-1] ;to see what happens when using peak+1 bin for fit
      xfit=bincen[indfit]
      yfit=dndl[indfit]
      yfiterr=dndlerr[indfit]
    endelse
  endelse
  
  ;for cases (mostly for equal size bins) when there are gaps
  ;in the LF...aka no sources in that bin. fitting program doesn't like Nans
  xfit=xfit[where(finite(yfit) eq 1)]
  yfiterr=yfiterr[where(finite(yfit) eq 1)]
  yfit=yfit[where(finite(yfit) eq 1)]
    
  ;test=where(finite(yfiterr) eq 0)
  ;if test[0] ne -1 then stop
  
  ;fit LF
  parinfo = replicate({value:0.D,fixed:0.D,limits:[0.D,0.D],limited:[0.D,0.D],$
                     mpmaxstep:[0.D]},2)

  if (keyword_set(fixedslope)) then begin
      ;fixed slope =-2
      parinfo[1].value=fixedslope[0]
      parinfo[1].fixed=1
  endif
  
  if (n_elements(xfit) eq 1) then begin
      xfit=[xfit,xfit]
      yfit=[yfit,yfit]
      yfiterr=[yfiterr,yfiterr]
  endif
  
  fit=mpfit('LINFITEX',PARINFO=PARINFO,BESTNORM=BESTNORM,PERROR=PERROR,xtol=1.d-3,/quiet,$
            FUNCTARGS={x:xfit,y:yfit,sigma_y:yfiterr})
    
  ;no good fit
  if (fit[0] eq 0. or n_elements(fit) ne 2) then begin
    perror=[0./0.,0./0.]
    fit=[0./0.,0./0.]
  endif
  
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
