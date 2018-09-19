pro sexwrite, lun, file=file, DETECT_THRESH=DETECT_THRESH,$
  DETECT_MINAREA=DETECT_MINAREA, SEEING_FWHM=SEEING_FWHM, $
  BACK_SIZE=BACK_SIZE, BACK_FILTERSIZE=BACK_FILTERSIZE, $
  BACKPHOTO_THICK=BACKPHOTO_THICK, BACKPHOTO_TYPE=BACKPHOTO_TYPE, $
  DEBLEND_NTHRESH=DEBLEND_NTHRESH, DEBLEND_MINCONT=DEBLEND_MINCONT,$
  PHOT_APERTURES=PHOT_APERTURES,CHECKIMAGE_NAME=CHECKIMAGE_NAME,$
  FILTER_NAME=FILTER_NAME, THRESH_TYPE=THRESH_TYPE,$
  BACK_TYPE=BACK_TYPE, BACK_VALUE=BACK_VALUE, FILTER_ON=FILTER_ON
  
  if (n_elements(file) eq 0) then begin
    print,'need to specify a file name, try again!'
    stop
  endif

  ;set to default value if not specified
  if n_elements(DETECT_THRESH) eq 0 then DETECT_THRESH=5.
  if n_elements(DETECT_MINAREA) eq 0 then DETECT_MINAREA=5.
  ;if n_elements(DETECT_MAXAREA) eq 0 then DETECT_MAXAREA=500
  if n_elements(SEEING_FWHM) eq 0 then SEEING_FWHM=1.5
  if n_elements(BACK_SIZE) eq 0 then BACK_SIZE=64.
  if n_elements(BACK_FILTERSIZE) eq 0 then BACK_FILTERSIZE=3
  if n_elements(BACKPHOTO_THICK) eq 0 then BACKPHOTO_THICK=24
  if n_elements(BACKPHOTO_TYPE) eq 0 then BACKPHOTO_TYPE='GLOBAL'
  if n_elements(DEBLEND_NTHRESH) eq 0 then DEBLEND_NTHRESH=32
  if n_elements(DEBLEND_MINCONT) eq 0 then DEBLEND_MINCONT=0.01
  if n_elements(PHOT_APERTURES) eq 0 then PHOT_APERTURES=5
  if n_elements(CHECKIMAGE_NAME) eq 0 then CHECKIMAGE_NAME='check.fits'
  if n_elements(FILTER_NAME) eq 0 then FILTER_NAME='default.conv'
  if n_elements(THRESH_TYPE) eq 0 then THRESH_TYPE='RELATIVE'
  if n_elements(BACK_TYPE) eq 0 then BACK_TYPE='AUTO'
  if n_elements(BACK_VALUE) eq 0 then BACK_VALUE=0.
  if n_elements(FILTER_ON) eq 0 then FILTER_ON='N'
  
  
  openw,lun,file
    printf,lun,'#-------------------------------- Catalog ------------------------------------ '
    printf,lun,'                                                                               '
    printf,lun,'CATALOG_NAME     test.cat       # name of the output catalog                   '
    printf,lun,'CATALOG_TYPE     ASCII_HEAD     # NONE,ASCII,ASCII_HEAD, ASCII_SKYCAT,         '
    printf,lun,'                                # ASCII_VOTABLE, FITS_1.0 or FITS_LDAC         '
    printf,lun,'PARAMETERS_NAME  default.param  # name of the file containing catalog contents '
    printf,lun,'                                                                               '
    printf,lun,'#------------------------------- Extraction ---------------------------------- '
    printf,lun,'                                                                               '
    printf,lun,'DETECT_TYPE      CCD            		# CCD (linear) or PHOTO (with gamma correction)'
    printf,lun,'DETECT_MINAREA   '+strtrim(DETECT_MINAREA,2)+'  # minimum number of pixels above threshold     ';should be relatively small, aka let threshold sigma do the rejection
    ;printf,lun,'DETECT_MAXAREA   '+strtrim(DETECT_MAXAREA,2)+' # maximum number of pixels above threshold     ';!need to check
    printf,lun,'THRESH_TYPE      '+strtrim(THRESH_TYPE,2)+'  # threshold type: RELATIVE (in sigmas)         '
    printf,lun,'                                		# or ABSOLUTE (in ADUs)                        ';!need to check
    printf,lun,'DETECT_THRESH    '+strtrim(DETECT_THRESH,2)+'	# <sigmas> or <threshold>,<ZP> in mag.arcsec-2 '
    printf,lun,'ANALYSIS_THRESH  '+strtrim(DETECT_THRESH,2)+'	# <sigmas> or <threshold>,<ZP> in mag.arcsec-2 '
    printf,lun,'                                                                               '
    printf,lun,'FILTER           '+strtrim(FILTER_ON,2)+'	# apply filter for detection (Y or N)?         '
    printf,lun,'FILTER_NAME      '+strtrim(FILTER_NAME,2)+'   	# name of the file containing the filter       '
    printf,lun,'                                                                               '
    printf,lun,'DEBLEND_NTHRESH  '+strtrim(DEBLEND_NTHRESH,2)+'	# Number of deblending sub-thresholds          ';!need to check
    printf,lun,'DEBLEND_MINCONT  '+strtrim(DEBLEND_MINCONT,2)+'	# Minimum contrast parameter for deblending    ';!need to check
    printf,lun,'                                                                               '
    printf,lun,'CLEAN            Y              		# Clean spurious detections? (Y or N)?         '
    printf,lun,'CLEAN_PARAM      10             		# Cleaning efficiency                          ';range is 0.1-10; lower is more aggressive
    printf,lun,'                                                                               '
    printf,lun,'MASK_TYPE        CORRECT        		# type of detection MASKing: can be one of     '
    printf,lun,'                                		# NONE, BLANK or CORRECT                       '
    printf,lun,'                                                                               '
    printf,lun,'#------------------------------ Photometry ----------------------------------- '
    printf,lun,'                                                                               '
    printf,lun,'PHOT_APERTURES   '+strtrim(PHOT_APERTURES,2)+'	# MAG_APER aperture diameter(s) in pixels      '
    printf,lun,'PHOT_AUTOPARAMS  2.5, 1.5       		# MAG_AUTO parameters: <Kron_fact>,<min_radius>'
    printf,lun,'PHOT_AUTOAPERS   0.0,0.0        		# <estimation>,<measurement> minimum apertures'
    printf,lun,'PHOT_PETROPARAMS 2.0, 1.5       		# MAG_PETRO parameters: <Petrosian_fact>,      '
    printf,lun,'                                		# <min_radius>                                 '
    printf,lun,'PHOT_FLUXFRAC    0.5            		# flux fraction[s] used for FLUX_RADIUS        '
    printf,lun,'SATUR_LEVEL      50000.0        		# level (in ADUs) at which arises saturation   '
    printf,lun,'SATUR_KEY        SATURATE       		# keyword for saturation level (in ADUs)       '
    printf,lun,'                                                                               '
    printf,lun,'MAG_ZEROPOINT    0.0            		# magnitude zero-point                         '
    printf,lun,'MAG_GAMMA        4.0            		# gamma of emulsion (for photographic scans)   '
    printf,lun,'GAIN             1.0            		# detector gain in e-/ADU                      '
    printf,lun,'GAIN_KEY         GAIN           		# keyword for detector gain in e-/ADU          '
    printf,lun,'PIXEL_SCALE      0              		# size of pixel in arcsec (0=use FITS WCS info)'
    printf,lun,'                                                                               '
    printf,lun,'#------------------------- Star/Galaxy Separation ---------------------------- '
    printf,lun,'                                                                               '
    printf,lun,'SEEING_FWHM      '+strtrim(SEEING_FWHM,2)+'	# stellar FWHM in arcsec     ';!need to check
    printf,lun,'STARNNW_NAME     default.nnw    		# Neural-Network_Weight table filename         '
    printf,lun,'                                                                               '
    printf,lun,'#------------------------------ Background ----------------------------------- '
    printf,lun,'                                                                               '
    printf,lun,'BACK_SIZE        '+strtrim(BACK_SIZE,2)+'	# Background mesh: <size> or <width>,<height>  ';!need to check
    printf,lun,'BACK_FILTERSIZE  '+strtrim(BACK_FILTERSIZE,2)+'	# Background filter: <size> or <width>,<height>';!need to check
    printf,lun,'BACK_TYPE        '+strtrim(BACK_TYPE,2)+'	# AUTO or MANUAL                               ';!need to check
    printf,lun,'BACK_VALUE       '+strtrim(BACK_VALUE,2)+'	# If BACK_TYPE set to manual                   '
    printf,lun,'BACKPHOTO_TYPE   '+strtrim(BACKPHOTO_TYPE,2)+'	# can be GLOBAL or LOCAL                       '
    printf,lun,'BACKPHOTO_THICK  '+strtrim(BACKPHOTO_THICK,2)+'	# thickness of the background LOCAL annulu     ';!need to check
    printf,lun,'#------------------------------ Check Image ---------------------------------- '
    printf,lun,'                                                                               '  
    printf,lun,'CHECKIMAGE_TYPE  SEGMENTATION   		# can be NONE, BACKGROUND, BACKGROUND_RMS,     '
    printf,lun,'                                		# MINIBACKGROUND, MINIBACK_RMS, -BACKGROUND,   '
    printf,lun,'                                		# FILTERED, OBJECTS, -OBJECTS, SEGMENTATION,   '
    printf,lun,'                                		# or APERTURES                                 '
    printf,lun,'CHECKIMAGE_NAME  '+strtrim(CHECKIMAGE_NAME,2)+'	# Filename for the check-image                 '
    printf,lun,'                                                                               '
    printf,lun,'#--------------------- Memory (change with caution!) ------------------------- '
    printf,lun,'                                                                               '
    printf,lun,'MEMORY_OBJSTACK  3000           # number of objects in stack                   '
    printf,lun,'MEMORY_PIXSTACK  300000         # number of pixels in stack                    '
    printf,lun,'MEMORY_BUFSIZE   1024           # number of lines in buffer                    '
    printf,lun,'                                                                               '
    printf,lun,'#----------------------------- Miscellaneous --------------------------------- '
    printf,lun,'                                                                               '
    printf,lun,'VERBOSE_TYPE     QUIET          # can be QUIET, NORMAL or FULL                 '
    printf,lun,'WRITE_XML        N              # Write XML file (Y/N)?                        '
    printf,lun,'XML_NAME         sex.xml        # Filename for XML output                      '
    printf,lun,'NTHREADS          0             # Number of simultaneous threads for           '
  close,lun
  
end
