function [L,modes,varargout] = pod(data,options)
% POD(DATA,OPTIONS)
% DATA = a 4D matrix of rows x cols x N x nComponents (N = number of
% snapshots), nComponents = number of the vector dimensions (1 = scalar);
%
% OPTIONS - structure which contains the following (optional) fields:
%   options.mean_method = 'mean' or 'none' ('m' or 'n')
%   options.method = 'direct' or 'snapshots' ('d' or 's')
%   options.numofmodes = 'all' or integer smaller than size(data,3)
%   options.output = 'modes','reconstruct','multimode'
%
%   if options.output = 'reconstruct' or 'multimode'
%   then: options.numofsnapshot = number in the interval [1,N]
%   and:  options.selectedmodes = list of modes to use, e.g. [1,3,5] or
%   'all'
%
%
% Example:
%   options = struct();
%   options.mean_method = 'mean';
%   options.method = 'snapshot';
%   options.numofmodes = 10;
%   options.output = 'reconstruct';
%   options.numofsnapshot = 8;
%   options.selectedmodes = [1,2,3];
%   load tmp.mat
%   [l,modes,rec8] = podscalar(flipdim(u,1),options);
%   figure, plot(cumsum(l)./sum(l)*100); ylabel('Cummulative energy, per-cent');
%   figure, imagesc(modes(:,:,1)); title('Mode 1');
%   figure, imagesc([rec8,flipud(u(:,:,8))]); axis equal

[r,c,N,k] = size(data); %4D data
len = r*c;
Uf = zeros(len*k,N);         % r*c*3 length of the vector

for j = 1:k
    for i = 1:N
        Uf((j-1)*len+1:j*len,i) = reshape(data(:,:,i,j),len,1);
    end
end


switch options.mean_method
    case{'mean','m'}
        meanU = mean(Uf,2);
        for i = 1:N
            Uf(:,i) = Uf(:,i) - meanU;
        end
end


switch options.method % additional switch, to distinguish between
    % direct and snapshots methods, Alex, 08.07.05
    case {'s','snapshot'}
        R = Uf'*Uf;
    case {'d','direct'}
        %       Covariance matrix:
        R = Uf*Uf';
end

[V,D] = eig(R);
clear R
[L,I] = sort(diag(D)/N);

nL = length(L);
L = L(nL:-1:1);
I = I(nL:-1:1);


if ischar(options.numofmodes) && strcmp(options.numofmodes,'all')
    m = N;
else
    m = options.numofmodes;
end


switch options.method
    case {'s', 'snapshot'}
        % Diagonal matrix containing the square roots of the eigenvalues:
        S = sqrt(diag(D));
        S = S(I);
        V = V(:,I);
        a = diag(S(1:m))*(V(:,1:m)');
        phi = Uf*V(:,1:m)*diag(1./S(1:m));

    case {'d','direct'}
        phi = V(:,I);
        S = sqrt(diag(D));
        a = (Uf'*phi(:,1:m)).';
        phi = phi(:,1:m);
end
modes = zeros(r,c,m,k);
for j = 1:k
    for i=1:m
        modes(:,:,i,j) = reshape(phi((j-1)*len+1:j*len,i),[r c] );
    end
end

switch options.output
    case{'reconstruct'}
        n = options.numofsnapshot;
        t = options.selectedmodes;
        if ischar(options.selectedmodes) && strcmp(options.selectedmodes,'all')
            t = 1:size(phi,2);
        else
            t = options.selectedmodes;
        end
        Q = phi(:,t)*a(t,n) + meanU;

        for j = 1:k
            varargout{j} = reshape(Q((j-1)*len+1:len*j),r,c);		   % u-components of reconstructed velocity field
        end

    case{'multimode'} % multi-mode, weighted reconstruction

        n = options.numofsnapshot;

        for j = 1:k
            uRec = modes(:,:,options.selectedmodes(1),j) * L(options.selectedmodes(1));
            for i = 1:length(options.selectedmodes)
                uRec = uRec + modes(:,:,options.selectedmodes(i),j) * L(options.selectedmodes(i));
            end
            varargout{j} = uRec;
        end
end


