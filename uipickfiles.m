function out = uipickfiles(varargin)
%uipickfiles: GUI program to select files and/or directories.
%
% Syntax:
%   files = uipickfiles('PropertyName',PropertyValue,...)
%
% The current directory can be changed by operating in the file navigator:
% double-clicking on a directory in the list or pressing Enter to move
% further down the tree, using the popup menu, clicking the up arrow button
% or pressing Backspace to move up the tree, typing a path in the box to
% move to any directory or right-clicking (control-click on Mac) on the
% path box to revisit a previously-listed directory.  (Windows only: To go
% to a UNC-named resource you will have to type the UNC name in the path
% box, but all such visited resources will be remembered and listed along
% with the mapped drives.)
%
% Files can be added to the list by double-clicking or selecting files
% (non-contiguous selections are possible with the control key) and
% pressing the Add button.  Since double-clicking a folder will open it,
% folders can be added only by selecting them and pressing the Add button.
% Files/folders in the list can be removed or re-ordered.  When finished, a
% press of the Done button will return the full paths to the selected files
% in a cell array, structure array or character array.  If the Cancel
% button is pressed then zero is returned.
%
% The following optional property/value pairs can be specified as arguments
% to control the indicated behavior:
%
%   Property    Value
%   ----------  ----------------------------------------------------------
%   FilterSpec  String to specify starting directory and/or file filter.
%               Ex:  'C:\bin' will start up in that directory.  '*.txt'
%               will list only files ending in '.txt'.  'c:\bin\*.txt' will
%               do both.  Default is to start up in the current directory
%               and list all files.  Can be changed with the GUI.
%
%   REFilter    String containing a regular expression used to filter the
%               file list.  Ex: '\.m$|\.mat$' will list files ending in
%               '.m' and '.mat'.  Default is empty string.  Can be used
%               with FilterSpec and both filters are applied.  Can be
%               changed with the GUI.
%
%   REDirs      Logical flag indicating whether to apply the regular
%               expression filter to directory names.  Default is false
%               which means that all directories are listed.  Can be
%               changed with the GUI.
%
%   Type        Two-column cell array where the first column contains file
%               filters and the second column contains descriptions.  If
%               this property is specified an additional popup menu will
%               appear below the File Filter and selecting an item will put
%               that item into the File Filter.  By default, the first item
%               will be entered into the File Filter.  For example,
%                   { '*.m',   'M-files'   ;
%                     '*.mat', 'MAT-files' }.
%               Can also be a cell vector of file filter strings in which
%               case the descriptions will be the same as the file filters
%               themselves.
%               Must be a cell array even if there is only one entry.
%
%   Prompt      String containing a prompt appearing in the title bar of
%               the figure.  Default is 'Select files'.
%
%   NumFiles    Scalar or vector specifying number of files that must be
%               selected. A scalar specifies an exact value; a two-element
%               vector can be used to specify a range, [min max].  The
%               function will not return unless the specified number of
%               files have been chosen.  Default is [] which accepts any
%               number of files.
%
%   Output      String specifying the data type of the output: 'cell',
%               'struct' or 'char'.  Specifying 'cell' produces a cell
%               array of strings, the strings containing the full paths of
%               the chosen files.  'Struct' returns a structure array like
%               the result of the dir function except that the 'name' field
%               contains a full path instead of just the file name.  'Char'
%               returns a character array of the full paths.  This is most
%               useful when you have just one file and want it in a string
%               instead of a cell array containing just one string.  The
%               default is 'cell'.
%
% All properties and values are case-insensitive and need only be
% unambiguous.  For example,
%
%   files = uipickfiles('num',1,'out','ch')
%
% is valid usage.

% Version: 1.7, 8 August 2010
% Author:  Douglas M. Schwarz
% Email:   dmschwarz=ieee*org, dmschwarz=urgrad*rochester*edu
% Real_email = regexprep(Email,{'=','*'},{'@','.'})


% Define properties and set default values.
prop.filterspec = '*';
prop.refilter = '';
prop.redirs = false;
prop.type = {};
prop.prompt = 'Select files';
prop.numfiles = [];
prop.output = 'cell';

