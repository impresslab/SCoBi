%% Mehmet Kurum
% 03/03/2017


function CalcRotMats3

%% global
global polT polR
global FolderPath_rot FolderPath_Config FolderPath_Ant

%% recall necessary parameters/vectors

% idn -  propagation vector (i_d^-)
% isn - propagation vector (i_s^-)
% isp - propagation vector (i_s^+)
% osp - propagation vector (o_s^+)
% osn - propagation vector (o_s^-)

filenamex = 'idn' ;
idn = read_var(FolderPath_Config, filenamex) ;
filenamex = 'isn' ;
isn = read_var(FolderPath_Config, filenamex) ;
filenamex = 'osp' ;
osp = read_var(FolderPath_Config, filenamex) ;
isp = osp ;

% transformations
filenamex = 'Tgs' ;
Tgs = read_var(FolderPath_Config, filenamex) ;
filenamex = 'Tgr' ;
Tgr = read_var(FolderPath_Config, filenamex) ;
filenamex = 'TgrI' ;
TgrI = read_var(FolderPath_Config, filenamex) ;
filenamex = 'Tgt' ;
Tgt = read_var(FolderPath_Config, filenamex) ;
filenamex = 'TgtI' ;
TgtI = read_var(FolderPath_Config, filenamex) ;

