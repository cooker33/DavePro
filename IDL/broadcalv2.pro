;updated 3-30-2010
;This program only handles two filters.  It requires a an input file that will
;have a format of:

;Night	        Fits  ObjName     Filter  AM     ExpTime   Counts  	mag		magerr
;jul17182009    a007  PG1633+099    B     1.32    5      65684.09	-10.296         0.005
;jul17182009    a007  PG1633+099A   B     1.32    5      13052.78	-8.542          0.019

;jul17182009    a008  PG1633+099    R     1.32    5      72462.81	-10.403         0.008
;jul17182009    a008  PG1633+099A   R     1.32    5      51585.87	-10.034         0.011

;jul17182009    a013  PG1633+099    B     1.46    5      64828.21	-10.282         0.005
;jul17182009    a013  PG1633+099A   B     1.46    5      12236.77	-8.472          0.020

;jul17182009    a014  PG1633+099    R     1.47    5      69887.29	-10.364         0.009
;jul17182009    a014  PG1633+099A   R     1.47    5      50072.07	-10.002         0.011

;The first two (a007 & a008) are a color pair -> this program sorts by color 
;pairs.  The magnitude in this file is a magnitude determined via IRAF with 
;the zeropoint set to zero.  The exposure time and counts are not used, but 
;are there for completness in case you want to see information about the data.

;Extinction (airmass) correction:
;this program gives you the option to fit or enter the values for the extinction
;coefficients.  Sometimes when you DO NOT have enough points, the errors resulting
;from the extinction coefficients will mess up your color correction fits.  In
;this case enter average values from the particular observatory the data is from.

;A plot of the fit to data (for both extinction and color correction) will pop 
;up giving the y-intercept and the slope; the parameters need for extinction:

    ;B0 = b + k * X
    
    ;B0 = airmass corrected magnitude
    ;b  = instrumental magnitude
    ;k  = extinction coefficient
    ;X  = airmass

;color correction:

    ;B = B0 - C0 - C1 * (color)
    
    ;B  = calibrated magnitude
    ;B0 = airmass corrected magnitude
    ;C0 = y-intercept
    ;C1 = slope

;Then hit enter to see these parameters for the second filter.

;/INPUT_EXT -> this keyword will allow the user to input the airmass
;coefficients and errors if they are known or if there is not enough data to
;perform a good fit.  
;KPNO values: 
;U=0.5 +/- 0.01 
;B=0.25 +/- 0.01 
;V=0.15 +/- 0.01 
;R=0.1 +/- 0.01 
;I=0.07 +/- 0.01

;WIRO values:
;U=0.5 +/- 0.01 
;B=0.295 ± 0.004 
;V=0.193 ± 0.004
;R=0.139 ± 0.004
;I=0.061 ± 0.011

;After you have gone through the plots you will be asked if you want to write
;the plots to a file.  If you are satisfied with the fits hit 'y' and the plots
;will be written into the nights directory.
    
;example:
; .r broadcal
; broadcal,'input.txt'




;!!!!!!!!!!!!!!!!!!!Need to change fitting to one which takes into account both
;x and y errors (e.g., fitexy)
;!!!!!!!!!!!!!!!!!!!!!

function linfitex, p, $
                   x=x, y=y, sigma_x=sigma_x, sigma_y=sigma_y, $
                   _EXTRA=extra

  a = p[0]   ;; Intercept
  b = p[1]   ;; Slope

  f = a + b*x

  resid = (y - f)/sqrt(sigma_y^2.)

  return, resid
end

pro broadcalv2,input,INPUT_EXT=INPUT_EXT,WIRO=WIRO,BOK=BOK,CTIO=CTIO

READCOL,input,F='A,A,A,A,D,D,D,D,D',night,fits,objname,$
  filt,am,time,counts,mag_instrumental,mag_instrumental_err

nstars=N_ELEMENTS(am)
mag_diff_UNcorr=DBLARR(nstars)
mag_diff_UNcorr_err=DBLARR(nstars)
MagAMcorr=DBLARR(nstars)
MagAMcorr_err=DBLARR(nstars)
magstandard=DBLARR(nstars)
magstandard_err=DBLARR(nstars)
file_response=' '

;define directory where info will be put
temp=STRSPLIT(input,'/',/extract)
dir=temp(0)

