function [varargout] = vecread(varargin)
%VECREAD Reads *.VEC files produced by Insight 3.3 software
% [HEADER,DATA] = VECREAD(FILENAME,HEADLINE,COLUMNS) will read the 
% FILENAME file (with or without .vec extension), with HEADLINE, number 
% of header lines, usually 1, and COLUMNS, number of columns in the file,
% usually 5. HEADER is a string and DATA is a 3D matrix as described below.
%   
% [DATA] = VECREAD(FILENAME) Reads the FILENAME.VEC to the DATA 3D matrix 
% as described below, and default values for HEADLINE = 1, COLUMNS = 5 
% (Usual 2D .vec file) are used.
%
% DATA(:,:,1)=X, DATA(:,:,2)=Y, DATA(:,:,3)=U, DATA(:,:,4)=V, DATA(:,;,5)=CHC. 
% (See Insight manual for more info)
%
%   example:
%    [h,d] = vecread('tmp.vec',1,5);
%    quivervec(d);
%    title(h);
%
%   See also READEXPDIR QUIVERVEC
%

% Created: 21-May-2001
% Author: Alex Liberzon 
% E-Mail : liberzon@tx.technion.ac.il 
% Phone : +972 (0)48 29 3861 
% Copyright (c) 2001 Technion - Israel Institute of Technology 
%
% Modified at: 21-May-2001
% $Revision: 1.0 $  $Date: 21-May-2001 09:36:48$ 
%
% $Revision: 2.0 $  $Date: 21-May-2001 21:08:48$ 
% - change the reshaping
% - change the inputs check
% $Revision: 2.1 $  $Date: 27-May-2001 22:46:48$ 
% - minor changes of the HELP section
% $Revision: 3.0 $  $Date: 28-May-2001 22:43:00$ 
% - 'Bad data' points are replaced by NaNs (>9.99e9);
% $Revision: 3.1 $  $Date: 17-Jun-2001 21:49:00$ 
% - 'Bad data' points are replaced by 0 (zeros) (>9.99e9);
% NaNs are not compatible with the following POD analysis
% Modified at: June 03, 2004 by Alex Liberzon
% - updated version can read multi-column VEC files, automatically
% scanning the header for the number of variables.
% usual VEC and V3D files work fine, unusual V3D are not checked



% Inputs:
msg = nargchk(1,3,nargin); if ~isempty(msg), error(msg), end;
% Defaults:
if nargin < 3
   varargin{3} = 5;		% default columns value   
   if nargin < 2
      varargin{2} = 1;	% default number of header lins
   end
end

% Assign variables
name = varargin{1};   
comments = varargin{2};
columns = varargin{3};

% Extension issue
if isempty(findstr(name,'.vec')), name = strcat(name,'.vec'); end;

% Read the file
fid=fopen(name,'r');

if fid<0
   errordlg('File not found');
end
[dch,count]=fread(fid,inf,'uchar');
fclose(fid);

% Reformat the data
chdat=[dch(:)',char(13)];

ind10=find(chdat==char(10));
chdat(ind10) = repmat(char(13),[length(ind10),1]);
% chdat(ind10) = repmat(char(' '),[length(ind10),1]);

% comp=computer;
% if strcmp(comp(1:3),'PCW')|strcmp(comp(1:3),'VAX')|strcmp(comp(1:3),'ALP'),
%    % replace cr-lf with cr only for PC's, VAXen and Alphas
%    chdat(ind10)=char(' '*ones(1,length(ind10)));
% else
%    %replace line-feeds with carriage-returns for Unix boxes
%    chdat(ind10)=char(13*ones(length(ind10),1));
% end

% Now replace commas with spaces
indcom=find(chdat==',');
chdat(indcom)=repmat(char(' '),[length(indcom),1]);

%find carriage-returns
ind13=find(chdat==char(13));

% Truncate array to just have data
if comments==0,
   char1=1;
else
   char1=ind13(comments)+1;
end
hdr = lower(chdat(1:char1-1));
chdata=chdat(char1:count);

% Update of the vecread towards Insight 7 with plugins and new variables
% multiple-columns, June 03, 2004.
% Alex, 22.02.08 - some change in VEC files - the space after variables=
% disappeared, new columns appeared, e.g. datasetauxdata ...
% variables = hdr(findstr(hdr,'variables=')+length('variables='):findstr(hdr,'zone')-1);
variables = hdr(findstr(hdr,'variables=')+length('variables='):findstr(hdr,'chc')+4); % '"chc"
columns = length(findstr(variables,'"'))/2;
ind = findstr(variables,'"');
xUnits = variables(ind(1)+2:ind(2)-1);
uUnits = variables(ind(5)+2:ind(6)-1);
data=sscanf(chdata,'%g',[columns inf])';

% Find and remove bad points > 9.99e9
data(data>9e9) = 0;

% Parse the header

i = findstr(hdr,'i=');
j = findstr(hdr,'j=');
[i,~] = strtok(hdr(i+2:end));
[j,~] = strtok(hdr(j+2:end));

i = eval(i); j = eval(j);

data = reshape(data,[i,j,columns]);
data = permute(data,[2 1 3]);

if nargout == 1
   varargout{1} = data;
elseif nargout == 2
   varargout{1} = hdr;
   varargout{2} = data;
elseif nargout == 3
    varargout{1} = xUnits;
    varargout{2} = uUnits;
    varargout{3} = data;
elseif nargout == 4
   varargout{1} = hdr;
   varargout{2} = data;
   varargout{3} = str2num(i);
   varargout{4} = str2num(j);
else
   warning('Wrong number of outputs') ;
end
