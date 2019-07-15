package PkgIterativeSeeding is

  -- The actual number of seeds produced
  constant N_Seeds : integer := 8;

  -- Number of groups of non-neighbouring PF regions
  -- Generall expected to be 4 or 9 depending on sub-region size   
  constant N_Region_Groups : integer := 4;

  -- Number of particles to select from each region before sorting down
  -- Any particles further down the pt-sorted region list will not become a seed
  constant N_Parts_Per_Region : integer := 4;

  -- Number of particles to keep after region groups are merged
  constant N_Parts_Per_Region_Group : integer := 16;  


end package;