;read in V mag and colors of landolt standard stars, and then 
;compute other band magnitudes and errors
readcol,'/pawnee3/davec/clusters/data/calibration/landolt/landolts.dat',$
        F='A,A,A,D,D,D,D,D,D',object,ra,dec,landoltVmag,bv,ub,vr,ri,vi,$
                              junk,junk1,landoltVmagerr,bverr,uberr,vrerr,$
                              rierr,vierr
  landoltBmag=(bv+landoltVmag)*(1.d)
  landoltUmag=(ub+landoltBmag)*(1.d)
  landoltRmag=(vr-landoltVmag)*(-1.d)
  landoltImag=(vi-landoltVmag)*(-1.d)

  landoltBmagerr=SQRT(bverr*(1.d)^2 + landoltVmagerr^2.d)
  landoltUmagerr=SQRT(uberr*(1.d)^2 + landoltBmagerr^2.d)
  landoltRmagerr=SQRT(vrerr*(1.d)^2 + landoltVmagerr^2.d)
  landoltImagerr=SQRT(vierr*(1.d)^2 + landoltVmagerr^2.d)

;find values of unique standard star names and filters
starind=REM_DUP(objname)
filtind=REM_DUP(filt)
airmassind=REM_DUP(am)
starlist=objname[starind]
filtlist=filt[filtind]
airmasslist=am[airmassind]

;put standard magnitudes into an array that matches calculated magnitudes 
;and filters
FOR j=0,(nstars-1) DO BEGIN

  ;find and index the correct standard star and corresponding magnitudes
  index=WHERE(STRMATCH(object,objname[j],/FOLD_CASE))

  IF (strcmp(filt[j],'U',/FOLD_CASE)) THEN BEGIN
          magstandard[j]=landoltUmag[index]
          magstandard_err[j]=landoltUmagerr[index]
  ENDIF ELSE IF (strcmp(filt[j],'B',/FOLD_CASE)) THEN BEGIN
          magstandard[j]=landoltBmag[index]
          magstandard_err[j]=landoltBmagerr[index]
  ENDIF ELSE IF (strcmp(filt[j],'V',/FOLD_CASE)) THEN BEGIN
          magstandard[j]=landoltVmag[index]
          magstandard_err[j]=landoltVmagerr[index]
  ENDIF ELSE IF (strcmp(filt[j],'R',/FOLD_CASE)) THEN BEGIN
          magstandard[j]=landoltRmag[index]
          magstandard_err[j]=landoltRmagerr[index]
  ENDIF ELSE IF (strcmp(filt[j],'I',/FOLD_CASE)) THEN BEGIN
          magstandard[j]=landoltImag[index]
          magstandard_err[j]=landoltImagerr[index]
  ENDIF

ENDFOR

;ask user what color to use for fits
  color12=filtlist[0]+'-'+filtlist[1]
  color21=filtlist[1]+'-'+filtlist[0]

  user_input=''

  ;if entry is not valid this asks the user again
  loop:
  read,'Do you want to use '+ color12+', y/n?',user_input

  IF (strcmp(user_input,'n',/FOLD_CASE)) THEN BEGIN

  ;put filters into 2 different arrays with the same order so that colors
  ;can be easily calculated
    filt1ind=where(filt eq filtlist[1])
    filt2ind=where(filt eq filtlist[0])
    color_text=color21
    filt1=filtlist[1]
    filt2=filtlist[0]
    print,'**********************'
    print,'Using '+ color21
    print,'**********************'

  ENDIF ELSE IF(strcmp(user_input,'y',/FOLD_CASE)) THEN BEGIN

    filt1ind=where(filt eq filtlist[0])
    filt2ind=where(filt eq filtlist[1])
    color_text=color12
    filt1=filtlist[0]
    filt2=filtlist[1]
    print,'**********************'
    print,'Using '+ color12
    print,'**********************'

  ENDIF ELSE BEGIN

    print,'Try Again'
    print,'Enter y or n'
    goto,loop

  ENDELSE

;if you want to fit the extinction correction coefficients then do not set
;the INPUT_EXT keyword; otherwise the extinction coefficients will
;be fit.
IF KEYWORD_SET(INPUT_EXT) THEN BEGIN
  read,'ENTER airmass coefficient for'+filt1+': ',amcoeff_input1
  read,'ENTER airmass coefficient error for'+filt1+': ',amcoefferr_input1
  read,'ENTER airmass coefficient for'+filt2+': ',amcoeff_input2
  read,'ENTER airmass coefficient error for'+filt2+': ',amcoefferr_input2
ENDIF
  

;Set up plotting ps file for multiple pages 
loop0:
IF (STRCMP(file_response,'y',/fold_case) eq 1) THEN BEGIN
  SET_PLOT,'ps'
  DEVICE,filename=night[0]+filt1+filt2+'.ps'
ENDIF

;need an error for fitting airmass correction -> chose 0.005 since most telscopes
;read to 2 decimal places.  1.28 -> error=0.005
  amerr=DBLARR(nstars)+1*0.005

