;+
; PROCEDURE:
;         elf_write_data_availability_table
;
; PURPOSE:
;         Write to and update the data availability
;
; KEYWORDS:
;         tdate: time to be used for calculation
;                (format can be time string '2020-03-20'
;                or time double)
;         probe: probe name, probes include 'a' and 'b'
;         instrument: instrument name, insturments include 'epd', 'fgm', 'mrm'
;         data: structure containing the availability data, start times, stop
;               times and science zone 
;
; OUTPUT:
;
; EXAMPLE:
;         elf_write_data_availability_table, filename, data_avail, 'epd', 'a'
;         
;LAST EDITED: lauraiglesias4@gmail.com 11/10/20
;
;-
pro elf_write_data_availability_table, filename, data_available, instrument, probe

  ; initialize parameters
  if undefined(filename) then begin
    print, 'You must provide a name for the csv file.'
    return
  endif
  if undefined(data_available) then begin
    print, 'You must provide data availability for the csv file.'
    return
  endif

  ;finding local directory
  ;cwd, !elf.LOCAL_DATA_DIR+'el'+probe+ '/data_availability/'
 
  
  if instrument NE 'mrm' then begin
    zone_names=['sasc','nasc','sdes','ndes']  
    for i=0,n_elements(data_available.zones)-1 do begin
      if data_available.zones[i] eq zone_names[0] then data_available.zones[i] = 'South Ascending'
      if data_available.zones[i] eq zone_names[1] then data_available.zones[i] = 'North Ascending'
      if data_available.zones[i] eq zone_names[2] then data_available.zones[i] = 'South Descending'
      if data_available.zones[i] eq zone_names[3] then data_available.zones[i] = 'North Descending'
    endfor
      ;current = where(data_available.zones eq zone_names[i])
      ;if current[0] ne -1 then begin
        
        newdat = {name:'newdat', starttimes: data_available.starttimes, endtimes: data_available.endtimes, dL:data_available.dL, medMLT:data_available.medMLT, zonenames: data_available.zones}
        
        this_file = filename + '_' + 'all' + '.csv'  
        
        ;writing the header. the position is added to the header
        ;if i eq 0 then pos = ' South Ascending'
        ;if i eq 1 then pos = ' North Ascending'
        ;if i eq 2 then pos = ' South Descending'
        ;if i eq 3 then pos = ' North Descending'
        pos = 'all'

        header = 'ELFIN ' + strupcase(probe) + ' - '+ strupcase(instrument) + pos + ' Science Collections'
        print, this_file
        ;reading the data
        
        ;making sure the file exists. if not, it will just create one
        existing = FILE_TEST(this_file)
        if existing eq 0 then begin
          starttimes = newdat.starttimes
          endtimes = newdat.endtimes
          dL = newdat.dL
          medMLT = newdat.medMLT
          zonenames = newdat.zonenames
          endif else begin 
          olddat = READ_CSV(this_file, N_TABLE_HEADER = 2)
          ;finding the start/end index
          olddat_doub = {name:'olddat_doub', starttimes: time_double(olddat.field1), endtimes: time_double(olddat.field2), dL:olddat.field3, medMLT:olddat.field4, zonenames:olddat.field5}
          UNDEFINE, olddat
          
          starttimes = [olddat_doub.starttimes, newdat.starttimes]
          endtimes = [olddat_doub.endtimes, newdat.endtimes]
          dL = [olddat_doub.dL, newdat.dL]
          medMLT = [olddat_doub.medMLT, newdat.medMLT]
          zonenames = [olddat_doub.zonenames, newdat.zonenames]
          endelse 
  
        ;sorting
        
        sorting = sort(starttimes)
        starttimes = starttimes[sorting]
        endtimes = endtimes[sorting]
        dL = dL[sorting]
        medMLT = medMLT[sorting]
        zonenames = zonenames[sorting]
        UNDEFINE, sorting

        unique = uniq(time_string(starttimes))
        starttimes = starttimes[unique]
        endtimes = endtimes[unique]
        dL = dL[unique]
        medMLT = medMLT[unique]
        zonenames = zonenames[unique]
        UNDEFINE, unique
        
  
        ;rewriting existing file
        write_csv, this_file, time_string(starttimes), time_string(endtimes), dL, medMLT, zonenames, HEADER = ['tstart', 'tend', 'Lstart, Lend', 'median MLT', 'Zones'], TABLE_HEADER=header
        ;write_csv, this_file, time_string(starttimes), time_string(endtimes), dL, medMLT, TABLE_HEADER=header
        print, 'Finished Writing to File: ', this_file
        print, 'Last Entry: ', time_string(starttimes[-1])
        
      ;endif
      close, /all
      
    ;endfor
    
 endif else begin
      ;  handle mrm data (should only be one entry)
      
      ;reading the data passed in
      this_file = 'el'+probe+'_'+instrument+'.csv'
      newdat = {name:'newdat', starttimes: data_available.starttimes, endtimes: data_available.endtimes, dL:data_available.dL, medMLT:data_available.medMLT}

      ;writing the header
      header = 'ELFIN '+ strupcase(probe) + ' - '+ strupcase(instrument)
      
       ;reading the data
      
       ;Making sure the file exists. If not, it will just create one
       existing = FILE_TEST(this_file)
       if existing eq 0 then begin
          starttimes = newdat.starttimes
          endtimes = newdat.endtimes
          dL = newdat.dL
          medMLT = newdat.medMLT
       endif else begin 
          olddat = READ_CSV(this_file, N_TALBE_HEADER = 2)
          
          ;finding the start/end index
          olddat_doub = {name:'olddat_doub', starttimes: time_double(olddat.field1), endtimes: time_double(olddat.field2), dL:olddat.field3, medMLT:olddat.field4}
          UNDEFINE, olddat
          
          starttimes = [olddat_doub.starttimes, newdat.starttimes]
          endtimes = [olddat_doub.endtimes, newdat.endtimes]
          dL = [olddat_doub.dL, newdat.dL]
          medMLT = [olddat_doub.medMLT, newdat.medMLT]
       endelse 
       close, /all
        sorting = sort(starttimes)
        starttimes = starttimes[sorting]
        endtimes = endtimes[sorting]
        dL = dL[sorting]
        medMLT = medMLT[sorting]

        UNDEFINE, sorting

        unique = uniq(time_string(starttimes))
        starttimes = starttimes[unique]
        endtimes = endtimes[unique]
        dL = dL[unique]
        medMLT = medMLT[unique]

        UNDEFINE, unique
      stop
      ;rewriting existing file
      write_csv, this_file, time_string(starttimes), time_string(endtimes), dL, medMLT, HEADER = ['tstart', 'tend', 'Lstart, Lend', 'median MLT'], TABLE_HEADER=header
      
      ;write_csv, this_file, time_string(starttimes), time_string(endtimes), dL, medMLT, TABLE_HEADER=header
      print, 'Finished Writing to File: ', this_file
      close, /all
      
 endelse
end