% Process inputs and set prop fields.
properties = fieldnames(prop);
arg_index = 1;
while arg_index <= nargin
	arg = varargin{arg_index};
	if ischar(arg)
		prop_index = find(strncmpi(arg,properties,length(arg)));
		if length(prop_index) == 1
			prop.(properties{prop_index}) = varargin{arg_index + 1};
		else
			error('Property ''%s'' does not exist or is ambiguous.',arg)
		end
		arg_index = arg_index + 2;
	elseif isstruct(arg)
		arg_fn = fieldnames(arg);
		for ii = 1:length(arg_fn)
			prop_index = find(strncmpi(arg_fn{ii},properties,...
				length(arg_fn{ii})));
			if length(prop_index) == 1
				prop.(properties{prop_index}) = arg.(arg_fn{ii});
			else
				error('Property ''%s'' does not exist or is ambiguous.',...
					arg_fn{ii})
			end
		end
		arg_index = arg_index + 1;
	else
		error(['Properties must be specified by property/value pairs',...
			' or structures.'])
	end
end

% Validate FilterSpec property.
if isempty(prop.filterspec)
	prop.filterspec = '*';
end
if ~ischar(prop.filterspec)
	error('FilterSpec property must contain a string.')
end

% Validate REFilter property.
if ~ischar(prop.refilter)
	error('REFilter property must contain a string.')
end

% Validate REDirs property.
if ~isscalar(prop.redirs)
	error('REDirs property must contain a scalar.')
end

% Validate Type property.
if isempty(prop.type)
elseif iscellstr(prop.type) && isvector(prop.type)
	prop.type = repmat(prop.type(:),1,2);
elseif iscellstr(prop.type) && size(prop.type,2) == 2
else
	error(['Type property must be empty or a cellstr vector or ',...
		'a 2-column cellstr matrix.'])
end

% Validate Prompt property.
if ~ischar(prop.prompt)
	error('Prompt property must contain a string.')
end

% Validate NumFiles property.
if numel(prop.numfiles) > 2 || any(prop.numfiles < 0)
	error('NumFiles must be empty, a scalar or two-element vector.')
end
prop.numfiles = unique(prop.numfiles);
if isequal(prop.numfiles,1)
	numstr = 'Select exactly 1 file.';
elseif length(prop.numfiles) == 1
	numstr = sprintf('Select exactly %d files.',prop.numfiles);
else
	numstr = sprintf('Select %d to %d files.',prop.numfiles);
end

% Validate Output property.
legal_outputs = {'cell','struct','char'};
out_idx = find(strncmpi(prop.output,legal_outputs,length(prop.output)));
if length(out_idx) == 1
	prop.output = legal_outputs{out_idx};
else
	error(['Value of ''Output'' property, ''%s'', is illegal or '...
		'ambiguous.'],prop.output)
end


% Set style preference for display of folders/directories.
%   1 => folder icon before and filesep after
%   2 => bullet before and filesep after
%   3 => filesep after only
folder_style_pref = 1;
fsdata = set_folder_style(folder_style_pref);

% Initialize file lists.
[current_dir,f,e] = fileparts(prop.filterspec);
filter = [f,e];
if isempty(current_dir)
	current_dir = pwd;
end
if isempty(filter)
	filter = '*';
end
re_filter = prop.refilter;
full_filter = fullfile(current_dir,filter);
network_volumes = {};
[path_cell,new_network_vol] = path2cell(current_dir);
if exist(new_network_vol,'dir')
	network_volumes = unique([network_volumes,{new_network_vol}]);
end
fdir = filtered_dir(full_filter,re_filter,prop.redirs);
filenames = {fdir.name}';
filenames = annotate_file_names(filenames,fdir,fsdata);

% Initialize some data.
file_picks = {};
full_file_picks = {};
dir_picks = dir(' ');  % Create empty directory structure.
show_full_path = false;
nodupes = true;
history = {current_dir};

% Create figure.
gray = get(0,'DefaultUIControlBackgroundColor');
fig = figure('Position',[0 0 740 445+34],...
	'Color',gray,...
	'WindowStyle','modal',...
	'Resize','off',...
	'NumberTitle','off',...
	'Name',prop.prompt,...
	'IntegerHandle','off',...
	'CloseRequestFcn',@cancel,...
	'CreateFcn',{@movegui,'center'});

% Set font on Mac and Windows to system font.
if ismac
	set(fig,'DefaultUIControlFontName','Lucida Grande')
	set(fig,'DefaultUIControlFontSize',9)
elseif ispc
	set(fig,'DefaultUIControlFontName','Tahoma')
	set(fig,'DefaultUIControlFontSize',8)
end

% Create uicontrols.
uicontrol('Style','frame',...
	'Position',[255 260 110 70])
uicontrol('Style','frame',...
	'Position',[275 135 110 100])

navlist = uicontrol('Style','listbox',...
	'Position',[10 10 250 320],...
	'String',filenames,...
	'Value',[],...
	'BackgroundColor','w',...
	'Callback',@clicknav,...
	'KeyPressFcn',@keypressnav,...
	'Max',2);
