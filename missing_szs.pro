  ;+
  ; :Author: lauraigs
  ;-
pro missing_szs, probe = probe
  
  ;part 1: compile all epd availability files
  file_prefix = 'el'+probe+'_epd_'
  directions = ['nasc', 'ndes', 'sasc', 'sdes']
  sz_start = []
  sz_end = []
  foreach element, directions do begin
    file = file_prefix+element+'.csv'
    print, file
    szs = READ_CSV(file, N_TABLE_HEADER = 2)
    sz_start = [sz_start, time_double(szs.field1)]
    sz_end = [sz_end, time_double(szs.field2)]
  endforeach
  
  sorting = sort(sz_start)
  sz_start = sz_start[sorting]
  sz_end = sz_end[sorting]

  
  file='el'+probe+'_epde_phase_delays.csv'
  fits = READ_CSV(file, N_TABLE_HEADER = 1)
  fit_start = time_double(fits.field01)
  fit_end = time_double(fits.field02)
  
  ;;;;
  ;Testing
  sz_starttest = sz_start[1620:1634]
  sz_endtest = sz_end[1420:1434]

  fit_starttest = fit_start[1370:1400]
  fit_endtest = fit_end[1370:1400]
  ;;;;
  
  nofit_start = []
  nofit_end = []
  foreach element, sz_start, i do begin
    con1 = WHERE(fit_start GE sz_start[i], count)
    con2 = WHERE(fit_end LE sz_end[i], count)
    con3 = WHERE(con1 EQ con2)
    if con3 eq -1 then begin
      nofit_start = [nofit_start, time_string(sz_start[i])]
      nofit_end = [nofit_end, time_string(sz_end[i])]
    endif

  endforeach
 

  write_csv, 'missingszs.csv', nofit_start, nofit_end, TABLE_HEADER = 'Missing Science Zones for el-' +probe
  
  ;OPENR, lun, file, /get_lun
  ;array=''
  ;line=''
  ;while not EOF(lun) do begin
  ;  READF, lun, line
  ;  array=[array,line]
  ;endwhile
  ;free_lun, lun
  ;cols=strsplit(array[1],',',/extract) ;header names
  ;cols=strsplit(array[1],',',/extract)
END