%% Gennting th and ph
pathname = strcat(FolderPath_Ant, '\', 'LOOK-UP') ;
load([pathname '\AntPat.mat'], 'th', 'ph')

%% polarization definitions
% antenna polarizations = Y, X, R, L
% ground polarizations = H (phi), V (theta)

%% Rotation Matrix (Transmitter to Receiver)
% u_t_r(i_d^-)

disp('Rotation Matrix (Transmitter to Receiver) . . .')
tic; 
pol1 = polT ; pol2 = polR ;
[ut1, ut2, ur1, ur2] = tanUnitVectors(Tgt, Tgr, idn, pol1, pol2) ;

% Polarization Basis Dot Products
u11 = dot(ut1, conj(ur1)) ; u12 = dot(ut2, conj(ur1)) ;
u21 = dot(ut1, conj(ur2)) ; u22 = dot(ut2, conj(ur2)) ;

% 2 X 2
u_tr = [u11, u12;...
    u21, u22] ;
% % % 4 X 4
% % U_tr = calc_Muller(u_tr) ;

toc
%% Rotation Matrix (Transmitter to Specular Point - Ground)
% u_t_s(i_s^-)

disp('Rotation Matrix (Transmitter to Specular) . . .')
tic ;
pol1 = polT ; pol2 = 'V' ;
[ut1, ut2, uvsi, uhsi] = tanUnitVectors(Tgt, Tgs, isn, pol1, pol2) ;

% Polarization Basis Dot Products
u11 = dot(ut1, conj(uvsi)) ; u12 = dot(ut2, conj(uvsi)) ;
u21 = dot(ut1, conj(uhsi)) ; u22 = dot(ut2, conj(uhsi)) ;

% 2 X 2
u_ts = [u11, u12;...
    u21, u22] ;
% % % 4 X 4
% % U_ts = calc_Muller(u_ts) ;

toc
%% Rotation Matrix (Image Transmitter to Specular Point - Ground)
% u_tI_s(i_s^+)

% % pol1 = polT ; pol2 = 'V' ;
% % [utI1, utI2, uvsi, uhsi] = tanUnitVectors(TgtI, Tgs, isp, pol1, pol2) ;
% % 
% % % Polarization Basis Dot Products
% % u_tIs = [dot(utI1, conj(uvsi)), dot(utI2, conj(uvsi));...
% %     dot(utI1, conj(uhsi)), dot(utI2, conj(uhsi))] ;

% 2 X 2
u_tIs = u_ts ; %% added april 29, 2017
% % % 4 X 4
% % U_tIs = U_ts ; %% added May 1, 2017
%% Rotation Matrix (Specular point - Ground to Receiver)
% u_p_r(o_s^+)

disp('Rotation Matrix (Specular to Receiver) . . .')
tic ;
pol1 = 'V' ; pol2 = polR ;
[uvso, uhso, ur1, ur2] = tanUnitVectors(Tgs, Tgr, osp, pol1, pol2) ;

% Polarization Basis Dot Products
u11 = dot(uvso, conj(ur1)) ; u12 = dot(uhso, conj(ur1)) ;
u21 = dot(uvso, conj(ur2)) ; u22 = dot(uhso, conj(ur2)) ;

% 2 X 2
u_sr = [u11, u12;...
    u21, u22] ;
% % % 4 X 4
% % U_sr = calc_Muller(u_sr) ;

toc

%% Calculate Rotation Matrices (Specular point - Ground to Image Receiver)
% u_p_rI(o_s^-)

% pol1 = 'V' ; pol2 = 'Y' ;
% [uvoI, uhoI, ur1, ur2] = tanUnitVectors(Tgs, TgrI, osn, pol1, pol2) ;
% 
% % Polarization Basis Dot Products
% usrI = [dot(uhoI, conj(ur1)), dot(uvoI, conj(ur1));...
%     dot(uhoI, conj(ur2)), dot(uvoI, conj(ur2))] ;


% % %% Calculate Rotation Matrices (Ground to Receiver)
% % % u_p_r(o_a^+)
% % 
% % disp('Rotation Matrix (Ground to Receiver) . . .')
% % tic;
% % [Nph, Nth] = size(th) ;
% % for t = 1 : Nth
% %     for p = 1 : Nph
% %         
% %         pol1 = 'V' ; pol2 = polR ;
% %         thpt = th(p, t) ; phpt = ph(p, t) ;
% %         oap_rf = -[sin(thpt) .* cos(phpt); sin(thpt) .* sin(phpt); cos(thpt)] ;
% %         oap = Tgr' * oap_rf ;   % in reference (ground) plane
% %         [uvo, uho, ur1, ur2] = tanUnitVectors(Tgs, Tgr, oap, pol1, pol2) ;
% %         
% %         % Polarization Basis Dot Products        
% %         u11 = dot(uvo, conj(ur1)) ; u12 = dot(uho, conj(ur1)) ;
% %         u21 = dot(uvo, conj(ur2)) ; u22 = dot(uho, conj(ur2)) ;
% %         
% %         % 2 X 2
% %         u_gar{p, t} = [u11, u12;...
% %             u21, u22] ;
% % % %         % 4 X 4      
% % % %         U_gar{p, t} = calc_Muller(u_gar{p, t}) ;
% % 
% %     end
% % end
% % toc
%% Calculate Rotation Matrices (Ground to Image Receiver)
% u_p_rI(o_a^-)

% % disp('Rotation Matrix (Ground to Image Receiver) . . .')
% % tic ;
% % [Nph, Nth] = size(th) ;
% % for t = 1 : Nth
% %     for p = 1 : Nph
% %        
% %         pol1 = 'V' ; pol2 = polR ;
% %         thpt = th(p, t) ; phpt = ph(p, t) ;
% %         oap_rIf = -[sin(thpt) .* cos(phpt); sin(thpt) .* sin(phpt); cos(thpt)] ;
% %         oaIp = TgrI' * oap_rIf ;  % in reference (ground) plane
% %         [uvoI, uhoI, ur1, ur2] = tanUnitVectors(Tgs, TgrI, oaIp, pol1, pol2) ;
% %         
% %         % Polarization Basis Dot Products
% %         u_garI{p, t} = [dot(uvoI, conj(ur1)), dot(uhoI, conj(ur1));...
% %             dot(uvoI, conj(ur2)), dot(uhoI, conj(ur2))] ;
% %         
% %     end
% % end
% % toc

% 2 X 2
% % u_garI = u_gar ; %% added april 29, 2017
% % % 4 X 4
% % U_garI = U_gar ; %% added May 1, 2017

%% Saving . . . 

disp('Saving Rotation Matrices . . .')
tic ;
pathname = strcat(FolderPath_rot, '\', 'LOOK-UP') ;

% 2 X 2
% % save([pathname '\u_gar.mat'], 'u_gar', 'th', 'ph')
% % save([pathname '\u_garI.mat'], 'u_garI', 'th', 'ph')
save([pathname '\u_sr.mat'], 'u_sr')
save([pathname '\u_ts.mat'], 'u_ts')
save([pathname '\u_tIs.mat'], 'u_tIs')
save([pathname '\u_tr.mat'], 'u_tr')
% % % 4 X 4
% % save([pathname '\U_gar.mat'], 'U_gar', 'th', 'ph')
% % save([pathname '\U_garI.mat'], 'U_garI', 'th', 'ph')
% % save([pathname '\U_sr.mat'], 'U_sr')
% % save([pathname '\U_ts.mat'], 'U_ts')
% % save([pathname '\U_tIs.mat'], 'U_tIs')
% % save([pathname '\U_tr.mat'], 'U_tr')

toc


end


%% Calculate unit vectors on the tangetial plane

function [u1p1, u1p2, u2p1, u2p2] = tanUnitVectors(Tg1, Tg2, k, pol1, pol2)

% k is a unit vector (given in reference frame) from Frame 1 to Frame 2
% ux1 = Tg1(1, :) ; uy1 = Tg1(2, :) ; uz1 = Tg1(3, :) ;
% ux2 = Tg2(1, :) ; uy2 = Tg2(2, :) ; uz2 = Tg2(3, :) ;

%% Angles to frames # 1 and # 2
k_1f = Tg1 * k ; % unit propagation vector in frame #1
k_2f = Tg2 * k ; % unit propagation vector in frame #2

% off-axis angle of z1 towards frame 2
th1 = acos(k_1f(3)) ;
% orientation - azimuth
ph1 = atan2(k_1f(2), k_1f(1)) ;

% off-axis angle of z2 towards frame 1
th2 = acos(-k_2f(3)) ;
% orientation - azimuth
ph2 = atan2(-k_2f(2), -k_2f(1)) ;

%% unit vectors in phi direction [HPOL]
AR = 0 ; AT = 0 ; AP = 1 ;
[ux1p, uy1p, uz1p] = sph2Car2(th1, ph1, AR, AT, AP) ;
[ux2p, uy2p, uz2p] = sph2Car2(th2, ph2, AR, AT, AP) ;

% phi vector of frame 1
u1ph = Tg1' * [ux1p; uy1p; uz1p] ;  % in reference frame
% phi vector of frame 2
u2ph = Tg2' * [ux2p; uy2p; uz2p] ;  % in reference frame

%% unit vectors in theta direction [VPOL]
AR = 0 ; AT = 1 ; AP = 0 ;
[ux1t, uy1t, uz1t] = sph2Car2(th1, ph1, AR, AT, AP) ;
[ux2t, uy2t, uz2t] = sph2Car2(th2, ph2, AR, AT, AP) ;

% theta vector of frame 1
u1th = Tg1' * [ux1t; uy1t; uz1t] ;  % in reference frame
% theta vector of frame 2
u2th = Tg2' * [ux2t; uy2t; uz2t] ;  % in reference frame


%% unit vectors in Ludwig basis (reference: YPOL)
AR = 0 ; AT = sin(ph1) ; AP = cos(ph1) ;
[ux1Y, uy1Y, uz1Y] = sph2Car2(th1, ph1, AR, AT, AP) ;
AR = 0 ; AT = sin(ph2) ; AP = cos(ph2) ;
[ux2Y, uy2Y, uz2Y] = sph2Car2(th2, ph2, AR, AT, AP) ;

% reference vector (Y-axis) of frame 1
u1Y = Tg1' * [ux1Y; uy1Y; uz1Y] ;  % in reference frame
% reference vector (Y-axis) of frame 2
u2Y = Tg2' * [ux2Y; uy2Y; uz2Y] ;  % in reference frame

%% unit vectors in Ludwig basis (cross: XPOL)
AR = 0 ; AT = cos(ph1) ; AP = -sin(ph1) ;
[ux1X, uy1X, uz1X] = sph2Car2(th1, ph1, AR, AT, AP) ;
AR = 0 ; AT = cos(ph2) ; AP = -sin(ph2) ;
[ux2X, uy2X, uz2X] = sph2Car2(th2, ph2, AR, AT, AP) ;

% cross vector (X-axis) of frame 1
u1X = Tg1' * [ux1X; uy1X; uz1X] ;  % in reference frame
% cross vector (X-axis) of frame 2
u2X = Tg2' * [ux2X; uy2X; uz2X] ;  % in reference frame

%% unit vectors in circular polarization (RPOL and LPOL)

% frame 1
u1R = 1/ sqrt(2) * (u1X - 1i * u1Y) ;   % port 1    RHCP
u1L = 1/ sqrt(2) * (u1X + 1i * u1Y) ;   % port 2    LHCP

% frame 2
u2R = 1/ sqrt(2) * (u2X - 1i * u2Y) ;   % port 1    RHCP
u2L = 1/ sqrt(2) * (u2X + 1i * u2Y) ;   % port 2    LHCP

% sum(u2R .* conj(u2L))

if pol1 == 'H'
    u1p1 = u1ph ;
    u1p2 = u1th ;
elseif pol1 == 'V'
    u1p1 = u1th ;
    u1p2 = u1ph ;
elseif pol1 == 'X'
    u1p1 = u1X ;
    u1p2 = u1Y ;
elseif pol1 == 'Y'
    u1p1 = u1Y ;
    u1p2 = u1X ;
elseif pol1 == 'R'
    u1p1 = u1R ;
    u1p2 = u1L ;
elseif pol1 == 'L'
    u1p1 = u1L ;
    u1p2 = u1R ;
end

if pol2 == 'H'
    u2p1 = u2ph ;
    u2p2 = u2th ;
elseif pol2 == 'V'
    u2p1 = u2th ;
    u2p2 = u2ph ;
elseif pol2 == 'X'
    u2p1 = u2X ;
    u2p2 = u2Y ;
elseif pol2 == 'Y'
    u2p1 = u2Y ;
    u2p2 = u2X ;
elseif pol2 == 'R' 
    u2p1 = u2R ;
    u2p2 = u2L ;
elseif pol2 == 'L'
    u2p1 = u2L ;
    u2p2 = u2R ;
end

% % elseif pol2 == 'R' % Circular pol rotation has swaped to match trasnmit and receive directions
% %     u2p1 = u2L ;
% %     u2p2 = u2R ;
% % elseif pol2 == 'L'
% %     u2p1 = u2R ;
% %     u2p2 = u2L ;
% % end

end


%% from Spherical to Cartesian coordinate system

function [AX, AY, AZ] = sph2Car2(theta, phi, AR, AT, AP)

st = sin(theta) ;
ct = cos(theta) ;
cp = cos(phi) ;
sp = sin(phi) ;

AX = AR .* st .* cp + AT .* ct .* cp - AP .* sp ;
AY = AR .* st .* sp + AT .* ct .* sp + AP .* cp ;
AZ = AR .* ct - AT .* st ;

end