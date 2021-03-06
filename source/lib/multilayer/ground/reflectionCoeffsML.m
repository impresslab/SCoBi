
function [r_g, pd] = reflectionCoeffsML
% function reflectionCoeffsML 
%
%   Calculates the equivalent reflection coefficients of the rough, 
%   multi-layered ground for the chosen ones of four dielectric profiles.
%	Penetration depth is calculated additionally if selected.
%
%   [r_g, pd] = reflectionCoeffsML
%
%   See also specularTerm, reflectionCoeffsSingle

%   Copyright � 2017-2018 Mehmet Kurum, Orhan Eroglu, Dylan R. Boyd

%   This program is free software: You can redistribute it and/or 
%   modify it under the terms of the GNU General Public License as 
%   published by the Free Software Foundation, either version 3 of the 
%   License, or (at your option) any later version.

%   Version: 1.0.3
%
%  %%%%%%%%%%%%%%%%%%%%%%%%%%  UPDATE HISTORY  %%%%%%%%%%%%%%%%%%%%%%%%%  %
%
%   Version 1.0.3
%
%   April 16, 2020
%
% Functionality added for calculating penetration depth. This function
% makes use of the energy incident upon the air-surface boundary. Thus,
% response to vegetation structures is not considered.
%
%   Version 1.0.2
%
%   July 13, 2019
%
%   Corrected an error in accounting for surface roughness seen in
%   multilayer scattering. calcSpecularReflectionCoeffML() is now used to
%   calculate the reflectivity from the dielectric slab function.
%
%   Version 1.0.1
%
%   November 14, 2018
%
%   Refitted the complex conjugate to make the physics-oriented multidiel 
%   function compatible with SCoBi. In engineering, j =sqrt(-1).
%   In physics, i = (-1)sqrt(-1).
%
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  %


%% GET GLOBAL PARAMETERS
sim_counter = ParamsManager.sim_counter;
% Transmitter Parameters
f_MHz = TxParams.getInstance.f_MHz;
f_Hz = f_MHz * Constants.MHZ_TO_HZ;
% Configuration Parameters
th0_Tx_list_deg = ConfigParams.getInstance.th0_Tx_list_deg;
th0_Tx_deg = th0_Tx_list_deg( sim_counter );
% Dielectric Parameters
eps_diel_z2nd = DielMLDynParams.getInstance.eps_diel_z2nd;
eps_diel_z3rd = DielMLDynParams.getInstance.eps_diel_z3rd;
eps_diel_zL = DielMLDynParams.getInstance.eps_diel_zL;
eps_diel_zS = DielMLDynParams.getInstance.eps_diel_zS;
% Ground Dynamic Params
eps_g = GndDynParams.getInstance.eps_g;
eps_g = conj(eps_g); % i --> j
% Ground MultiLayer Parameters
layer_bottom_m = GndMLParams.getInstance.layer_bottom_m;
zA_m = GndMLParams.getInstance.zA_m;    % Air layer
z_m = GndMLParams.getInstance.z_m;    % Layer profile
calc_diel_profile_fit_functions = GndMLParams.getInstance.calc_diel_profile_fit_functions;


%% CALCULATE REFLECTION COEFFICIENTS
% Wavelength
lambda_m = Constants.LIGHTSPEED / f_Hz ;

[num_diel_profiles, ~] = size(calc_diel_profile_fit_functions);

r_g = cell(num_diel_profiles, 1);

pd = cell(num_diel_profiles, 1);

% Reflection Coefficient for Discrete Slab
if calc_diel_profile_fit_functions(Constants.ID_DIEL_PROFILE_SLAB, 1)
    
    [rh_ds, rv_ds, pdh_ds, pdv_ds] = ...
        calcSpecularReflectionCoeffML(lambda_m, th0_Tx_deg, z_m, eps_diel_zS) ;
    
    r_g{Constants.ID_DIEL_PROFILE_SLAB, 1} = [rv_ds 0; 0 rh_ds];
    
    % assign penetration depth
    pd{Constants.ID_DIEL_PROFILE_SLAB, 1} = [pdv_ds; pdh_ds];

end