IF KEYWORD_SET(INPUT_EXT) THEN BEGIN
ENDIF ELSE BEGIN

  ;setup difference between instrumental mags (uncorrected for airmass) and Standard
  ;mags.  I am using instrumental minus standard since the slope already has
  ;a minus sign in front of it.
  mag_diff_UNcorr=mag_instrumental - magstandard
  mag_diff_UNcorr_err=SQRT(magstandard_err^2 + mag_instrumental_err^2)

  ;begin fit for airmass correction
  parinfo = replicate({value:0.D,fixed:0.D,limits:[0.D,0.D],limited:[0.D,0.D],$
                       maxstep:[0.D]},2)

  ;parinfo[0].value=-10
  ;parinfo[1].value=-0
  ;parinfo[0].limited[0]=1
  ;parinfo[1].limited[1]=1
  ;parinfo[0].limits=[-13,-5]
  ;parinfo[1].limits=[0.1,1]
  ;parinfo[0].step=0.1
  parinfo[1].maxstep=0.01

  ;fit and plot airmass correction for filter 1 
  ;(aka the first filter listed in the input file)
  fit_am1=mpfit('LINFITEX',PARINFO=PARINFO,BESTNORM=BESTNORM,PERROR=PERROR,$
            xtol=1.d-3,FUNCTARGS={x:am[filt1ind],y:mag_diff_UNcorr[filt1ind],$
            sigma_x:amerr[filt1ind],sigma_y:mag_diff_UNcorr_err[filt1ind]})

  print,fit_am1
  fit_am1err=perror

  xfit=DINDGEN(200)*0.1-10.  ;array for plotting best fit
  yfit_am1=fit_am1[1]*xfit + fit_am1[0]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;plot best fit 
  plot,am[filt1ind],mag_diff_UNcorr[filt1ind],psym=4,$
       yr=[MIN(mag_diff_UNcorr[filt1ind])-0.5,MAX(mag_diff_UNcorr[filt1ind])+0.5],$
       xr=[MIN(am[filt1ind])-0.5,MAX(am[filt1ind])+0.5],$
       ystyle=1,xstyle=1,$
       ytitle='!4D!3 mag',xtitle='Airmass (X)'
  oploterror,am[filt1ind],mag_diff_UNcorr[filt1ind],amerr[filt1ind],$
       mag_diff_UNcorr_err[filt1ind],psym=4
  oplot,xfit,yfit_am1
  legend,['k1 (slope)     = '+STRCOMPRESS(fit_am1[1],/remove_all)+$
          ' !9+!3 '+STRCOMPRESS(fit_am1err[1],/remove_all)],/bottom
  legend,[STRCOMPRESS(filt1+' band airmass correction')],/bottom,/right
  legend,[night[0]],/right
  
;for making the plots;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  IF (STRCMP(file_response,'y',/fold_case) eq 1) THEN BEGIN
    erase
    goto,loop1
  ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;stop the program to allow the user to view filter 1 airmass fit
  user_input=''
  read,'Hit enter to continue to next fit: ',user_input

  ;fit and plot airmass correction for filter 1 
  ;(aka the first filter listed in the input file)
  fit_am2=mpfit('LINFITEX',PARINFO=PARINFO,BESTNORM=BESTNORM,PERROR=PERROR,$
            xtol=1.d-3,FUNCTARGS={x:am[filt2ind],y:mag_diff_UNcorr[filt2ind],$
            sigma_x:amerr[filt2ind],sigma_y:mag_diff_UNcorr_err[filt2ind]})

  print,fit_am2
  fit_am2err=perror

  xfit=DINDGEN(200)*0.1-10.  ;array for plotting best fit
  yfit_am2=fit_am2[1]*xfit + fit_am2[0]

loop1:
  ;plot best fit 
  plot,am[filt2ind],mag_diff_UNcorr[filt2ind],psym=4,$
       yr=[MIN(mag_diff_UNcorr[filt2ind])-0.5,MAX(mag_diff_UNcorr[filt2ind])+0.5],$
       xr=[MIN(am[filt2ind])-0.5,MAX(am[filt2ind])+0.5],$
       ystyle=1,xstyle=1,$
       ytitle='!4D!3 mag',xtitle='Airmass (X)'
  oploterror,am[filt2ind],mag_diff_UNcorr[filt2ind],amerr[filt2ind],$
       mag_diff_UNcorr_err[filt2ind],psym=4
  oplot,xfit,yfit_am2
  legend,['k1 (slope)     = '+STRCOMPRESS(fit_am2[1],/remove_all)+$
          ' !9+!3 '+STRCOMPRESS(fit_am2err[1],/remove_all)],/bottom
  legend,[STRCOMPRESS(filt2+' band airmass correction')],/bottom,/right
  legend,[night[0]],/right