pickslist = uicontrol('Style','listbox',...
	'Position',[380 10 350 320],...
	'String',{},...
	'BackgroundColor','w',...
	'Callback',@clickpicks,...
	'Max',2);

openbut = uicontrol('Style','pushbutton',...
	'Position',[270 300 80 20],...
	'String','Open',...
	'Enable','off',...
	'Callback',@open);

arrow = [ ...
	'        1   ';
	'        10  ';
	'         10 ';
	'000000000000';
	'         10 ';
	'        10  ';
	'        1   '];
cmap = NaN(128,3);
cmap(double('10'),:) = [0.5 0.5 0.5;0 0 0];
arrow_im = NaN(7,76,3);
arrow_im(:,45:56,:) = ind2rgb(double(arrow),cmap);
addbut = uicontrol('Style','pushbutton',...
	'Position',[270 270 80 20],...
	'String','Add    ',...
	'Enable','off',...
	'CData',arrow_im,...
	'Callback',@add);

removebut = uicontrol('Style','pushbutton',...
	'Position',[290 205 80 20],...
	'String','Remove',...
	'Enable','off',...
	'Callback',@remove);
moveupbut = uicontrol('Style','pushbutton',...
	'Position',[290 175 80 20],...
	'String','Move Up',...
	'Enable','off',...
	'Callback',@moveup);
movedownbut = uicontrol('Style','pushbutton',...
	'Position',[290 145 80 20],...
	'String','Move Down',...
	'Enable','off',...
	'Callback',@movedown);

dir_popup = uicontrol('Style','popupmenu',...
	'Position',[10 335 225 20],...
	'BackgroundColor','w',...
	'String',path_cell,...
	'Value',length(path_cell),...
	'Callback',@dirpopup);

uparrow = [ ...
	'  0     ';
	' 000    ';
	'00000   ';
	'  0     ';
	'  0     ';
	'  0     ';
	'  000000'];
cmap = NaN(128,3);
cmap(double('0'),:) = [0 0 0];
uparrow_im = ind2rgb(double(uparrow),cmap);
up_dir_but = uicontrol('Style','pushbutton',...
	'Position',[240 335 20 20],...
	'CData',uparrow_im,...
	'Callback',@dir_up_one);
