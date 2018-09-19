;This program will read in a messy NED compact_2 batch inquiry and print out
;the ra,dec,and redshift.  The NED file will have stuff above and below the 
;data so erase this.  Make the first line of the modified file an ra and dec line.
;Also, leave one space below the last line; whether an object is found or not.

;.r readned
;readned,'file_input','file_ouput'

pro readned,input,output

lines=''
i=0

openr,1,input

WHILE (not EOF(1)) do begin
    readf,1,lines
    i+=1
ENDWHILE

close,1

length=i

ra=DBLARR(length/5)
dec=DBLARR(length/5)
z=DBLARR(length/5)

F='(74x,D)'

openr,U,input,/GET_LUN
FOR n=0, length-1 DO BEGIN
  readf,U,lines
  
  temp=STRSPLIT(lines,';',/extract)
    
  IF (STRCMP(temp(3),' No object is found')) THEN BEGIN
    ra[n]=DOUBLE(temp(0))
    dec[n]=DOUBLE(temp(1))
    z[n]=-99
    IF (EOF(U)) THEN BEGIN
      goto,loopend
    ENDIF
    readf,U,lines
    IF (EOF(U)) THEN BEGIN
      goto,loopend
    ENDIF
    readf,U,lines
    IF (EOF(U)) THEN BEGIN
      goto,loopend
    ENDIF
    readf,U,lines 
    IF (EOF(U)) THEN BEGIN
      goto,loopend
    ENDIF
    
    goto,loop
       
  ENDIF

  IF (strcmp(temp(3),'   1 object(s) found.')) THEN BEGIN
    ra[n]=DOUBLE(temp(0))
    dec[n]=DOUBLE(temp(1))
    readf,U,lines
    readf,U,lines,FORMAT=F
        
    z[n]=DOUBLE(lines)
    readf,U,lines
    IF (EOF(U)) THEN BEGIN
      goto,loopend
    ENDIF
    readf,U,lines
    IF (EOF(U)) THEN BEGIN
      goto,loopend
    ENDIF
    readf,U,lines
    IF (EOF(U)) THEN BEGIN
      goto,loopend
    ENDIF
    readf,U,lines
  ENDIF

  IF (strcmp(temp(3),'   2 object(s) found.')) THEN BEGIN
    ra[n]=DOUBLE(temp(0))
    dec[n]=DOUBLE(temp(1))
    readf,U,lines
    readf,U,lines,FORMAT=F
    
    z[n]=DOUBLE(lines)
    IF (EOF(U)) THEN BEGIN
      goto,loopend
    ENDIF
    readf,U,lines
    IF (EOF(U)) THEN BEGIN
      goto,loopend
    ENDIF
    readf,U,lines
    IF (EOF(U)) THEN BEGIN
      goto,loopend
    ENDIF
    readf,U,lines
    IF (EOF(U)) THEN BEGIN
      goto,loopend
    ENDIF
    readf,U,lines
    readf,U,lines
    readf,U,lines
  ENDIF
  
  IF (strcmp(temp(3),'   3 object(s) found.')) THEN BEGIN
    ra[n]=DOUBLE(temp(0))
    dec[n]=DOUBLE(temp(1))
    readf,U,lines
    readf,U,lines,FORMAT=F
    
    z[n]=DOUBLE(lines)
    IF (EOF(U)) THEN BEGIN
      goto,loopend
    ENDIF
    readf,U,lines
    IF (EOF(U)) THEN BEGIN
      goto,loopend
    ENDIF
    readf,U,lines
    IF (EOF(U)) THEN BEGIN
      goto,loopend
    ENDIF
    readf,U,lines
    IF (EOF(U)) THEN BEGIN
      goto,loopend
    ENDIF
    readf,U,lines
    readf,U,lines
    readf,U,lines
    readf,U,lines
    readf,U,lines
  ENDIF

  loop:

ENDFOR

loopend:

FREE_LUN,U

;truncate array to match number of actual elements
ra=ra[0:n]
dec=dec[0:n]
z=z[0:n]

openw,U,output,/GET_LUN
printf,U,'      RA     ','      DEC      ','     REDSHIFT'
FOR k=0, n DO BEGIN
  printf,U,F='(D12.4,2x,D12.4,2x,D12.4)',ra[k],dec[k],z[k]
ENDFOR
FREE_LUN,U

STOP
END
