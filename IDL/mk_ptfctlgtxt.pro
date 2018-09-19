pro mk_ctlgtext

spawn,'ls PTF_*c_p_*.ctlg > ctlg.list'
readcol,'ctlg.list',f='(a)',ctlgs

nctlgs=n_elements(ctlgs)

for i=0, nctlgs-1 do begin
    
    pid=(strsplit(ctlgs[i],'_.',/extract))(8)
    filt=(strsplit(ctlgs[i],'_.',/extract))(7)
    chip=(strsplit(ctlgs[i],'_.',/extract))(9)
    
    filtnum=(strsplit(filt,'f',/extract))(0)
    chipnum=(strsplit(chip,'c',/extract))(0)
    
    cat=mrdfits(ctlgs[i],1)

    nsrcs=n_elements(cat.X_WORLD)
    
    mag2=(cat.mag_aper)[0,*]     &       mag2err=(cat.magerr_aper)[0,*]   
    mag4=(cat.mag_aper)[1,*]     &       mag4err=(cat.magerr_aper)[1,*]   
    mag5=(cat.mag_aper)[2,*]     &       mag5err=(cat.magerr_aper)[2,*]   
    mag8=(cat.mag_aper)[3,*]     &       mag8err=(cat.magerr_aper)[3,*]   
    mag10=(cat.mag_aper)[4,*]	 &	mag10err=(cat.magerr_aper)[4,*]
            
    
    parinfo = replicate({value:0.D,fixed:0.D,limits:[0.D,0.D],limited:[0.D,0.D],mpmaxstep:[0.D]},2)

    xfit=ci[good]
    yfit=apcorr[good]
    yfiterr=n_elements(good)+0.2
    fit=mpfit('LINFITEX',PARINFO=PARINFO,BESTNORM=BESTNORM,PERROR=PERROR,xtol=1.d-3,/quiet,$
              FUNCTARGS={x:xfit,y:yfit,sigma_y:yfiterr})

    plot,ci[good],apcorr[good],psym=4,xtitle='CI (mag2px - mag4px)',$
         ytitle='ApCorr (mag10px - mag5px)',xr=[0,2],yr=[-2,1]
    xgen=findgen(10)-5
    oplot,xgen,xgen*fit[1]+fit[0]
    
    apcorr_ci=ci*fit[1]+fit[0]
    
    ;assign apcorr at edges of defined ci-aperture correction space
    apcorr_ci[where(ci le 1. or apcorr_ci gt -0.2)]=-0.2
    apcorr_ci[where(apcorr_ci le -1. or ci gt 1.5)]=-1.
        
    magcorr=mag5+apcorr_ci
    magcorr_err=mag5err

    openw,1,'PTF_'+pid+'_'+filt+'_'+chip+'.dat'
    printf,1,f='(a2,2x,a3,2x,a1,2x,a1,2x,a4,2x,a4,2x,a6,2x,a3,2x,a6,2x,a3,2x,a6,2x,a3,2x,a6,2x,a3,2x, a7,2x,a3,2x, a9,2x,a3,2x, a9,2x,a3)',$
             'ra','dec','X','Y','filt','chip','mag2px','Err',$
	     'mag2px','Err','mag4px','Err','mag5px','Err',$
	     'mag8px','Err','mag10px','Err','magApCorr','Err'
    for m=0, nsrcs-1 do begin
        printf,1,f='(d10.5,2x,d10.5,2x,f7.2,2x,f7.2,2x,i2,2x,i2,2x,f7.3,2x,f7.3,2x,f7.3,2x,f7.3,2x,f7.3,2x,f7.3,2x,f7.3,2x,f7.3,2x,f7.3,2x,f7.3,2x,f7.3,2x,f7.3)',$
                 cat[m].X_WORLD,cat[m].y_WORLD,$
                 cat[m].X_image,cat[m].y_image,$
                 filtnum,chipnum,$
                 mag2[m],mag2err[m],$
                 mag4[m],mag4err[m],$
                 mag5[m],mag5err[m],$
                 mag8[m],mag2err[m],$                 
                 mag10[m],mag10err[m],$
                 magcorr[m],magcorr_err[m]
                 
    endfor
    close,1
    stop
endfor

stop
end
