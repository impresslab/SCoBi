function var = readVar(pathname, filename)
% function readVar 
%
%   Reads number values from a given filename. In fact, the given 
%   filename is combined with "_r" and "_i" extensions for real and
%   imaginary part files for a complex number.
%
%   var = readVar(pathname, filename)
%
%   INPUTS:
%   pathname: The folder path
%   filename: The filename that includes the number values.
%   
%   File Structure to be read: Files that will be read by this function are 
%   generally generated by writeVar function. The first line of the file 
%   should have the number of dimensinons, following lines (enugh number of
%   them depending on the number of dimensions) should have the length of 
%   each dimension, then the following lines should have the values 
%   corresponding to the given size.
%   For example:
%   
%   example.dat
%   2.0
%   3.0
%   5.0
%    9   5 6 0  4
%   -33  8 0 4 -3
%   -4  -8 7 0  4

%   Copyright � 2017-2018 Mehmet Kurum, Orhan Eroglu, Dylan R. Boyd

%   This program is free software: You can redistribute it and/or 
%   modify it under the terms of the GNU General Public License as 
%   published by the Free Software Foundation, either version 3 of the 
%   License, or (at your option) any later version.

%   Version: 1.0.0


% Check if folder does nt contain any .dat dile
folderNotEmpty = any(size(dir([strcat( pathname ) '/*.dat' ] ), 1 ));

% If folder contains some .dat files
if folderNotEmpty
    
    % Try to read the given filename
    if exist( [strcat(pathname, '\') strcat(filename, '.dat')], 'file' )
        
        filename = strcat( pathname, '\', filename, '.dat' );
        
    else
        
        var = NaN;
        
        return
    
    end

    % Open the file for reading
    fid = fopen(filename,'r') ;

    % First, read the number of dimensions of the values array in the first 
    % line
    NofDims = str2num(fgetl(fid)) ;
    
    SizeVar = zeros(1, NofDims) ;

    % Read the next number-of-dimensions lines to read the length o each 
    % dimension 
    for ii = 1 : NofDims

        SizeVar(ii) = str2num(fgetl(fid)) ;

    end
    
    var = zeros(SizeVar) ;

    N = SizeVar(1) ;

    % Read the values corresponding to the dimensions 
    for n = 1 : N

        var(n, :) = str2num(fgetl(fid)); 

    end

    % Close the file
    fclose(fid);
    
else
    
    var = NaN;
    
end


end