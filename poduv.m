function [varargout] = poduv(handles,step,varargin)
% PODUV is the Proper Orthogonal Decomposition of U,V velocity fields
% 

% Copyright (c) 2003 Alex Liberzon and Roi Gurka
persistent r c N len U meanU Uf V D L I a phi

% dbstop if caught error MATLAB:nonExistentField

switch step
    case{1} % first time we call the function

        [r,c,N] = size(handles.u);	% 4-D is the number of files

        len = r*c;

        U = zeros(len*2,N);         % r*c*3 length of the vector

        % small rearrangement
        for i = 1:N
            U(1:len,i) = reshape(handles.u(:,:,i),len,1);
            U(len+1:2*len,i) = reshape(handles.v(:,:,i),len,1);
        end

        % Ensemble average of U:
        meanU = mean(U,2);
        % meanU = zeros(len,1);
        % Fluctuations
        %        % Uf = U - repmat(meanU,1,N);
        for i = 1:N
            Uf(:,i) = U(:,i) - meanU;
        end


        %         keyboard
        switch handles.METHOD_FLAG % additional switch, to distinguish between
            % direct and snapshots methods, Alex, 08.07.05
            case {0,'snapshot'}
                R = Uf'*Uf;
            case {1,'direct'}
    %       Covariance matrix:
                R = Uf*Uf';
        end
        % Eigenvalue problem:
%        [~,D,V] = svds(R,min(len*2,N));
       [V,D] = eig(R);
       clear R
       [L,I] = sort(diag(D)/N);

        nL = length(L);
        L = L(nL:-1:1);
        I = I(nL:-1:1);

        varargout{1} = L;


    case{2}
        % second call, the number of modes is known or the amount of energy
        % and POD prepares modes
        m = handles.numOfModes;
        switch handles.METHOD_FLAG
            case {0, 'snapshot'}
                % Diagonal matrix containing the square roots of the eigenvalues:

                S = sqrt(diag(D));
                % [S, I] = sort(S);
                % S = flipud(S);
                % I = flipud(I);
                S = S(I);
                V = V(:,I);



                a = diag(S(1:m))*(V(:,1:m)');


                % Calculation of POD modes:

                % for i=1:m
                %   y = Uf*V(:,i);
                %   phi(:,i) = y/norm(y);
                % end;

                %        phi = Uf*V(:,1:m);
                %        phi = phi./repmat(sum(abs(phi).^2).^(1/2),len*2,1);

                phi = Uf*V(:,1:m)*diag(1./S(1:m));

            case {1,'direct'}
                phi = V(:,I);
                 S = sqrt(diag(D));
%                 S = S(I);
%                 a = diag(S(1:m))*(phi(:,1:m)');
                %  a = diag(L(1:m))*(V(:,1:m)');
                a = (Uf'*phi(:,1:m)).';
                phi = phi(:,1:m);
%                  disp('direct')
%                  whos
        end

        [umodes,vmodes,wmodes,vel] = deal(zeros(r,c,m));
        for i=1:m
            umodes(:,:,i) = reshape(phi(1:len,i),[r c] );
            vmodes(:,:,i) = reshape(phi(len+1:2*len,i),[r c]);
        end

        vel = (umodes.^2 + vmodes.^2).^(0.5); % .+wmodes.^2);             % Velocity vector magnitude

        % misterious -1
        varargout{1} = umodes;
        varargout{2} = vmodes;
        %                 varargout{1} = -1*umodes;
        %         varargout{2} = -1*vmodes;

    case{3} % reconstruction

        n = handles.current;
        if isfield(handles,'SelectedModes') & ~isempty(handles.SelectedModes)
            t = handles.SelectedModes;
        else
            t = 1:size(phi,2);
        end
        Q = phi(:,t)*a(t,n) + meanU;
        varargout{1} = reshape(Q(1:r*c),r,c);		   % u-components of reconstructed velocity field
        varargout{2} = reshape(Q(r*c+1:2*r*c),r,c);	   % v-components of reconstructed velocity field

    case{4} % multi-mode, weighted reconstruction
        
        n = handles.current;
        
        uRec = handles.umodes(:,:,handles.multimode(1)) * L(handles.multimode(1));
        vRec = handles.vmodes(:,:,handles.multimode(1)) * L(handles.multimode(1));
%                 uRec = handles.umodes(:,:,handles.multimode(1)) * L(handles.multimode(1));
%         vRec = handles.vmodes(:,:,handles.multimode(1)) * L(handles.multimode(1));
        
        for i = 1:length(handles.multimode) % (1) + 1 : handles.multimode(end)
            uRec = uRec + handles.umodes(:,:,handles.multimode(i)) * L(handles.multimode(i));
            vRec = vRec + handles.vmodes(:,:,handles.multimode(i)) * L(handles.multimode(i));
        end            
        
        varargout{1} = uRec;
        varargout{2} = vRec;
%         % r c N len U meanU Uf V L I a phi
%         varargout{1} = U;
%         varargout{2} = meanU;
%         varargout{3} = Uf;
%         varargout{4} = V;
%         varargout{5} = L;
%         varargout{6} = I;
%         varargout{7} = a;
%         varargout{8} = phi;
% 
%         clear r c N len U meanU Uf V L I a phi

    case{6} % first time we call the function, but different from case 1 it is
        % without subtracting the mean of the velocity fields.

        [r,c,N] = size(handles.u);	% 4-D is the number of files

        len = r*c;

        U = zeros(len*2,N);     % r*c*3 length of the vector

        % small rearrangement
        for i = 1:N
            U(1:len,i) = reshape(handles.u(:,:,i),len,1);
            U(len+1:2*len,i) = reshape(handles.v(:,:,i),len,1);
        end

        % Ensemble average of U:
        %         meanU = mean(U,2);
        meanU = zeros(len,1);

        % Fluctuations
        % Uf = U - repmat(meanU,1,N);
        for i = 1:N
            Uf(:,i) = U(:,i) - meanU;
        end

        % Covariance matrix:
        R = Uf'*Uf;

        % Eigenvalue problem:
        [V,D] = eig(R);

        clear R


        [L,I]=sort(diag(D));
        nL = length(L);
        L = L(nL:-1:1);
        I = I(nL:-1:1);

        varargout{1} = L;
        varargout{2} = a;

end % of switch