% Reflection Coefficient for Logistic Profile
if calc_diel_profile_fit_functions(Constants.ID_DIEL_PROFILE_LOGISTIC, 1)

    [rh_L, rv_L, pdh_L, pdv_L] = ...
        calcSpecularReflectionCoeffML(lambda_m, th0_Tx_deg, z_m, eps_diel_zL) ;
    
    r_g{Constants.ID_DIEL_PROFILE_LOGISTIC, 1} = [rv_L 0; 0 rh_L] ;
    
    % assign penetration depth
    pd{Constants.ID_DIEL_PROFILE_LOGISTIC, 1} = [pdh_L; pdv_L] ;
    
end


% Reflection Coefficient for 2nd Order Profile
if calc_diel_profile_fit_functions(Constants.ID_DIEL_PROFILE_2ND_ORDER, 1)
    
    [rh_2nd, rv_2nd, pdh_2nd, pdv_2nd] = ...
        calcSpecularReflectionCoeffML(lambda_m, th0_Tx_deg, z_m, eps_diel_z2nd ) ;
    
    r_g{Constants.ID_DIEL_PROFILE_2ND_ORDER, 1} = [rv_2nd 0; 0 rh_2nd] ;
    
    % assign penetration depth
    pd{Constants.ID_DIEL_PROFILE_2ND_ORDER, 1} = [pdh_2nd ; pdv_2nd] ;
    
end


% Reflection Coefficient for 3rd Order Profile
if calc_diel_profile_fit_functions(Constants.ID_DIEL_PROFILE_3RD_ORDER, 1)
    
    [rh_3rd, rv_3rd, pdh_3rd, pdv_3rd] = ...
        calcSpecularReflectionCoeffML(lambda_m, th0_Tx_deg, z_m, eps_diel_z3rd ) ;
    
    r_g{Constants.ID_DIEL_PROFILE_3RD_ORDER, 1} = [rv_3rd 0; 0 rh_3rd] ;
    
    % assign penetration depth
    pd{Constants.ID_DIEL_PROFILE_3RD_ORDER, 1} = [pdh_3rd; pdv_3rd] ;
    
end

end


function [rh, rv, pdh, pdv] = ...
    calcSpecularReflectionCoeffML(lambda_m, th0_Tx_deg, z_m, eps_diel_z)

Lz = diff(z_m)' / lambda_m ; % complex optical length in units of lambda_m

nAz = sqrte(Constants.EPS_DIEL_AIR) ;
nmz = sqrte(eps_diel_z(2 : end, :)) ;
nSz = sqrte(eps_diel_z(end, :)) ;

% Air - % isotropic
na = [nAz; nAz; nAz] ;

% Dielectric Profile : isotropic
nm = [nmz(:, 1).'; nmz(:, 1).'; nmz(:, 1).'] ;

% Soil - isotropic
nb = [nSz(:, 1); nSz(:, 1); nSz(:, 1)] ;

%% input to multidiel
n = [na, nm, nb] ;

%% Reflection Coeffficient
rh = multidiel(n, Lz, 1, th0_Tx_deg, 'te') ;
rv = multidiel(n, Lz, 1, th0_Tx_deg, 'th') ;


%% Apply surface roughness
% Effective roughness parameters
h = GndDynParams.getInstance.h;

% cosine of the incidence angle
CTI = cos(th0_Tx_deg * pi/180) ;

% Surface roughness scalar term
QZSGMI2 = h * CTI ^ 2 / 2.0 ;

% Apply term
rh = rh * exp(-QZSGMI2) ;
rv = rv * exp(-QZSGMI2) ;

% determine penetration depth if requested
calculate_penetration_depth = ...
    GndMLParams.getInstance.calculate_penetration_depth;

if calculate_penetration_depth
    
    % Get index of penetration depth from entire profile
    pdh_in = pendep(rh, n, Lz, 1, th0_Tx_deg, 'te') ;
    pdv_in = pendep(rv, n, Lz, 1, th0_Tx_deg, 'th') ;

    % remove air layer and convert to meters
    zA_m = GndMLParams.getInstance.zA_m;    % Air layer
    z_m = GndMLParams.getInstance.z_m;    % Layer profile

    pdh = z_m(pdh_in) - zA_m ;
    pdv = z_m(pdv_in) - zA_m ;
    
else
    % assign null values if no calculation is used
    pdh = 0; pdv = 0;
end

end