;for making the plots;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  IF (STRCMP(file_response,'y',/fold_case) eq 1) THEN BEGIN
    erase
    goto,loop2
  ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;stop the program to allow the user to view filter 2 airmass fit and continue 
  ;color corrections
  user_input=''
  read,'Hit enter to continue to next fit: ',user_input

ENDELSE

;define airmass constants for the different filters
;and correct for airmass
  ;distinguish between extinction fitting results and user input extinction coefficients
  IF KEYWORD_SET(INPUT_EXT) THEN BEGIN
    amcoeff1 = amcoeff_input1
    amcoefferr1 = amcoefferr_input1
    amcoeff2 = amcoeff_input2
    amcoefferr2 = amcoefferr_input2
  ENDIF ELSE BEGIN
    amcoeff1 = fit_am1[1]
    amcoefferr1 = fit_am1err[1]
    amcoeff2 = fit_am2[1]
    amcoefferr2 = fit_am2err[1]
  ENDELSE

  MagAMcorr[filt1ind]=Mag_instrumental[filt1ind] - AM[filt1ind]*AMcoeff1
  MagAMcorr_err[filt1ind] = SQRT(Mag_instrumental_err[filt1ind]^2 + $
                                (am[filt1ind]*amcoefferr1)^2 + (amcoeff1*amerr)^2) 


  MagAMcorr[filt2ind]=Mag_instrumental[filt2ind] - AM[filt2ind]*AMcoeff2
  MagAMcorr_err[filt2ind] = SQRT(Mag_instrumental_err[filt2ind]^2 + $
                                (am[filt2ind]*amcoefferr2)^2 + (amcoeff2*amerr)^2) 

  Mag_diff_AMcorr=magstandard - MagAMcorr
  Mag_diff_AMcorr_err=(magstandard_err^2 + MagAMcorr_err^2)

;set up color array
;standard colors
  color=magstandard[filt1ind]-magstandard[filt2ind]
  colorerr=SQRT(magstandard_err[filt1ind]^2+magstandard_err[filt2ind]^2)

;y-axis is the standard mag - airmass corr mag array
  y_filt1=magstandard[filt1ind]-magamcorr[filt1ind]
  y_filt1err=SQRT(magamcorr_err[filt1ind]^2+magstandard_err[filt1ind]^2)

  y_filt2=magstandard[filt2ind]-magamcorr[filt2ind]
  y_filt2err=SQRT(magamcorr_err[filt2ind]^2+magstandard_err[filt2ind]^2)

;begin fit of color correction
  parinfo = replicate({value:0.D,fixed:0.D,limits:[0.D,0.D],limited:[0.D,0.D],$
                       maxstep:[0.D]},2)

  parinfo[0].value=20
  ;parinfo[1].value=-0
  ;parinfo[0].limited[0]=1
  ;parinfo[1].limited[1]=1
  ;parinfo[0].limits=[-13,-5]
  ;parinfo[1].limits=[0.1,1]
  ;parinfo[1].step=0.5
  parinfo[0].maxstep=1.

  ;fit and plot for filter 1 (aka the first filter listed in the input file)
  fit_filt1=mpfit('LINFITEX',PARINFO=PARINFO,BESTNORM=BESTNORM,PERROR=PERROR,$
            xtol=1.d-3,FUNCTARGS={x:color,y:y_filt1,sigma_x:colorerr,$
            sigma_y:y_filt1err})

  fit_filt1err=perror

  xfit=DINDGEN(200)*0.1-10.  ;array for plotting best fit
  yfit_filt1=fit_filt1[1]*xfit + fit_filt1[0]

;calc and print out landolt mag to compare to tabulated landolt mag
zpoint1=fit_filt1[0]+fit_filt1[1]*color
print,'calculated landolt magnitude'
print,magamcorr[filt1ind]+zpoint1
print,'tabulated landolt magnitude'
print,magstandard[filt1ind]
print,'difference:'
print,magamcorr[filt1ind]+zpoint1-magstandard[filt1ind]

loop2:
;plot best fit 
plot,color,y_filt1,psym=4,yr=[MIN(y_filt1)-1,MAX(y_filt1)+1],$
     xr=[MIN(color)-0.5,MAX(color+0.5)],ystyle=1,xstyle=1,$
     ytitle=filt1,xtitle=color_text
