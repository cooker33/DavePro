;usage: lumerr_log=logerr(lum,lumerr)

function logerr,value,error

logerror=error/(value*alog(10.))

return,logerror
end