if length(path_cell) > 1
	set(up_dir_but','Enable','on')
else
	set(up_dir_but','Enable','off')
end

hist_cm = uicontextmenu;
pathbox = uicontrol('Position',[10 360 250 26],...
	'Style','edit',...
	'BackgroundColor','w',...
	'String',current_dir,...
	'HorizontalAlignment','left',...
	'Callback',@change_path,...
	'UIContextMenu',hist_cm);
uicontrol('Position',[10 386 250 16],...
	'Style','text',...
	'String','Current Directory',...
	'HorizontalAlignment','center',...
	'UIContextMenu',hist_cm)
hist_menus = [];
hist_cb = @history_cb;
hist_menus = make_history_cm(hist_cb,hist_cm,hist_menus,history);

uicontrol('Position',[10 425+36 80 17],...
	'Style','text',...
	'String','File Filter',...
	'HorizontalAlignment','left')
uicontrol('Position',[100 425+36 160 17],...
	'Style','text',...
	'String','Reg. Exp. Filter',...
	'HorizontalAlignment','left')
showallfiles = uicontrol('Position',[270 405+32 100 20],...
	'Style','checkbox',...
	'String','Show All Files',...
	'Value',0,...
	'HorizontalAlignment','left',...
	'Callback',@togglefilter);
refilterdirs = uicontrol('Position',[270 405+10 100 20],...
	'Style','checkbox',...
	'String','RE Filter Dirs',...
	'Value',prop.redirs,...
	'HorizontalAlignment','left',...
	'Callback',@toggle_refiltdirs);
filter_ed = uicontrol('Position',[10 405+30 80 26],...
	'Style','edit',...
	'BackgroundColor','w',...
	'String',filter,...
	'HorizontalAlignment','left',...
	'Callback',@setfilspec);
refilter_ed = uicontrol('Position',[100 405+30 160 26],...
	'Style','edit',...
	'BackgroundColor','w',...
	'String',re_filter,...
	'HorizontalAlignment','left',...
	'Callback',@setrefilter);

if ~isempty(prop.type)
	type_value = 1;
	set(filter_ed,'String',prop.type{type_value,1})
	setfilspec()
	type_popup = uicontrol('Position',[10 407 250 20],...
		'Style','popupmenu',...
		'String',prop.type(:,2),...
		'BackgroundColor','w',...
		'Value',type_value,...
		'Callback',@filter_type_callback);
end

viewfullpath = uicontrol('Style','checkbox',...
	'Position',[380 335 230 20],...
	'String','Show full paths',...
	'Value',show_full_path,...
	'HorizontalAlignment','left',...
	'Callback',@showfullpath);
remove_dupes = uicontrol('Style','checkbox',...
	'Position',[380 360 280 20],...
	'String','Remove duplicates (as per full path)',...
	'Value',nodupes,...
	'HorizontalAlignment','left',...
	'Callback',@removedupes);
uicontrol('Position',[380 405 350 20],...
	'Style','text',...
	'String','Selected Files',...
	'HorizontalAlignment','center')
uicontrol('Position',[280 80 80 30],'String','Done',...
	'Callback',@done);
uicontrol('Position',[280 30 80 30],'String','Cancel',...
	'Callback',@cancel);

% If necessary, add warning about number of files to be selected.
if ~isempty(prop.numfiles)
	uicontrol('Position',[380 385 350 16],...
		'Style','text',...
		'String',numstr,...
		'ForegroundColor',[0.8 0 0],...
		'HorizontalAlignment','center')
end

set(fig,'HandleVisibility','off')

% Wait until figure is closed.
uiwait(fig)

% Compute desired output.
switch prop.output
	case 'cell'
		out = full_file_picks;
	case 'struct'
		out = dir_picks(:);
	case 'char'
		out = char(full_file_picks);
	case 'cancel'
		out = 0;
end


% -------------------- Callback functions --------------------

	function add(varargin)
		values = get(navlist,'Value');
		for i = 1:length(values)
			dir_pick = fdir(values(i));
			pick = dir_pick.name;
			pick_full = fullfile(current_dir,pick);
			dir_pick.name = pick_full;
			if ~nodupes || ~any(strcmp(full_file_picks,pick_full))
				file_picks{end + 1} = pick; %#ok<AGROW>
				full_file_picks{end + 1} = pick_full; %#ok<AGROW>
				dir_picks(end + 1) = dir_pick; %#ok<AGROW>
			end
		end
		if show_full_path
			set(pickslist,'String',full_file_picks,'Value',[]);
		else
			set(pickslist,'String',file_picks,'Value',[]);
		end
		set([removebut,moveupbut,movedownbut],'Enable','off');
	end

	function remove(varargin)
		values = get(pickslist,'Value');
		file_picks(values) = [];
		full_file_picks(values) = [];
		dir_picks(values) = [];
		top = get(pickslist,'ListboxTop');
		num_above_top = sum(values < top);
		top = top - num_above_top;
		num_picks = length(file_picks);
		new_value = min(min(values) - num_above_top,num_picks);
		if num_picks == 0
			new_value = [];
			set([removebut,moveupbut,movedownbut],'Enable','off')
		end
		if show_full_path
			set(pickslist,'String',full_file_picks,'Value',new_value,...
				'ListboxTop',top)
		else
			set(pickslist,'String',file_picks,'Value',new_value,...
				'ListboxTop',top)
		end
	end

	function open(varargin)
		values = get(navlist,'Value');
		if fdir(values).isdir
			set(fig,'pointer','watch')
			drawnow
			current_dir = fullfile(current_dir,fdir(values).name);
			history{end+1} = current_dir;
			history = unique(history);
			hist_menus = make_history_cm(hist_cb,hist_cm,hist_menus,...
				history);
			full_filter = fullfile(current_dir,filter);
			path_cell = path2cell(current_dir);
			fdir = filtered_dir(full_filter,re_filter,prop.redirs);
			filenames = {fdir.name}';
			filenames = annotate_file_names(filenames,fdir,fsdata);
			set(dir_popup,'String',path_cell,'Value',length(path_cell))
			if length(path_cell) > 1
				set(up_dir_but','Enable','on')
			else
				set(up_dir_but','Enable','off')
			end
			set(pathbox,'String',current_dir)
			set(navlist,'ListboxTop',1,'Value',[],'String',filenames)
			set(addbut,'Enable','off')
			set(openbut,'Enable','off')
			set(fig,'pointer','arrow')
		end
	end

	function clicknav(varargin)
		value = get(navlist,'Value');
		nval = length(value);
		dbl_click_fcn = @add;
		switch nval
			case 0
				set([addbut,openbut],'Enable','off')
			case 1
				set(addbut,'Enable','on');
				if fdir(value).isdir
					set(openbut,'Enable','on')
					dbl_click_fcn = @open;
				else
					set(openbut,'Enable','off')
				end
			otherwise
				set(addbut,'Enable','on')
				set(openbut,'Enable','off')
		end
		if strcmp(get(fig,'SelectionType'),'open')
			dbl_click_fcn();
		end
	end

	function keypressnav(h,evt) %#ok<INUSL>
		if length(path_cell) > 1 && strcmp(evt.Key,'backspace')
			dir_up_one()
		end
		
		% Some key combinations cause the menu bar to appear so we turn it
		% back off.
		set(fig,'MenuBar','none')
	end

	function clickpicks(varargin)
		value = get(pickslist,'Value');
		if isempty(value)
			set([removebut,moveupbut,movedownbut],'Enable','off')
		else
			set(removebut,'Enable','on')
			if min(value) == 1
				set(moveupbut,'Enable','off')
			else
				set(moveupbut,'Enable','on')
			end
			if max(value) == length(file_picks)
				set(movedownbut,'Enable','off')
			else
				set(movedownbut,'Enable','on')
			end
		end
		if strcmp(get(fig,'SelectionType'),'open')
			remove();
		end
	end

	function dirpopup(varargin)
		value = get(dir_popup,'Value');
		path_cell = path_cell(1:value);
		set(fig,'pointer','watch')
		drawnow
		if ispc && value == 1
			current_dir = '';
			full_filter = filter;
			drives = getdrives(network_volumes);
			num_drives = length(drives);
			temp = tempname;
			mkdir(temp)
			dir_temp = dir(temp);
			rmdir(temp)
			fdir = repmat(dir_temp(1),num_drives,1);
			[fdir.name] = deal(drives{:});
		else
			current_dir = cell2path(path_cell);
			history{end+1} = current_dir;
			history = unique(history);
			hist_menus = make_history_cm(hist_cb,hist_cm,hist_menus,...
				history);
			full_filter = fullfile(current_dir,filter);
			fdir = filtered_dir(full_filter,re_filter,prop.redirs);
		end
		filenames = {fdir.name}';
		filenames = annotate_file_names(filenames,fdir,fsdata);
		set(dir_popup,'String',path_cell,'Value',length(path_cell))
		if length(path_cell) > 1
			set(up_dir_but','Enable','on')
		else
			set(up_dir_but','Enable','off')
		end
		set(pathbox,'String',current_dir)
		set(navlist,'String',filenames,'Value',[])
		set(addbut,'Enable','off')
		set(fig,'pointer','arrow')
	end

	function dir_up_one(varargin)
		value = length(path_cell) - 1;
		path_cell = path_cell(1:value);
		set(fig,'pointer','watch')
		drawnow
		if ispc && value == 1
			current_dir = '';
			full_filter = filter;
			drives = getdrives(network_volumes);
			num_drives = length(drives);
			temp = tempname;
			mkdir(temp)
			dir_temp = dir(temp);
			rmdir(temp)
			fdir = repmat(dir_temp(1),num_drives,1);
			[fdir.name] = deal(drives{:});
		else
			current_dir = cell2path(path_cell);
			history{end+1} = current_dir;
			history = unique(history);
			hist_menus = make_history_cm(hist_cb,hist_cm,hist_menus,...
				history);
			full_filter = fullfile(current_dir,filter);
			fdir = filtered_dir(full_filter,re_filter,prop.redirs);
		end
		filenames = {fdir.name}';
		filenames = annotate_file_names(filenames,fdir,fsdata);
		set(dir_popup,'String',path_cell,'Value',length(path_cell))
		if length(path_cell) > 1
			set(up_dir_but','Enable','on')
		else
			set(up_dir_but','Enable','off')
		end
		set(pathbox,'String',current_dir)
		set(navlist,'String',filenames,'Value',[])
		set(addbut,'Enable','off')
		set(fig,'pointer','arrow')
	end

	function change_path(varargin)
		set(fig,'pointer','watch')
		drawnow
		proposed_path = get(pathbox,'String');
		% Process any directories named '..'.
		proposed_path_cell = path2cell(proposed_path);
		ddots = strcmp(proposed_path_cell,'..');
		ddots(find(ddots) - 1) = true;
		proposed_path_cell(ddots) = [];
		proposed_path = cell2path(proposed_path_cell);
		% Check for existance of directory.
		if ~exist(proposed_path,'dir')
			set(fig,'pointer','arrow')
			uiwait(errordlg(['Directory "',proposed_path,...
				'" does not exist.'],'','modal'))
			return
		end
		current_dir = proposed_path;
		history{end+1} = current_dir;
		history = unique(history);
		hist_menus = make_history_cm(hist_cb,hist_cm,hist_menus,history);
		full_filter = fullfile(current_dir,filter);
		[path_cell,new_network_vol] = path2cell(current_dir);
		if exist(new_network_vol,'dir')
			network_volumes = unique([network_volumes,{new_network_vol}]);
		end
		fdir = filtered_dir(full_filter,re_filter,prop.redirs);
		filenames = {fdir.name}';
		filenames = annotate_file_names(filenames,fdir,fsdata);
		set(dir_popup,'String',path_cell,'Value',length(path_cell))
		if length(path_cell) > 1
			set(up_dir_but','Enable','on')
		else
			set(up_dir_but','Enable','off')
		end
		set(pathbox,'String',current_dir)
		set(navlist,'String',filenames,'Value',[])
		set(addbut,'Enable','off')
		set(openbut,'Enable','off')
		set(fig,'pointer','arrow')
	end

	function showfullpath(varargin)
		show_full_path = get(viewfullpath,'Value');
		if show_full_path
			set(pickslist,'String',full_file_picks)
		else
			set(pickslist,'String',file_picks)
		end
	end

	function removedupes(varargin)
		nodupes = get(remove_dupes,'Value');
		if nodupes
			num_picks = length(full_file_picks);
			[unused,rev_order] = unique(full_file_picks(end:-1:1));
			order = sort(num_picks + 1 - rev_order);
			full_file_picks = full_file_picks(order);
			file_picks = file_picks(order);
			dir_picks = dir_picks(order);
			if show_full_path
				set(pickslist,'String',full_file_picks,'Value',[])
			else
				set(pickslist,'String',file_picks,'Value',[])
			end
			set([removebut,moveupbut,movedownbut],'Enable','off')
		end
	end

	function moveup(varargin)
		value = get(pickslist,'Value');
		set(removebut,'Enable','on')
		n = length(file_picks);
		omega = 1:n;
		index = zeros(1,n);
		index(value - 1) = omega(value);
		index(setdiff(omega,value - 1)) = omega(setdiff(omega,value));
		file_picks = file_picks(index);
		full_file_picks = full_file_picks(index);
		dir_picks = dir_picks(index);
		value = value - 1;
		if show_full_path
			set(pickslist,'String',full_file_picks,'Value',value)
		else
			set(pickslist,'String',file_picks,'Value',value)
		end
		if min(value) == 1
			set(moveupbut,'Enable','off')
		end
		set(movedownbut,'Enable','on')
	end

	function movedown(varargin)
		value = get(pickslist,'Value');
		set(removebut,'Enable','on')
		n = length(file_picks);
		omega = 1:n;
		index = zeros(1,n);
		index(value + 1) = omega(value);
		index(setdiff(omega,value + 1)) = omega(setdiff(omega,value));
		file_picks = file_picks(index);
		full_file_picks = full_file_picks(index);
		dir_picks = dir_picks(index);
		value = value + 1;
		if show_full_path
			set(pickslist,'String',full_file_picks,'Value',value)
		else
			set(pickslist,'String',file_picks,'Value',value)
		end
		if max(value) == n
			set(movedownbut,'Enable','off')
		end
		set(moveupbut,'Enable','on')
	end

	function togglefilter(varargin)
		set(fig,'pointer','watch')
		drawnow
		value = get(showallfiles,'Value');
		if value
			filter = '*';
			re_filter = '';
			set([filter_ed,refilter_ed],'Enable','off')
		else
			filter = get(filter_ed,'String');
			re_filter = get(refilter_ed,'String');
			set([filter_ed,refilter_ed],'Enable','on')
		end
		full_filter = fullfile(current_dir,filter);
		fdir = filtered_dir(full_filter,re_filter,prop.redirs);
		filenames = {fdir.name}';
		filenames = annotate_file_names(filenames,fdir,fsdata);
		set(navlist,'String',filenames,'Value',[])
		set(addbut,'Enable','off')
		set(fig,'pointer','arrow')
	end

	function toggle_refiltdirs(varargin)
		set(fig,'pointer','watch')
		drawnow
		value = get(refilterdirs,'Value');
		prop.redirs = value;
		full_filter = fullfile(current_dir,filter);
		fdir = filtered_dir(full_filter,re_filter,prop.redirs);
		filenames = {fdir.name}';
		filenames = annotate_file_names(filenames,fdir,fsdata);
		set(navlist,'String',filenames,'Value',[])
		set(addbut,'Enable','off')
		set(fig,'pointer','arrow')
	end

	function setfilspec(varargin)
		set(fig,'pointer','watch')
		drawnow
		filter = get(filter_ed,'String');
		if isempty(filter)
			filter = '*';
			set(filter_ed,'String',filter)
		end
		% Process file spec if a subdirectory was included.
		[p,f,e] = fileparts(filter);
		if ~isempty(p)
			newpath = fullfile(current_dir,p,'');
			set(pathbox,'String',newpath)
			filter = [f,e];
			if isempty(filter)
				filter = '*';
			end
			set(filter_ed,'String',filter)
			change_path();
		end
		full_filter = fullfile(current_dir,filter);
		fdir = filtered_dir(full_filter,re_filter,prop.redirs);
		filenames = {fdir.name}';
		filenames = annotate_file_names(filenames,fdir,fsdata);
		set(navlist,'String',filenames,'Value',[])
		set(addbut,'Enable','off')
		set(fig,'pointer','arrow')
	end

	function setrefilter(varargin)
		set(fig,'pointer','watch')
		drawnow
		re_filter = get(refilter_ed,'String');
		fdir = filtered_dir(full_filter,re_filter,prop.redirs);
		filenames = {fdir.name}';
		filenames = annotate_file_names(filenames,fdir,fsdata);
		set(navlist,'String',filenames,'Value',[])
		set(addbut,'Enable','off')
		set(fig,'pointer','arrow')
	end

	function filter_type_callback(varargin)
		type_value = get(type_popup,'Value');
		set(filter_ed,'String',prop.type{type_value,1})
		setfilspec()
	end

	function done(varargin)
		% Optional shortcut: click on a file and press 'Done'.
% 		if isempty(full_file_picks) && strcmp(get(addbut,'Enable'),'on')
% 			add();
% 		end
		numfiles = length(full_file_picks);
		if ~isempty(prop.numfiles)
			if numfiles < prop.numfiles(1)
				msg = {'Too few files selected.',numstr};
				uiwait(errordlg(msg,'','modal'))
				return
			elseif numfiles > prop.numfiles(end)
				msg = {'Too many files selected.',numstr};
				uiwait(errordlg(msg,'','modal'))
				return
			end
		end
		delete(fig)
	end

	function cancel(varargin)
		prop.output = 'cancel';
		delete(fig)
	end

	function history_cb(varargin)
		set(fig,'pointer','watch')
		drawnow
		current_dir = history{varargin{3}};
		full_filter = fullfile(current_dir,filter);
		path_cell = path2cell(current_dir);
		fdir = filtered_dir(full_filter,re_filter,prop.redirs);
		filenames = {fdir.name}';
		filenames = annotate_file_names(filenames,fdir,fsdata);
		set(dir_popup,'String',path_cell,'Value',length(path_cell))
		if length(path_cell) > 1
			set(up_dir_but','Enable','on')
		else
			set(up_dir_but','Enable','off')
		end
		set(pathbox,'String',current_dir)
		set(navlist,'ListboxTop',1,'Value',[],'String',filenames)
		set(addbut,'Enable','off')
		set(openbut,'Enable','off')
		set(fig,'pointer','arrow')
	end
end


% -------------------- Subfunctions --------------------

function [c,network_vol] = path2cell(p)
% Turns a path string into a cell array of path elements.
if ispc
	p = strrep(p,'/','\');
	k = regexp(p,'(^\\\\[^\\]+\\[^\\]+)|(^[A-Za-z]+:)','end');
	vol = p(1:k);
	c1 = strread(p(k+2:end),'%s','delimiter','\\/');
	c = [{'My Computer'};{vol};c1];
	if strncmp(vol,'\\',2)
		network_vol = vol;
	else
		network_vol = '';
	end
else
	c = strread(p,'%s','delimiter','\\/');
	c = [{filesep};c(2:end)];
	network_vol = '';
end
end

% --------------------

function p = cell2path(c)
% Turns a cell array of path elements into a path string.
if ispc
	p = fullfile(c{2:end},'');
else
	p = fullfile(c{:},'');
end
end

% --------------------

function d = filtered_dir(full_filter,re_filter,filter_both)
% Like dir, but applies filters and sorting.
p = fileparts(full_filter);
if isempty(p) && full_filter(1) == '/'
	p = '/';
end
if exist(full_filter,'dir')
	dfiles = dir(' ');
else
	dfiles = dir(full_filter);
end
if ~isempty(dfiles)
	dfiles([dfiles.isdir]) = [];
end
ddir = dir(p);
ddir = ddir([ddir.isdir]);
% Additional regular expression filter.
if nargin > 1 && ~isempty(re_filter)
	if ispc || ismac
		no_match = cellfun('isempty',regexpi({dfiles.name},re_filter));
	else
		no_match = cellfun('isempty',regexp({dfiles.name},re_filter));
	end
	dfiles(no_match) = [];
end
if filter_both
	if nargin > 1 && ~isempty(re_filter)
		if ispc || ismac
			no_match = cellfun('isempty',regexpi({ddir.name},re_filter));
		else
			no_match = cellfun('isempty',regexp({ddir.name},re_filter));
		end
		ddir(no_match) = [];
	end
end
% Set navigator style:
%	1 => list all directories before all files, case-insensitive sorting
%	2 => mix files and directories, case-insensitive sorting
%	3 => list all directories before all files, case-sensitive sorting
nav_style = 1;
switch nav_style
	case 1
		[unused,index1] = sort(lower({dfiles.name}));
		ddir(strcmp({ddir.name},'.') | strcmp({ddir.name},'..')) = [];
		[unused,index2] = sort(lower({ddir.name}));
		d = [ddir(index2);dfiles(index1)];
	case 2
		ddir(strcmp({ddir.name},'.') | strcmp({ddir.name},'..')) = [];
		d = [dfiles;ddir];
		[unused,index] = sort(lower({d.name}));
		d = d(index);
	case 3
		[unused,index1] = sort({dfiles.name});
		ddir(strcmp({ddir.name},'.') | strcmp({ddir.name},'..')) = [];
		[unused,index2] = sort({ddir.name});
		d = [ddir(index2);dfiles(index1)];
end
end

% --------------------

function drives = getdrives(other_drives)
% Returns a cell array of drive names on Windows.
letters = char('A':'Z');
num_letters = length(letters);
drives = cell(1,num_letters);
for i = 1:num_letters
	if exist([letters(i),':\'],'dir');
		drives{i} = [letters(i),':'];
	end
end
drives(cellfun('isempty',drives)) = [];
if nargin > 0 && iscellstr(other_drives)
	drives = [drives,unique(other_drives)];
end
end

% --------------------

function filenames = annotate_file_names(filenames,dir_listing,fsdata)
% Adds a trailing filesep character to directory names and, optionally,
% prepends a folder icon or bullet symbol.
for i = 1:length(filenames)
	if dir_listing(i).isdir
		filenames{i} = sprintf('%s%s%s%s',fsdata.pre,filenames{i},...
			fsdata.filesep,fsdata.post);
	end
end
end

% --------------------

function hist_menus = make_history_cm(cb,hist_cm,hist_menus,history)
% Make context menu for history.
if ~isempty(hist_menus)
	delete(hist_menus)
end
num_hist = length(history);
hist_menus = zeros(1,num_hist);
for i = 1:num_hist
	hist_menus(i) = uimenu(hist_cm,'Label',history{i},...
		'Callback',{cb,i});
end
end

% --------------------

function success = generate_folder_icon(icon_path)
% Black = 1, manila color = 2, transparent = 3.
im = [ ...
	3 3 3 1 1 1 1 3 3 3 3 3;
	3 3 1 2 2 2 2 1 3 3 3 3;
	3 1 1 1 1 1 1 1 1 1 1 3;
	1 2 2 2 2 2 2 2 2 2 2 1;
	1 2 2 2 2 2 2 2 2 2 2 1;
	1 2 2 2 2 2 2 2 2 2 2 1;
	1 2 2 2 2 2 2 2 2 2 2 1;
	1 2 2 2 2 2 2 2 2 2 2 1;
	1 2 2 2 2 2 2 2 2 2 2 1;
	1 1 1 1 1 1 1 1 1 1 1 1];
cmap = [0 0 0;255 220 130;255 255 255]/255;
fid = fopen(icon_path,'w');
if fid > 0
	fclose(fid);
	imwrite(im,cmap,icon_path,'Transparency',[1 1 0])
end
success = exist(icon_path,'file');
end

% --------------------

function fsdata = set_folder_style(folder_style_pref)
% Set style to preference.
fsdata.style = folder_style_pref;
% If style = 1, check to make sure icon image file exists.  If it doesn't,
% try to create it.  If that fails set style = 2.
if fsdata.style == 1
	icon_path = fullfile(fileparts(mfilename('fullpath')),...
		'uipickfiles_folder_icon.png');
	if ~exist(icon_path,'file')
		success = generate_folder_icon(icon_path);
		if ~success
			fsdata.style = 2;
		end
	end
end
% Set pre and post fields.
if fsdata.style == 1
	icon_url = ['file://localhost/',...
		strrep(strrep(icon_path,':','|'),'\','/')];
	fsdata.pre = sprintf('<html><img src="%s">&nbsp;',icon_url);
	fsdata.post = '</html>';
elseif fsdata.style == 2
	fsdata.pre = '<html><b>&#8226;</b>&nbsp;';
	fsdata.post = '</html>';
elseif fsdata.style == 3
	fsdata.pre = '';
	fsdata.post = '';
end
fsdata.filesep = filesep;

end
