function linfitex, p, x=x, y=y, $
                   sigma_y=sigma_y, $
                   _EXTRA=extra

  a = p[0]   ;; Intercept
  b = p[1]   ;; Slope

  f = a + b*x

  resid = (y - f)/(sigma_y)

  return, resid
end
