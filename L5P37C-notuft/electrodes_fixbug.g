// genesis (R.M. 12/12/95)

// Copied from Parallel_fiber.g on 29/12//2001
// Intended to model a 2D array of electrodes

// IMPORTANT
// Because the efield object is not yet supported by the hines solver,
// the elctrodes must be made, and connected, after the hines solver 
// has been installed for the compartments to which the electrodes 
// are to be connected.
// For this reason, the constants, makearray and setup of messages are
// collapsed in this single script.


// according to Hugo Cornelis, now supported by hines solver (9/12/2006)


//include defaults
//include Gran_layer_const.g

echo making electrodes

// the constants

   int nx = 1 // 8 // 1 // 10 // 9 // 3 // 1   // number of electrodes along X-axis
   int ny = 1 // 8 // 1 // 10 // 9 // 3 // 1   // number of electrodes along Y-axis
   int number_electrodes = {nx * ny}
   float dx = 40e-6 // 50e-6 // 0  // interelectrode spacing
   float dy = 40e-6 // 50e-6 // 0 
   float ox = 20e-6 // -140e-6 // 20e-6 // 0 // -225e-6 // -50e-6 // 20e-6 // 0 
   float oy = 20e-6 // -140e-6 // 20e-6 // 0 // -225e-6 // -50e-6 // 20e-6 // 0

   int number_contact_points = 8 // 11 // 1 // 11
   float contact_separation = 0.1e-3 // 0.15e-3 // 0.6e-3
   float depth = -0.15e-3 // -0.5e-3 // 0 // -0.5e-3 // -1e-3 // vertical position electrode tip (on z-axis)

   int i //  j, index

// the make function


// make 1 prototype electrode

function make_electrode_shaft (number_contact_points, contact_separation, depth)

   int number_contacts_points, i
   float contact_separation, depth

   create efield /library/contact
   setfield ^ scale -1e-3

//   possibility to low-pass-filter the electrode signal, so that it
//   can be sampled at a lower clock rate

   create RC /library/contact/RC 
   setfield ^ V0 0 R 1 C 0.005  // should give same amplitude as input,
                                //  but low-pass-filtered with tau 1 ms

   addmsg /library/contact /library/contact/RC INJECT field

   if(!{exists /library/electrode})
          create neutral /library/electrode 
   end

   createmap /library/contact  /library/electrode 1 {number_contact_points} \ 
                        -delta 0 {contact_separation} -origin 0 {depth}

   for (i = 0; {i < number_contact_points}; i = i + 1)
       setfield /library/electrode/contact[{i}] z {getfield /library/electrode/contact[{i}] y}
       setfield /library/electrode/contact[{i}] y 0
   end
 
end



// make array of electrodes

function make_electrode_array  (number_contact_points, contact_separation, depth, nx, ny, dx, dy, ox, oy)

   int   length, number_contact_points
   float depth, contact_separation 

   int   nx, ny // n = number
   float dx, dy, ox, oy // d = delta, o = origin

   if(!{exists /library})
          create neutral /library 
          disable /library
   end

   make_electrode_shaft {number_contact_points} {contact_separation} {depth}

   createmap /library/electrode /electrode_array  {nx} {ny} -delta {dx} {dy} -origin {ox} {oy}

end


// make the array

   create neutral /electrode_array
   make_electrode_array {number_contact_points} {contact_separation} {depth} {nx} {ny} {dx} {dy} {ox} {oy}


// connect all electrodes to all compartments of the PC

echo making msgs to electrodes

   float el_x, el_y, el_z  // (x,y,z) coordinates of electrode
   float cp_x, cp_y, cp_z  // (x,y,z) coordinates of compartment
   float distance          // distance between electrode and compartment
   str name, name2, elem

// this makes the msgs using diffamps to fix the hinessolver bug
   include electrodes_try.g



// connect the electrodes to an asc_file element

   str electrodes_ascii_filename   // =  "electrodes" @ "label" & ".ascii"
   str name2, pathname

   for (i = 0; i < {number_electrodes}; i = i + 1)
 
      pathname = "/output/electrode" @ {i}
      electrodes_ascii_filename   =  {filename} @ "electrode" @ {i} @ ".ascii"

      if (!({exists {pathname}}))
            create asc_file {pathname}
      end
//   setclock 7 20e-5
      useclock {pathname} 1
      enable /output
      enable {pathname}
      setfield {pathname} filename {electrodes_ascii_filename} \ 
               initialize 1 leave_open 1  flush 1
      echo Output to {electrodes_ascii_filename}

      foreach name2 ({el /electrode_array/electrode[{i}]/##[][TYPE=efield]})

          addmsg {name2} {pathname} SAVE field
//          addmsg {name2}/RC  /output/electrodes SAVE state
      end

end


// this reset is needed to activate the connections to the asc_file object ? 

//   reset