oploterror,color,y_filt1,colorerr,y_filt1err,psym=4
oplot,xfit,yfit_filt1
legend,['C0 (intercept) = '+STRCOMPRESS(fit_filt1[0],/remove_all)+$
        ' !9+!3 '+STRCOMPRESS(fit_filt1err[0],/remove_all),$
        'C1 (slope)     = '+STRCOMPRESS(fit_filt1[1],/remove_all)+$
        ' !9+!3 '+STRCOMPRESS(fit_filt1err[1],/remove_all)],/bottom
legend,[night[0]],/right

;for making the plots;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IF (STRCMP(file_response,'y',/fold_case) eq 1) THEN BEGIN
    erase
    goto,loop3
  ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;stop the program to allow the user to view filter 1 fit
user_input=''
read,'Hit enter to continue to next fit: ',user_input

;fit and plot for filter 2 (aka the second filter listed in the input file)
parinfo[1].maxstep=0.01

fit_filt2=mpfit('LINFITEX',PARINFO=PARINFO,BESTNORM=BESTNORM,PERROR=PERROR,$
          xtol=1.d-3,FUNCTARGS={x:color,y:y_filt2,sigma_x:colorerr,$
          sigma_y:y_filt2err})

fit_filt2err=perror

yfit_filt2=fit_filt2[1]*xfit + fit_filt2[0]

;calc and print out landolt mag to compare to tabulated landolt mag
zpoint2=fit_filt2[0]+fit_filt2[1]*color
print,'calculated landolt magnitude'
print,magamcorr[filt2ind]+zpoint2
print,'tabulated landolt magnitude'
print,magstandard[filt2ind]
print,'difference:'
print,magamcorr[filt2ind]+zpoint2-magstandard[filt2ind]

loop3:
;plot best fit 
plot,color,y_filt2,psym=4,yr=[MIN(y_filt2)-1,MAX(y_filt2)+1],$
     xr=[MIN(color)-0.5,MAX(color+0.5)],$
     ystyle=1,xstyle=1,$
     ytitle=filt2,xtitle=color_text
oploterror,color,y_filt2,colorerr,y_filt2err,psym=4
oplot,xfit,yfit_filt2
legend,['C0 (intercept) = '+STRCOMPRESS(fit_filt2[0],/remove_all)+$
        ' !9+!3 '+STRCOMPRESS(fit_filt2err[0],/remove_all),$
        'C1 (slope)     = '+STRCOMPRESS(fit_filt2[1],/remove_all)+$
        ' !9+!3 '+STRCOMPRESS(fit_filt2err[1],/remove_all)],/bottom
legend,[night[0]],/right

;set_plot,'ps'
;device,filename='zpt_mag.ps'
;plot,MagAMcorr[filt2ind],y_filt2,psym=4,xtitle='r!d0!n (Airmass corrected instrumental mags)',$
;     ytitle='r!do!n - R(landolt)',$
;     xr=[-15,-7],yr=[-26,-24]
;     ;oplot,MagAMcorr[filt1ind],y_filt1,psym=5
;device,/close
;set_plot,'x'

;for making the plots;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  IF (STRCMP(file_response,'y',/fold_case) eq 1) THEN BEGIN
    DEVICE,/CLOSE
    SET_PLOT,'X'
    goto,loopend
  ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;ask user if the plot is good and write the plot to a file if it is a good plot
  read,'Would you like to write these plots to a file? (y/n)',file_response

  IF (STRCMP(file_response,'y',/fold_case) eq 1) THEN BEGIN
    goto,loop0
  ENDIF

loopend:    
;make text output file of calibration constants
OPENW,U,night[0]+filt1+filt2+'.cal',/GET_LUN
PRINTF,U,F='(A-11,5x,A5,3x,A7,A9,3x,A7,2x,A13,2x,A7,2x,A10,2x,A7,2x)',$
        'night','color','filter','AmCoef','Error','C0(intercept)','Error','C1(slope)','Error'
PRINTF,U,F='(A-11,3x,A5,A7,6x,d8.4,3x,d7.4,2x,d13.5,2x,d7.4,2x,d10.4,2x,d7.4)',$
        night[0],color_text,filt1,amcoeff1,amcoefferr1,fit_filt1[0],fit_filt1err[0],fit_filt1[1],fit_filt1err[1]
PRINTF,U,F='(A-11,3x,A5,A7,6x,d8.4,3x,d7.4,2x,d13.5,2x,d7.4,2x,d10.4,2x,d7.4)',$
        night[0],color_text,filt2,amcoeff2,amcoefferr2,fit_filt2[0],fit_filt2err[0],fit_filt2[1],fit_filt2err[1]
FREE_LUN,U

STOP
END
