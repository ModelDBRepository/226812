// genesis

// Creates for each compartment element of L5P an associated randomspike element
// located at the same position, and connected to the L5P cell using volumeconnect.
// The randomspike elements are collected in /Excitatory_fibres.
// The connections may be laid horizontally, using only the z-coordinate as a criterion,
// or radially, allowing the fibre to connect to all compartments at about the same
// position from the soma.

// Inaddition (from 6Oct07) creates for each randomspike element a diffamp from which 
// it will receive a RATE msg.

// Moreover, both randomspike and diffamp populations are divided into 3 equal parts:
// feedforward afferents, intracolumn feedbak afferents and intercolumn feedback afferents.

 
int  index


include Fibres.g

make_fibres /Excitatory_fibres


 
// Connecting fibres to L5P *****

ce /Excitatory_fibres


// First connection scheme: each fiber runs horizontally and is allowed to make a synapse
// on each compartment in (approximately) the same horizontal plane


echo Connecting excitatory feedforward fibres 

      volumeconnect FF/FF_fibre[] \
                    /L5P/p#[][TYPE=compartment]/AMPA \
                    -relative \
                    -sourcemask box -1 -1 -1 1 1 1 \
                    -destmask ellipsoid 0 0 0 1 1 2e-6 \ 
                    -probability 0.05 // 1.0 // {P_parallel_fiber_to_Golgi_cell_synapse}

      volumeweight FF/FF_fibre[] \
                   /L5P/p#[][TYPE=compartment]/AMPA  -fixed \
                   {weight_AMPA_synapse * 0.05} -uniform {weight_distribution}

      volumedelay   FF/FF_fibre[] \
                    /L5P/p#[][TYPE=compartment]/AMPA \
                    -radial {E_fibre_conduction_velocity} -uniform {delay_distribution}


echo Connecting excitatory intracolumnar feedback fibres 

      volumeconnect FBintra/FBintra_fibre[] \
                    /L5P/p#[][TYPE=compartment]/AMPA \
                    -relative \
                    -sourcemask box -1 -1 -1 1 1 1 \
                    -destmask ellipsoid 0 0 0 1 1 2e-6 \ 
                    -probability 0.05 // 1.0 // {P_parallel_fiber_to_Golgi_cell_synapse}

      volumeweight FBintra/FBintra_fibre[] \
                   /L5P/p#[][TYPE=compartment]/AMPA  -fixed \
                   {weight_AMPA_synapse * 0.05} -uniform {weight_distribution}

      volumedelay   FBintra/FBintra_fibre[] \
                    /L5P/p#[][TYPE=compartment]/AMPA \
                    -fixed 0.02 // -radial {E_fibre_conduction_velocity} -uniform {delay_distribution}

/*
echo Connecting excitatory intercolumnar feedback fibres

      volumeconnect FBinter/FBinter_fibre[] \
                    /L5P/p#[][TYPE=compartment]/AMPA \
                    -relative \
                    -sourcemask box -1 -1 -1 1 1 1 \
                    -destmask ellipsoid 0 0 0 1 1 2e-6 \ 
                    -probability 0.05 // 1.0 // {P_parallel_fiber_to_Golgi_cell_synapse}

      volumeweight FBinter/FBinter_fibre[] \
                   /L5P/p#[][TYPE=compartment]/AMPA  -fixed \
                   {weight_AMPA_synapse} -uniform {weight_distribution}

      volumedelay   FBinter/FBinter_fibre[] \
                    /L5P/p#[][TYPE=compartment]/AMPA \
                    -radial {E_fibre_conduction_velocity} -uniform {delay_distribution}
*/

/*

// Second connection scheme: each fiber is allowed to make a synapse on compartments
// located from the soma (the origin) at the same distance as the compartment to which the fibre
// has been associated (remember that a fibre for each compartment was created).
int i
float r, x1, y1, z1

      ce {FF}

      for (i = 0; i < 686; i = {i} + 1)
          x1 = {getfield FF_fibre[{i}] x}
          y1 = {getfield FF_fibre[{i}] y}
          z1 = {getfield FF_fibre[{i}] z}
          r = {sqrt {x1*x1 + y1*y1 + z1*z1}}
//          echo {r}

          volumeconnect FF_fibre[{i}] \
                    /L5P/p#[][TYPE=compartment]/AMPA \
                    -sourcemask box -1 -1 -1 1 1 1 \
                    -destmask ellipsoid 0 0 0 {r + 1e-6} {r + 1e-6} {r + 1e-6} \ 
                    -desthole ellipsoid 0 0 0 {r - 1e-6} {r - 1e-6} {r - 1e-6} \ 
                    -probability 0.1 // 0.05
      end

      volumeweight FF_fibre[] \
                   /L5P/p#[][TYPE=compartment]/AMPA  -fixed \
                   {weight_AMPA_synapse} -uniform {weight_distribution}

      volumedelay   FF_fibre[] \
                    /L5P/p#[][TYPE=compartment]/AMPA \
                    -radial {E_fibre_conduction_velocity} -uniform {delay_distribution}


      ce {FBintra}

      for (i = 0; i < 686; i = {i} + 1)
          x1 = {getfield FBintra_fibre[{i}] x}
          y1 = {getfield FBintra_fibre[{i}] y}
          z1 = {getfield FBintra_fibre[{i}] z}
          r = {sqrt {x1*x1 + y1*y1 + z1*z1}}
//          echo {r}
  
          volumeconnect FBintra_fibre[{i}] \
                    /L5P/p#[][TYPE=compartment]/AMPA \
                    -sourcemask box -1 -1 -1 1 1 1 \
                    -destmask ellipsoid 0 0 0 {r + 1e-6} {r + 1e-6} {r + 1e-6} \ 
                    -desthole ellipsoid 0 0 0 {r - 1e-6} {r - 1e-6} {r - 1e-6} \ 
                    -probability 0.1 // 0.05
      end

      volumeweight FBintra_fibre[] \
                   /L5P/p#[][TYPE=compartment]/AMPA  -fixed \
                   {weight_AMPA_synapse} -uniform {weight_distribution}

      volumedelay   FBintra_fibre[] \
                    /L5P/p#[][TYPE=compartment]/AMPA \
                    -radial {E_fibre_conduction_velocity} -uniform {delay_distribution}




      ce {FBinter}

      for (i = 0; i < 686; i = {i} + 1)
          x1 = {getfield FBinter_fibre[{i}] x}
          y1 = {getfield FBinter_fibre[{i}] y}
          z1 = {getfield FBinter_fibre[{i}] z}
          r = {sqrt {x1*x1 + y1*y1 + z1*z1}}
//          echo {r}
  
          volumeconnect FBinter_fibre[{i}] \
                    /L5P/p#[][TYPE=compartment]/AMPA \
                    -sourcemask box -1 -1 -1 1 1 1 \
                    -destmask ellipsoid 0 0 0 {r + 1e-6} {r + 1e-6} {r + 1e-6} \ 
                    -desthole ellipsoid 0 0 0 {r - 1e-6} {r - 1e-6} {r - 1e-6} \ 
                    -probability 0.1 // 0.05
      end

      volumeweight FBinter_fibre[] \
                   /L5P/p#[][TYPE=compartment]/AMPA  -fixed \
                   {weight_AMPA_synapse} -uniform {weight_distribution}

      volumedelay   FBinter_fibre[] \
                    /L5P/p#[][TYPE=compartment]/AMPA \
                    -radial {E_fibre_conduction_velocity} -uniform {delay_distribution}




*/


