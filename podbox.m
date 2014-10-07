function varargout = podbox(varargin)
warning off

global orighandles current_path;

if nargin == 0
    current_path = cd;
    addpath(current_path);

    fig = openfig(mfilename,'reuse','invisible');
    movegui(fig,'center')
    set(fig,'DockControls','off');

    handles = guihandles(fig);

    handles.inst_list = '-|u|v|(u^2+v^2)^(1/2)|vorticity|sxx=du/dx|du/dy|dv/dx|syy=dv/dy|du/dx+dv/dy|sxy';

    handles.fig = fig;
    handles.previous_quantity = '-';
    handles.multimode = 1;
    handles.SelectedModes = 1;
    orighandles = handles;
    guidata(handles.fig, handles);


    set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

    guidata(handles.fig, handles);

    if nargout > 0
        varargout{1} = fig;
    end
    set(findobj(handles.fig,'type','uicontrol'),'Enable','Off');

    Pos_spat=get(handles.spatial_controls,'Position');
    set(handles.spatial_controls,'Position',...
        [0.95-Pos_spat(3) 0.96-Pos_spat(4) Pos_spat(3) Pos_spat(4)]);

    Pos_ctrl=get(handles.select_controls,'Position');
    set(handles.select_controls,'Position',...
        [0.95-Pos_spat(3) 0.96-Pos_ctrl(4) Pos_spat(3) Pos_ctrl(4)]);

    Pos_energy=get(handles.uipanel_relEnergy,'Position');
    set(handles.uipanel_relEnergy,'Position',...
        [0.95-Pos_spat(3) 0.93-Pos_ctrl(4)-Pos_energy(3) Pos_spat(3) Pos_energy(4)]);

    Pos_plot=get(handles.uipanel_plotoptions,'Position');
    set(handles.uipanel_plotoptions,'Position',...
        [0.95-Pos_spat(3) 0.93-Pos_ctrl(4)-Pos_energy(4)-0.14 Pos_spat(3) Pos_plot(4)]);

    set(handles.fig,'Visible','on');

elseif ischar(varargin{1})

    try
        if (nargout)
            [varargout{1:nargout}] = feval(varargin{:});
        else
            feval(varargin{:});
        end
    catch
        disp(lasterr);
    end

end
warning off

% --------------------------------------------------------------------
function checkbox_arrow_Callback(hObject, eventdata, handles)
if get(handles.checkbox_arrow,'Value') == 0
    handles.color=0;
    set(handles.checkbox_arrow_color,'Enable','off');
    set(handles.checkbox_arrow_color,'Value',0);
else
    set(handles.checkbox_arrow_color,'Enable','on');
    delete(get(handles.axes_main,'children'));
end
guidata(handles.fig,handles);
update_gui(handles.fig,[],handles);


% --------------------------------------------------------------------
function checkbox_arrow_color_Callback(hObject, eventdata, handles)
if (get(hObject,'Value') == 1)
    handles.color = 1;
else

    handles.color = 0;

    set(handles.color_quiver,'Visible','off');
end

guidata(handles.fig,handles);
update_gui(handles.fig,[],handles);


% --------------------------------------------------------------------
function varargout = popupmenu_quantity_Callback(h, eventdata, handles)

if get(handles.checkbox_modes,'Value' ) == 1
    switch get(handles.popupmenu_quantity,'Value')
        case 1
            handles.property = [];
            set(handles.edit_min_clim,'Visible','Off');
            set(handles.edit_max_clim,'Visible','Off');
            set(handles.pushbutton_set_clim,'Visible','Off');
            handles.alltodisp = 0;
            handles.allfields = 0;

        case 2
            handles.units = handles.velUnits;

            handles.property = handles.umodes(:,:,handles.current);
        case 3
            handles.units = handles.velUnits;
            handles.property = handles.vmodes(:,:,handles.current);
        case 4
            handles.units = handles.velUnits;
            handles.property = sqrt(handles.umodes(:,:,handles.current).^2+...
                handles.vmodes(:,:,handles.current).^2);
        case 5
            if ~isempty(findstr(handles.velUnits,'s'))
                handles.units='[1/s]'  ;
            else
                handles.units = '[1/\Delta t]';
            end

            [handles.dudx,handles.dudy] = gradient(handles.umodes(:,:,handles.current),...
                handles.dx, handles.dy);
            [handles.dvdx,handles.dvdy] = gradient(handles.vmodes(:,:,handles.current),...
                handles.dx, handles.dy);

            handles.property = handles.dvdx - handles.dudy ;
        case 6
            if ~isempty(findstr(handles.velUnits,'s'))
                handles.units='[1/s]'  ;
            else
                handles.units = '[1/\Delta t]';
            end
            [handles.dudx,handles.dudy] = gradient(handles.umodes(:,:,handles.current),...
                handles.dx, handles.dy);
            handles.property = handles.dudx;
        case 7
            if ~isempty(findstr(handles.velUnits,'s'))
                handles.units='[1/s]'  ;
            else
                handles.units = '[1/\Delta t]';
            end
            [handles.dudx,handles.dudy] = gradient(handles.umodes(:,:,handles.current),...
                handles.dx, handles.dy);
            handles.property = handles.dudy;
        case 8
            if ~isempty(findstr(handles.velUnits,'s'))
                handles.units='[1/s]'  ;
            else
                handles.units = '[1/\Delta t]';
            end
            [handles.dvdx,handles.dvdy] = gradient(handles.vmodes(:,:,handles.current),...
                handles.dx, handles.dy);

            handles.property = handles.dvdx;
        case 9
            if ~isempty(findstr(handles.velUnits,'s'))
                handles.units='[1/s]'  ;
            else
                handles.units = '[1/\Delta t]';
            end
            [handles.dvdx,handles.dvdy] = gradient(handles.vmodes(:,:,handles.current),...
                handles.dx, handles.dy);
            handles.property = handles.dvdy;
        case 10
            if ~isempty(findstr(handles.velUnits,'s'))
                handles.units='[1/s]'  ;
            else
                handles.units = '[1/\Delta t]';
            end
            [handles.dudx,handles.dudy] = gradient(handles.umodes(:,:,handles.current),...
                handles.dx, handles.dy);
            [handles.dvdx,handles.dvdy] = gradient(handles.vmodes(:,:,handles.current),...
                handles.dx, handles.dy);

            handles.property = handles.dudx + handles.dvdy;
        case 11 % s_xy
            if ~isempty(findstr(handles.velUnits,'s'))
                handles.units='[1/s]'  ;
            else
                handles.units = '[1/\Delta t]';
            end
            [handles.dudx,handles.dudy] = gradient(handles.umodes(:,:,handles.current),...
                handles.dx, handles.dy);
            [handles.dvdx,handles.dvdy] = gradient(handles.vmodes(:,:,handles.current),...
                handles.dx, handles.dy);

            handles.property = 0.5*(handles.dvdx + handles.dudy);
    end

elseif (get(handles.checkbox_reconstruction,'Value') == 1 || get(handles.radiobutton_multimode,'Value') == 1)

    if get(handles.checkbox_reconstruction,'Value') == 1
        [handles.uRec, handles.vRec] = poduv(handles,3);
    end
    %---------------------------
    switch get(handles.popupmenu_quantity,'Value')
        case 1
            handles.property = [];
            set(handles.edit_min_clim,'Visible','Off');
            set(handles.edit_max_clim,'Visible','Off');
            set(handles.pushbutton_set_clim,'Visible','Off');
            handles.alltodisp = 0;
            handles.allfields = 0;

        case 2
            handles.units = handles.velUnits;
            handles.property = handles.uRec;

        case 3
            handles.units = handles.velUnits;
            handles.property = handles.vRec;

        case 4
            handles.units = handles.velUnits;
            handles.property = sqrt(handles.uRec.^2 + handles.vRec.^2);

        case 5
            if ~isempty(findstr(handles.velUnits,'s'))
                handles.units = '[1/s]'  ;
            else
                handles.units = '[1/\Delta t]';
            end
            [dudx,dudy] = gradient(handles.uRec,handles.dx, handles.dy);
            [dvdx,dvdy] = gradient(handles.vRec,handles.dx, handles.dy);
            handles.property = dvdx - dudy;
        case 6
            if ~isempty(findstr(handles.velUnits,'s'))
                handles.units = '[1/s]'  ;
            else
                handles.units = '[1/\Delta t]';
            end
            [dudx,dudy] = gradient(handles.uRec,handles.dx, handles.dy);
            [dvdx,dvdy] = gradient(handles.vRec,handles.dx, handles.dy);
            handles.property = dudx;
        case 7
            if ~isempty(findstr(handles.velUnits,'s'))
                handles.units = '[1/s]'  ;
            else
                handles.units = '[1/\Delta t]';
            end
            [dudx,dudy] = gradient(handles.uRec,handles.dx, handles.dy);
            [dvdx,dvdy] = gradient(handles.vRec,handles.dx, handles.dy);
            handles.property = dudy;
        case 8
            if ~isempty(findstr(handles.velUnits,'s'))
                handles.units = '[1/s]'  ;
            else
                handles.units = '[1/\Delta t]';
            end
            [dudx,dudy] = gradient(handles.uRec,handles.dx, handles.dy);
            [dvdx,dvdy] = gradient(handles.vRec,handles.dx, handles.dy);
            handles.property = dvdx;
        case 9
            if ~isempty(findstr(handles.velUnits,'s'))
                handles.units = '[1/s]'  ;
            else
                handles.units = '[1/\Delta t]';
            end
            [dudx,dudy] = gradient(handles.uRec,handles.dx, handles.dy);
            [dvdx,dvdy] = gradient(handles.vRec,handles.dx, handles.dy);
            handles.property = dvdy;
        case 10
            if ~isempty(findstr(handles.velUnits,'s'))
                handles.units = '[1/s]'  ;
            else
                handles.units = '[1/\Delta t]';
            end
            [dudx,dudy] = gradient(handles.uRec,handles.dx, handles.dy);
            [dvdx,dvdy] = gradient(handles.vRec,handles.dx, handles.dy);
            handles.property = dudx + dvdy;
        case 11 % s_xy
            if ~isempty(findstr(handles.velUnits,'s'))
                handles.units = '[1/s]'  ;
            else
                handles.units = '[1/\Delta t]';
            end
            [dudx,dudy] = gradient(handles.uRec,handles.dx, handles.dy);
            [dvdx,dvdy] = gradient(handles.vRec,handles.dx, handles.dy);
            handles.property = 0.5*(dvdx + dudy);
    end
end

if ~isempty(handles.property)
    if strcmp( get(handles.edit_arrow_size,'Enable'),'on')
        set(handles.checkbox_arrow_color,'Enable','on');
    end
end

tmp = cellstr(get(handles.popupmenu_quantity,'String'));
if strcmp(handles.previous_quantity,tmp{get(handles.popupmenu_quantity,'Value')}) == 0 && ...
        get(handles.popupmenu_eachfield,'Value') == 3
    handles.previous_quantity = tmp{get(handles.popupmenu_quantity,'Value')};
    popupmenu_eachfield_Callback(handles.fig, [], handles);
else
    handles.previous_quantity = tmp{get(handles.popupmenu_quantity,'Value')};
    guidata(handles.fig,handles);
    update_gui(handles.fig,[],handles);
end

function edit_numcolors_Callback(h, eventdata, handles)
numcolors = str2double(get(h,'String'));
if numcolors < 1 | isnan(numcolors)
    warndlg('Wrong number of colors, must be greater than 0', 'Error','modal');
    set(h,'String',10);
else
    handles.numcolors = numcolors;
end
if isempty(handles.numcolors),
    set(h,'String',10);
    handles.numcolors = 10;
end
guidata(handles.fig,handles);
update_gui(handles.fig,[],handles);


function update_gui(h, eventdata, handles)

persistent kernel;
kernel = ...
    [0.0030    0.0133    0.0219    0.0133    0.0030
    0.0133    0.0596    0.0983    0.0596    0.0133
    0.0219    0.0983    0.1621    0.0983    0.0219
    0.0133    0.0596    0.0983    0.0596    0.0133
    0.0030    0.0133    0.0219    0.0133    0.0030];

axes(handles.axes_main); grid on; box on; axis ij;
delete(get(handles.axes_main,'children'));


if ~isfield(handles,'umodes') | isempty(handles.umodes)
    handles.umodes = handles.u(:,:,1);
    handles.vmodes = handles.v(:,:,1);
end

if get(handles.popupmenu_quantity,'Value') == 1 ,
    set(handles.checkbox_label,'Enable','Off');
    set(handles.checkbox_colorbar,'Enable','Off');
    set(handles.text_numberofcolors,'Enable','Off');
    set(handles.edit_numcolors,'Enable','Off');
    set(handles.popupmenu_eachfield,'Enable','Off');
    set(handles.edit_max_clim,'Enable','Off');
    set(handles.edit_min_clim,'Enable','Off');
    set(handles.pushbutton_set_clim,'Enable','Off');
    set(handles.popupmenu_contour_type,'Enable','Off');
else
    set(handles.checkbox_label,'Enable','On');
    set(handles.checkbox_colorbar,'Enable','On');
    set(handles.text_numberofcolors,'Enable','On');
    set(handles.edit_numcolors,'Enable','On');
    set(handles.popupmenu_eachfield,'Enable','On');
    set(handles.edit_max_clim,'Enable','On');
    set(handles.edit_min_clim,'Enable','On');
    set(handles.pushbutton_set_clim,'Enable','On');
    set(handles.popupmenu_contour_type,'Enable','On');
end

if ~isempty(handles.property)
    switch (get(handles.popupmenu_contour_type,'Value'))
        case 1
            cla reset;
        case 2
            [handles.C,handles.CH] = contourf('v6',handles.x,handles.y,filter2(kernel,handles.property,'same'),handles.numcolors);
            set(handles.CH,'edgecolor','none');
        case 3
            [handles.C,handles.CH] = contour('v6',handles.x,handles.y,filter2(kernel,handles.property,'same'),handles.numcolors);
        case 4
            [handles.C,handles.CH] = contourf('v6',handles.x,handles.y,filter2(kernel,handles.property,'same'),handles.numcolors);
        case 5
            [handles.C,handles.CH] = contour('v6',handles.x,handles.y,filter2(kernel,handles.property,'same'),handles.numcolors);
            set(handles.CH,'edgecolor','black');
    end

    %     handles.climit_prev = get(gca,'clim');
    if handles.alltodisp == 1
        set(gca,'CLim',handles.climit);
    elseif handles.allfields == 1
        if get(handles.popupmenu_eachfield,'Value') == 4;
            handles.cmin = str2num(get(handles.edit_min_clim,'String'));
            handles.cmax = str2num(get(handles.edit_max_clim,'String'));
        end
        caxis('manual');
        caxis(handles.axes_main,[handles.cmin handles.cmax]);
    end
    if handles.labelit == 1
        if get(handles.popupmenu_contour_type,'Value')>1
            clabel(handles.C,handles.CH,'Color','b','Rotation',0);
        end;
    end

    if handles.colorbar_flag
        handles.colorbar = colorbar('v6','peer',handles.axes_main);
    end
else
    cla reset;
    handles.color = 0;
    set(handles.checkbox_arrow_color,'Enable','off');
    set(handles.checkbox_arrow_color,'Value',0);
    set(handles.checkbox_colorbar,'Value',0);
    set(handles.checkbox_label,'Value',0);
    set(handles.popupmenu_eachfield,'Value',1);
    handles.colorbar_flag=0;
    handles.labelit= 0;
end
if get(handles.checkbox_arrow,'Value') == 1
    if handles.color == 1
        hold on;
        if (get(handles.checkbox_reconstruction,'Value') == 1 | get(handles.radiobutton_multimode,'Value') == 1)
            handles.color_quiver = quiverc(handles.x,handles.y,handles.uRec,handles.vRec,handles.arrow_scale,handles.property);
        elseif get(handles.checkbox_modes,'Value') == 1
            handles.color_quiver = quiverc(handles.x,handles.y,handles.umodes(:,:,handles.current),handles.vmodes(:,:,handles.current),handles.arrow_scale,handles.property);
        end
        hold off;
        if handles.colorbar_flag
            handles.colorbar = colorbar('v6','peer',handles.axes_main);
        end
    else
        hold on;
        if (get(handles.checkbox_reconstruction,'Value') == 1 | get(handles.radiobutton_multimode,'Value') == 1)
            handles.quiver = quiver(handles.x,handles.y,handles.uRec,handles.vRec,handles.arrow_scale,'k');
        else
            handles.quiver = quiver(handles.x,handles.y,handles.umodes(:,:,handles.current),handles.vmodes(:,:,handles.current),handles.arrow_scale,'k');
        end

    end
    hold off;
end
handles.climit_prev = get(gca,'clim');
set(handles.axes_main,'XLim',[min(handles.x(:)),max(handles.x(:))]);
set(handles.axes_main,'YLim',[min(handles.y(:)),max(handles.y(:))]);
xlabel(['x ',handles.xUnits]);
ylabel(['y ',handles.xUnits]);

if isfield(handles,'colorbar') & get(handles.checkbox_colorbar,'Value') == 1
    set(handles.axes_main,'Units','normalized');
    axpos = get(handles.axes_main,'Position');
    set(handles.colorbar,'Units','normalized','Position',[axpos(1)+axpos(3)+0.018+0.04,axpos(2),0.020,axpos(4)]);
    set(handles.axes_main,'Position',[axpos(1),axpos(2),axpos(3)+0.04,axpos(4)]);

end
box( handles.axes_main,'on');
guidata(handles.fig,handles);

function varargout = edit_min_clim_Callback(h, eventdata, handles, varargin)
handles.cmin = str2num(get(handles.edit_min_clim,'String'));
if isempty(handles.cmin)
    warndlg('Wrong input','Error','modal');
    current_clim = get(handles.axes_main,'clim');
    set(handles.edit_min_clim,'String',sprintf('%3.2f',current_clim(1)));
    handles.cmin = current_clim(2);
end
% handles.alltodisp = 0;
% handles.allfields = 1;
guidata(handles.fig,handles);


function varargout = edit_max_clim_Callback(h, eventdata, handles, varargin)
handles.cmax = str2num(get(handles.edit_max_clim,'String'));
if isempty(handles.cmax),
    warndlg('Wrong input','Error','modal');
    current_clim = get(handles.axes_main,'clim');
    set(handles.edit_max_clim,'String',sprintf('%3.2f',current_clim(2)));
    handles.cmax = current_clim(2);
end
% handles.alltodisp = 0;
% handles.allfields = 1;
guidata(handles.fig,handles);


function varargout = pushbutton_set_clim_Callback(h, eventdata, handles, varargin)

edit_min_clim_Callback(h, eventdata, handles, varargin)
edit_max_clim_Callback(h, eventdata, handles, varargin)

% handles.cmin = str2num(get(handles.edit_min_clim,'String'));
% handles.cmax = str2num(get(handles.edit_max_clim,'String'));

if handles.cmin >= handles.cmax
    warndlg('Wrong limits, min should be less than max', 'Error','modal');
    current_clim = get(handles.axes_main,'clim');
    handles.cmin = current_clim(1);
    handles.cmax = current_clim(2);
    set(handles.edit_min_clim,'String',sprintf('%3.2f',handles.cmin));
    set(handles.edit_max_clim,'String',sprintf('%3.2f',handles.cmax));
end
guidata(handles.fig,handles);
update_gui(handles.fig,[],handles);


function varargout = pushbutton_previous_Callback(h, eventdata, handles, varargin)
if handles.current > 1
    handles.current = handles.current - 1;
    set(handles.edit_current,'String',handles.current);
    delete(get(handles.axes_main,'children'));
    guidata(handles.fig,handles);
    popupmenu_quantity_Callback(handles.fig, [], handles);
else
    beep;
end


function varargout = pushbutton_next_Callback(h, eventdata, handles, varargin)
if get(handles.checkbox_modes,'Value') == 1
    if handles.current < handles.numOfModes
        handles.current = handles.current + 1;
        set(handles.edit_current,'String',handles.current);
        guidata(handles.fig,handles);
        delete(get(handles.axes_main,'children'));
        popupmenu_quantity_Callback(handles.fig, [], handles);
    else
        beep;
    end
else
    if handles.current < handles.N
        handles.current = handles.current + 1;
        set(handles.edit_current,'String',handles.current);
        guidata(handles.fig,handles);
        delete(get(handles.axes_main,'children'));
        popupmenu_quantity_Callback(handles.fig, [], handles);
    else
        beep;
    end
end

function varargout = edit_current_Callback(h, eventdata, handles, varargin)
tmp = fix(str2double(get(handles.edit_current,'String')));

if isnan(tmp)
    beep
    tmp = 1;
    set(handles.edit_current,'String','1');
end

if get(handles.checkbox_modes,'Value') == 1

    if tmp > 0 & tmp <= handles.numOfModes
        handles.current = tmp;
        guidata(handles.fig,handles);
        popupmenu_quantity_Callback(handles.fig, [], handles);
    else
        beep
        set(handles.edit_current,'String',handles.current);
    end
else
    if tmp > 0 & tmp <= handles.N
        handles.current = tmp;
        guidata(handles.fig,handles);
        popupmenu_quantity_Callback(handles.fig, [], handles);
    else
        beep
        set(handles.edit_current,'String',handles.current);
    end
end



function varargout = edit_arrow_size_Callback(h, eventdata, handles, varargin)
handles.arrow_scale = str2double(get(h,'String'));
if handles.arrow_scale == 0 | isempty(handles.arrow_scale) | isnan(handles.arrow_scale)
    handles.arrow_scale = 1;
    set(handles.edit_arrow_size,'String','1');
end
guidata(handles.fig,handles);
update_gui(handles.fig,[],handles);


function varargout = pushbutton_animate_Callback(h, eventdata, handles, varargin)

if get(handles.pushbutton_animate,'Value') == 1
    startpoint = handles.current;
    if get(handles.checkbox_modes,'Value') == 1
        for i = startpoint:handles.numOfModes
            if get(handles.pushbutton_animate,'Value') == 0
                break;
            end
            handles.current = i;
            set(handles.edit_current,'String',handles.current);
            delete(get(handles.axes_main,'children'));
            guidata(handles.fig,handles);
            popupmenu_quantity_Callback(handles.fig, [], handles);
            drawnow;
        end
    elseif get(handles.checkbox_reconstruction,'Value') == 1
        for i = startpoint:handles.N
            if get(handles.pushbutton_animate,'Value') == 0
                break;
            end
            handles.current = i;
            set(handles.edit_current,'String',handles.current);
            delete(get(handles.axes_main,'children'));
            guidata(handles.fig,handles);
            popupmenu_quantity_Callback(handles.fig, [], handles);
            drawnow;
        end
    end
else

end
set(handles.pushbutton_animate,'Value',0);



function varargout = pushbutton_save_movie_Callback(h, eventdata, handles, varargin)

if get(handles.pushbutton_save_movie,'Value') == 1
    file = [];
    file = inputdlg('File Name','Input File Name for the movie');
    if isempty(file) | exist(file{1},'file') | exist([file{1},'.avi'],'file')
        set(handles.pushbutton_save_movie,'Value',0);
        return
    end
    handles.mov = avifile(file{1},'compression','none','quality',100,'fps',15);

    startpoint = handles.current;
    if get(handles.checkbox_modes,'Value') == 1
        for i = startpoint:handles.numOfModes
            handles.current = i;
            set(handles.edit_current,'String',handles.current);
            delete(get(handles.axes_main,'children'));
            guidata(handles.fig,handles);
            popupmenu_quantity_Callback(handles.fig, [], handles);
            F = getframe(handles.axes_main);
            if get(handles.pushbutton_save_movie,'Value') == 0
                break;
            end
            handles.mov = addframe(handles.mov,F);
        end
    elseif get(handles.checkbox_reconstruction,'Value') ==1
        for i = startpoint:handles.N
            handles.current = i;
            set(handles.edit_current,'String',handles.current);
            delete(get(handles.axes_main,'children'));
            guidata(handles.fig,handles);
            popupmenu_quantity_Callback(handles.fig, [], handles);
            F = getframe(handles.axes_main);
            if get(handles.pushbutton_save_movie,'Value') == 0
                break;
            end
            handles.mov = addframe(handles.mov,F);
        end
    end

    if isfield(handles,'mov')
        handles.mov = close(handles.mov);
        handles = rmfield(handles,'mov');
    end

end
set(handles.pushbutton_save_movie,'Value',0);

% -------------------------------------------------------------------------
function varargout = checkbox_label_Callback(h, eventdata, handles, varargin)
if (get(h,'Value') == get(h,'Max'))
    if get(handles.popupmenu_contour_type,'Value')>1
        handles.labelit = 1;

        clabel(handles.C,handles.CH,'Color','b','Rotation',0);
        guidata(handles.fig,handles);
    else
        set(handles.checkbox_label,'Value',0);
    end;
else
    handles.labelit = 0;
    guidata(handles.fig,handles);
    update_gui(handles.fig,[],handles);
end


function varargout = checkbox_colorbar_Callback(h, eventdata, handles, varargin)
if get(h,'Value') == 1
    handles.colorbar_flag = 1;
    guidata(handles.fig,handles);
    update_gui(handles.fig,[],handles);
else
    delete(findobj(handles.fig,'Tag','Colorbar'));
    handles.colorbar_flag = 0;
    guidata(handles.fig,handles);
end

function popupmenu_eachfield_Callback(hObject, eventdata, handles)
% Each Field, All to display, all fields & manual processing

% get value and assign selected property to handles.property which is default to display
val = get(handles.popupmenu_eachfield,'Value');
% redirect in case of
if  get(handles.radiobutton_multimode,'Value')==1
    if val==2 | val==3
        val=1;
        set(handles.popupmenu_eachfield,'Value',1);
    end
end

switch val
    case 1
        set(handles.edit_min_clim,'Visible','Off');
        set(handles.edit_max_clim,'Visible','Off');
        set(handles.pushbutton_set_clim,'Visible','Off');
        handles.alltodisp = 0;                             % unset all other flags
        handles.allfields = 0;
    case 2
        set(handles.edit_min_clim,'Visible','Off');
        set(handles.edit_max_clim,'Visible','Off');
        set(handles.pushbutton_set_clim,'Visible','Off');
        handles.alltodisp = 1;
        handles.climit = handles.climit_prev;
    case 3
        set(handles.edit_min_clim,'Visible','Off');
        set(handles.edit_max_clim,'Visible','Off');
        set(handles.pushbutton_set_clim,'Visible','Off');
        handles.alltodisp = 0;
        handles.allfields = 1;
        if get(handles.checkbox_modes,'Value') == 1
            switch get(handles.popupmenu_quantity,'Value')
                case 1
                    handles.cmin = 0; handles.cmax = 1;
                case 2
                    handles.cmin = min(handles.umodes(:)); handles.cmax = max(handles.umodes(:));
                case 3
                    handles.cmin = min(handles.vmodes(:)); handles.cmax = max(handles.vmodes(:));
                case 4
                    handles.cmin = min(sqrt(handles.umodes(:).^2+handles.vmodes(:).^2));
                    handles.cmax = max(sqrt(handles.umodes(:).^2+handles.vmodes(:).^2));
                case 5
                    handles.cmin = Inf;
                    handles.cmax = -Inf;
                    for i = 1:handles.numOfModes
                        [dudx,dudy] = gradient(handles.umodes(:,:,handles.current),handles.dx, handles.dy);
                        [dvdx,dvdy] = gradient(handles.vmodes(:,:,handles.current),handles.dx, handles.dy);
                        tmp = dvdx - dudy ;
                        handles.cmin = min(handles.cmin,min(tmp(:)));
                        handles.cmax = max(handles.cmax,max(tmp(:)));
                    end
                case 6
                    handles.cmin = Inf;
                    handles.cmax = -Inf;
                    for i = 1:handles.numOfModes
                        [dudx,dudy] = gradient(handles.umodes(:,:,handles.current),handles.dx, handles.dy);
                        tmp = dudx;
                        handles.cmin = min(handles.cmin,min(tmp(:)));
                        handles.cmax = max(handles.cmax,max(tmp(:)));
                    end
                case 7
                    handles.cmin = Inf;
                    handles.cmax = -Inf;
                    for i = 1:handles.numOfModes
                        [dudx,dudy] = gradient(handles.umodes(:,:,handles.current),handles.dx, handles.dy);
                        tmp = dudy;
                        handles.cmin = min(handles.cmin,min(tmp(:)));
                        handles.cmax = max(handles.cmax,max(tmp(:)));
                    end

                case 8
                    handles.cmin = Inf;
                    handles.cmax = -Inf;
                    for i = 1:handles.numOfModes
                        [dvdx,dvdy] = gradient(handles.vmodes(:,:,handles.current),handles.dx, handles.dy);
                        tmp = dvdx;
                        handles.cmin = min(handles.cmin,min(tmp(:)));
                        handles.cmax = max(handles.cmax,max(tmp(:)));
                    end
                case 9
                    handles.cmin = Inf;
                    handles.cmax = -Inf;
                    for i = 1:handles.numOfModes
                        [dvdx,dvdy] = gradient(handles.vmodes(:,:,handles.current),handles.dx, handles.dy);
                        tmp = dvdy;
                        handles.cmin = min(handles.cmin,min(tmp(:)));
                        handles.cmax = max(handles.cmax,max(tmp(:)));
                    end

                case 10
                    handles.cmin = Inf;
                    handles.cmax = -Inf;
                    for i = 1:handles.numOfModes
                        [dudx,dudy] = gradient(handles.umodes(:,:,handles.current),handles.dx, handles.dy);
                        [dvdx,dvdy] = gradient(handles.vmodes(:,:,handles.current),handles.dx, handles.dy);
                        tmp = dudx + dvdy;
                        handles.cmin = min(handles.cmin,min(tmp(:)));
                        handles.cmax = max(handles.cmax,max(tmp(:)));
                    end
                case 11
                    handles.cmin = Inf;
                    handles.cmax = -Inf;
                    for i = 1:handles.numOfModes
                        [dudx,dudy] = gradient(handles.umodes(:,:,handles.current),handles.dx, handles.dy);
                        [dvdx,dvdy] = gradient(handles.vmodes(:,:,handles.current),handles.dx, handles.dy);
                        tmp = 0.5* (dvdx + dudy);
                        handles.cmin = min(handles.cmin,min(tmp(:)));
                        handles.cmax = max(handles.cmax,max(tmp(:)));
                    end
            end
        elseif (get(handles.checkbox_reconstruction,'Value') == 1 | get(handles.radiobutton_multimode,'Value')==1)
            switch get(handles.popupmenu_quantity,'Value')
                case 1
                    handles.cmin = 0;
                    handles.cmax = 1;
                case 2

                    handles.cmin = Inf;
                    handles.cmax = -Inf;
                    tmpcounter = handles.current;
                    for i = 1:handles.N
                        handles.current = i;
                        [handles.uRec, handles.vRec] = poduv(handles,3);
                        handles.cmin = min(handles.cmin,min(handles.uRec(:)));
                        handles.cmax = max(handles.cmax,max(handles.uRec(:)));
                    end
                    handles.current = tmpcounter;

                case 3
                    handles.cmin = Inf;
                    handles.cmax = -Inf;
                    tmpcounter = handles.current;
                    for i = 1:handles.N
                        handles.current = i;
                        [handles.uRec, handles.vRec] = poduv(handles,3);
                        handles.cmin = min(handles.cmin,min(handles.vRec(:)));
                        handles.cmax = max(handles.cmax,max(handles.vRec(:)));
                    end
                    handles.current = tmpcounter;

                case 4
                    handles.cmin = Inf;
                    handles.cmax = -Inf;
                    tmpcounter = handles.current;
                    for i = 1:handles.N
                        handles.current = i;
                        [handles.uRec, handles.vRec] = poduv(handles,3);
                        tmp = sqrt(handles.uRec.^2 + handles.vRec.^2);
                        handles.cmin = min(handles.cmin,min(tmp(:)));
                        handles.cmax = max(handles.cmax,max(tmp(:)));
                    end
                    handles.current = tmpcounter;

                case 5
                    handles.cmin = Inf;
                    handles.cmax = -Inf;
                    tmpcounter = handles.current;
                    for i = 1:handles.N
                        handles.current = i;
                        [handles.uRec, handles.vRec] = poduv(handles,3);
                        [dudx,dudy] = gradient(handles.uRec,handles.dx, handles.dy);
                        [dvdx,dvdy] = gradient(handles.vRec,handles.dx, handles.dy);
                        tmp = 0.5* (dvdx - dudy);
                        handles.cmin = min(handles.cmin,min(tmp(:)));
                        handles.cmax = max(handles.cmax,max(tmp(:)));
                    end
                    handles.current = tmpcounter;
                case 6
                    handles.cmin = Inf;
                    handles.cmax = -Inf;
                    tmpcounter = handles.current;
                    for i = 1:handles.N
                        handles.current = i;

                        [handles.uRec, handles.vRec] = poduv(handles,3);
                        [dudx,dudy] = gradient(handles.uRec,handles.dx, handles.dy);
                        [dvdx,dvdy] = gradient(handles.vRec,handles.dx, handles.dy);
                        tmp = dudx;
                        handles.cmin = min(handles.cmin,min(tmp(:)));
                        handles.cmax = max(handles.cmax,max(tmp(:)));
                    end
                    handles.current = tmpcounter;
                case 7
                    handles.cmin = Inf;
                    handles.cmax = -Inf;
                    tmpcounter = handles.current;
                    for i = 1:handles.N
                        handles.current = i;

                        [handles.uRec, handles.vRec] = poduv(handles,3);
                        [dudx,dudy] = gradient(handles.uRec,handles.dx, handles.dy);
                        [dvdx,dvdy] = gradient(handles.vRec,handles.dx, handles.dy);
                        tmp = dudy;
                        handles.cmin = min(handles.cmin,min(tmp(:)));
                        handles.cmax = max(handles.cmax,max(tmp(:)));
                    end
                    handles.current = tmpcounter;
                case 8
                    handles.cmin = Inf;
                    handles.cmax = -Inf;
                    tmpcounter = handles.current;
                    for i = 1:handles.N
                        handles.current = i;
                        [handles.uRec, handles.vRec] = poduv(handles,3);
                        [dudx,dudy] = gradient(handles.uRec,handles.dx, handles.dy);
                        [dvdx,dvdy] = gradient(handles.vRec,handles.dx, handles.dy);
                        tmp = dvdx;
                        handles.cmin = min(handles.cmin,min(tmp(:)));
                        handles.cmax = max(handles.cmax,max(tmp(:)));
                    end
                    handles.current = tmpcounter;
                case 9
                    handles.cmin = Inf;
                    handles.cmax = -Inf;
                    tmpcounter = handles.current;
                    for i = 1:handles.N
                        handles.current = i;
                        [handles.uRec, handles.vRec] = poduv(handles,3);
                        [dudx,dudy] = gradient(handles.uRec,handles.dx, handles.dy);
                        [dvdx,dvdy] = gradient(handles.vRec,handles.dx, handles.dy);
                        tmp = dvdy;
                        handles.cmin = min(handles.cmin,min(tmp(:)));
                        handles.cmax = max(handles.cmax,max(tmp(:)));
                    end
                    handles.current = tmpcounter;
                case 10
                    handles.cmin = Inf;
                    handles.cmax = -Inf;
                    tmpcounter = handles.current;
                    for i = 1:handles.N
                        handles.current = i;
                        [handles.uRec, handles.vRec] = poduv(handles,3);
                        [dudx,dudy] = gradient(handles.uRec,handles.dx, handles.dy);
                        [dvdx,dvdy] = gradient(handles.vRec,handles.dx, handles.dy);
                        tmp = dudx + dvdy;
                        handles.cmin = min(handles.cmin,min(tmp(:)));
                        handles.cmax = max(handles.cmax,max(tmp(:)));
                    end
                    handles.current = tmpcounter;
                case 11
                    handles.cmin = Inf;
                    handles.cmax = -Inf;
                    tmpcounter = handles.current;
                    for i = 1:handles.N
                        handles.current = i;
                        [handles.uRec, handles.vRec] = poduv(handles,3);
                        [dudx,dudy] = gradient(handles.uRec,handles.dx, handles.dy);
                        [dvdx,dvdy] = gradient(handles.vRec,handles.dx, handles.dy);
                        tmp = 0.5* (dvdx + dudy);
                        handles.cmin = min(handles.cmin,min(tmp(:)));
                        handles.cmax = max(handles.cmax,max(tmp(:)));
                    end
                    handles.current = tmpcounter;
            end
        end
    case 4
        set(handles.edit_min_clim,'Visible','On');
        set(handles.edit_max_clim,'Visible','On');
        set(handles.pushbutton_set_clim,'Visible','On');
        handles.alltodisp = 0;
        handles.allfields = 1;
        current_clim = get(handles.axes_main,'clim');
        set(handles.edit_min_clim,'String',sprintf('%3.2f',current_clim(1)));
        set(handles.edit_max_clim,'String',sprintf('%3.2f',current_clim(2)));
end

guidata(handles.fig,handles);
update_gui(handles.fig,[],handles);



function checkbox_modes_Callback(hObject, eventdata, handles)

set (handles.arrow_ctrls,'Enable','on');
set(handles.checkbox_modes,'Value',1);
if get(handles.checkbox_modes,'Value') == 1
    set(handles.edit_numfields,'String',int2str(handles.numOfModes));
    set(handles.checkbox_reconstruction,'Value',0)
    set(handles.radiobutton_multimode,'Value',0);
    set(handles.edit_multimode,'Visible','off','Enable','off');
    set(handles.edit_SelectedModes,'Visible','off','Enable','off');
    set(handles.radiobutton_weights,'Visible','off','Value',0);
    set(handles.edit_min_clim,'Visible','Off');
    set(handles.edit_max_clim,'Visible','Off');
    set(handles.pushbutton_set_clim,'Visible','Off');
    handles.alltodisp = 0;
    handles.allfields = 0;
    set(handles.popupmenu_eachfield,'String','Each Field|All to Display|All Fields|Manual');

    handles.current = 1;
    set(handles.edit_current,'String',handles.current);
    set(handles.pushbutton_previous,'Enable','on');
    set(handles.pushbutton_next,'Enable','on');
    set(handles.pushbutton_animate,'Enable','on');
    set(handles.pushbutton_save_movie,'Enable','on');
    set(handles.edit_current,'Enable','on');

end
set(handles.popupmenu_eachfield,'String','Each Field|All to Display|All Fields|Manual');

set(handles.popupmenu_quantity,'Value',1);
handles.property = [];
handles.C = [];
handles.CH = [];
guidata(handles.fig,handles);
update_gui(handles.fig,[],handles);


function checkbox_reconstruction_Callback(hObject, eventdata, handles)
set(handles.arrow_ctrls,'Enable','on');
set(handles.edit_numfields,'String',int2str(handles.N));
set(handles.checkbox_reconstruction,'Value',1);
% if (get(handles.checkbox_reconstruction,'Value') == 1)
set(handles.edit_numfields,'String',int2str(handles.N));
set(handles.checkbox_modes,'Value',0);
set(handles.radiobutton_multimode,'Value',0);
set(handles.edit_multimode,'Visible','off','Enable','off');
set(handles.radiobutton_weights,'Visible','off','Enable','off');
set(handles.edit_min_clim,'Visible','Off');
set(handles.edit_max_clim,'Visible','Off');
set(handles.pushbutton_set_clim,'Visible','Off');
handles.current = 1;
set(handles.edit_current,'String',int2str(handles.current));
set(handles.pushbutton_previous,'Enable','on');
set(handles.pushbutton_next,'Enable','on');
set(handles.pushbutton_animate,'Enable','on');
set(handles.pushbutton_save_movie,'Enable','on');
set(handles.edit_current,'Enable','on');
handles.alltodisp = 0;
handles.allfields = 0;
set(handles.popupmenu_eachfield,'String','Each Field|All to Display|All Fields|Manual');
% end

set(handles.popupmenu_quantity,'Value',1);
set(handles.edit_SelectedModes,'Visible','on','Enable','on');
set(handles.edit_SelectedModes,'String',['1:',int2str(handles.numOfModes)]);

try
    handles.SelectedModes =  sort(eval(['[',get(handles.edit_SelectedModes,'String'),']',]));
catch
    warndlg('Wrong input: e.g. 1,3,5 or 1:2:5 or 1:5','Error','modal');
end

if min(size(handles.SelectedModes)) ~= 1 | ~isempty(findstr(get(handles.edit_SelectedModes,'String'),'.')) % | max(size(handles.SelectedModes)) ~= 2
    warndlg('Wrong input: e.g. 1,3,5 or 1:2:5 or 1:5','Error','modal');
elseif ( handles.SelectedModes(1) < 1 | max(handles.SelectedModes) > handles.numOfModes)
    warndlg('Input must be in the range of 1:number of modes','Error','modal');
end

[handles.uRec, handles.vRec] = poduv(handles,3);
handles.current = 1;
handles.property    =   [];
handles.C           =   [];
handles.CH          =   [];
guidata(handles.fig,handles);
update_gui(handles.fig,[],handles);


function File_Callback(hObject, eventdata, handles)

function load_Callback(hObject, eventdata, handles)

global orighandles;
if isfield(handles,'restoreorig')
    handles = orighandles;
end
handles.restoreorig = 1;

try
    %     [gui_files,gui_path] = getVECfiles;
    fileTypes = {'*.txt', 'OpenPIV TXT files'
        '*.vec', 'Insight 3G VEC files'
        '*.mat', 'SpatialToolbox MAT files'};

    [handles.files] = uipickfiles('Type',fileTypes);

    %     handles.N = length(gui_files);
    %     if  handles.N >= 1
    %         handles.files = gui_files;
    %         handles.path = gui_path;
    %         set(handles.fig,'pointer','watch');
    %     else
    %         warndlg('More than 2 files are required','Error','modal');
    %         set(handles.fig,'pointer','arrow');
    %         return
    %     end

    handles.N = length(handles.files); % number of files selected
    if  handles.N > 0
        [handles.path,~,extension] = fileparts(handles.files{1});
        set(handles.fig,'pointer','watch');
    else
        return
    end

    switch(extension)
        case{'.vec'}
            [handles.xUnits,handles.velUnits,d] = vecread(handles.files{1});
            [rows,cols,k] = size(d);
            [handles.u,handles.v] = deal(zeros(rows,cols,handles.N));
            handles.x           = d(:,:,1);
            handles.y           = d(:,:,2);
            handles.u(:,:,1)    = d(:,:,3);
            handles.v(:,:,1)    = d(:,:,4);
            for i = 2:handles.N
                d = vecread(handles.files{i},1,5);
                handles.u(:,:,i) = d(:,:,3);
                handles.v(:,:,i) = d(:,:,4);
            end

        case{'.txt'}
                d = load(handles.files{1});
                d = repmat(d,[1 1 handles.N]);
                for i = 2:handles.N
                    d(:,:,i) = load(handles.files{i});
                end

                x = d(:,1,:);
                x = x(x~=0);
                unX = unique(x);

                minX = min(unX);
                maxX = max(unX);
                dX = ceil((maxX-minX)/(length(unX)-1));

                y = d(:,2,:);
                y = y(y~=0);
                unY = unique(y);

                minY = min(unY);
                maxY = max(unY);
                dY = ceil((maxY-minY)/(length(unY)-1));

                [handles.x,handles.y] = meshgrid(minX:dX:maxX,minY:dY:maxY);
                [rows,cols] = size(handles.x);

                [handles.u,handles.v] = deal(zeros(rows,cols,handles.N+1)); % 11.04.04, Alex

                for i = 1:handles.N
                    x = d(:,1,i);
                    tmp = d(x~=0,:,i);
                    y = tmp(:,2);
                    x = tmp(:,1);
                    for j = 1:length(x)
                        [m,n] = find(handles.x == x(j) & handles.y == y(j));
                        handles.u(m,n,i) = tmp(j,3);
                        handles.v(m,n,i) = tmp(j,4);
                    end
                end

                handles.xUnits = 'pix';
                handles.velUnits = 'pix/dt';

        case{'.mat'}
            tmp = load(handles.files{1}); % should be only one file
            handles.x = tmp.x;
            handles.y = tmp.y;
            handles.u = tmp.u;
            handles.v = tmp.v;
            handles.uf = tmp.uf;
            handles.vf = tmp.vf;
            handles.files = tmp.files;
            handles.path = tmp.path;
            handles.dx = tmp.dx;
            handles.dy = tmp.dy;
            handles.dudx = tmp.dudx;
            handles.dvdx = tmp.dvdx;
            handles.dudy = tmp.dudy;
            handles.dvdy = tmp.dvdy;
            handles.gridX = tmp.gridX;
            handles.gridY = tmp.gridY;
            handles.N = tmp.N;
            handles.xUnits = tmp.xUnits;
            handles.velUnits = tmp.velUnits;
            clear tmp

        otherwise
            
    end % of switch
catch
    keyboard
    warndlg('Something wrong with vector files','Error','modal');
    set(handles.fig,'pointer','arrow');
    return
end


handles.dx = handles.x(1,2) - handles.x(1,1);
handles.dy = handles.y(2,1) - handles.y(1,1);
handles.gridX = abs(handles.dx);
handles.gridY = abs(handles.dy);

handles.current = 1;
set(handles.edit_current,'String',handles.current);
set(handles.edit_numfields,'String',handles.N);

handles.numcolors = 10;
colormap(handles.axes_main,'jet');
set(handles.edit_numcolors,'String', handles.numcolors);

handles.arrow_scale = 1;                % default scale
set(handles.edit_arrow_size,'String',handles.arrow_scale);

set(handles.checkbox_modes,'Value',1);
set(handles.checkbox_reconstruction,'Value',0);
set(handles.radiobutton_multimode,'Value',0);
set(handles.edit_multimode,'Visible','off','Enable','off');

handles.color = 0;
handles.alltodisp = 0;
handles.allfields = 0;
handles.labelit = 0;
handles.colorbar_flag = 0;
handles.current_index = handles.current;
handles.distribOn=0;
handles.rowlock=0; handles.columnlock=0;
handles.previousSel=[];

handles.i=[];
handles.j=[];
handles.PointsH=[];
handles.Allselected=0;


set(handles.spatial_controls,'Visible','off');
set(handles.select_controls,'Visible','on');
set(findobj(handles.select_controls,'type','uicontrol'),'Enable','On');
% set(handles.uipanel_plotoptions,'Visible','on');
% set(findobj(handles.uipanel_plotoptions,'type','uicontrol'),'Enable','On');
% set(handles.checkbox_DirectSnapshot,'Enable','off');
set(handles.pushbutton_select,'String','> Select <');
set(handles.pushbutton_pod,'String','POD');

set(handles.popupmenu_quantity,'Visible','on');
set(handles.popupmenu_quantity,'Value',1);
set(handles.popupmenu_contour_type,'Visible','on');
set(handles.popupmenu_contour_type,'Value',1);
set(handles.popupmenu_eachfield,'Visible','on');
set(handles.popupmenu_eachfield,'Value',1);

set(handles.checkbox_arrow,'Enable','On');
set(handles.edit_arrow_size,'Enable','On');
set(handles.checkbox_reconstruction,'Enable','On');
set(handles.checkbox_modes,'Enable','On');
set(handles.popupmenu_quantity,'Enable','On');
set(handles.pushbutton_previous,'Enable','On');
set(handles.pushbutton_next,'Enable','On');
set(handles.edit_current,'Enable','On');
set(handles.pushbutton_animate,'Enable','On');
set(handles.pushbutton_save_movie,'Enable','on');

set(handles.popupmenu_quantity,'String',handles.inst_list);

handles.property = [];

handles.select_options_panel = [...
    handles.pushbutton_selectreg,...
    handles.pushbutton_selectall,...
    handles.pushbutton_reset,...
    handles.pushbutton_start...
    ];

handles.arrow_ctrls = [ ...
    handles.edit_arrow_size,...
    handles.checkbox_arrow,...
    handles.checkbox_arrow_color...
    ];

set(handles.pushbutton_pod,'Enable','Off');

set(handles.fig,'pointer','arrow');

set(handles.checkbox_DirectSnapshot,'Value',0);
% sizeU = size(handles.u);
% if (sizeU(1)*sizeU(2) > handles.N)
%     set(handles.checkbox_DirectSnapshot,'Value',0);
% else
%     set(handles.checkbox_DirectSnapshot,'Value',1);
% end

guidata(handles.fig,handles);

update_gui(handles.fig,[],handles);


function exit_Callback(hObject, eventdata, handles)
while ~strcmpi(get(hObject,'Type'),'figure'),
    hObject = get(hObject,'Parent');
end
delete(hObject);

function pushbutton_pod_Callback(hObject, eventdata, handles)

set(handles.spatial_controls,'Visible','on');
set(handles.select_controls,'Visible','Off');
set(handles.uipanel_relEnergy,'Visible','Off');
set(handles.pushbutton_pod,'FontWeight','bold');
set(handles.pushbutton_select,'FontWeight','normal');
set(handles.pushbutton_pod,'String','>POD<');
set(handles.pushbutton_select,'String','Select');
val = get(handles.popupmenu_eachfield,'Value');
if val == 4
    set(handles.edit_min_clim,'Visible','On');
    set(handles.edit_max_clim,'Visible','On');
    set(handles.pushbutton_set_clim,'Visible','On');
end

handles.i = []; handles.j = [];
handles.rowlock=0; handles.columnlock=0;
handles.previousSel=[];

update_gui(gcbo,[],guidata(gcbo));
guidata(handles.fig,handles);


function pushbutton_select_Callback(hObject, eventdata, handles)
set(handles.spatial_controls,'Visible','Off');
set(handles.select_controls,'Visible','on');
set(handles.uipanel_relEnergy,'Visible','on');
set(findobj(handles.select_controls,'type','uicontrol'),'Enable','On');
set(handles.pushbutton_select,'String','> Select <');
set(handles.pushbutton_pod,'String','POD');


set(handles.pushbutton_pod,'FontWeight','normal');
set(handles.pushbutton_select,'FontWeight','bold');
val = get(handles.popupmenu_eachfield,'Value');
handles.i = []; handles.j = [];
handles.rowlock=0; handles.columnlock=0;
handles.previousSel=[];

update_gui(gcbo,[],guidata(gcbo));
guidata(handles.fig,handles);


function pushbutton_selectreg_Callback(hObject, eventdata, handles)
set(findobj(handles.uipanel_relEnergy,'type','uicontrol'),'Enable','Off');
set(findobj(handles.uipanel_relEnergy,'type','uicontrol'),'Enable','Off');
set(findobj(handles.select_controls,'type','uicontrol'),'Enable','Off');

set(handles.region_text,'Visible','on','Enable','on');

k       =   waitforbuttonpress;
point1  =   get(gca,'CurrentPoint');
finalRect = rbbox;
point2  =    get(gca,'CurrentPoint');
point1  =    point1(1,1:2);
point2  =    point2(1,1:2);
p1      =    min(point1,point2);
Offset  =    abs(point1-point2);


limX = xlim; limY = ylim;
leftcolX = fix(( p1(1)-limX(1,1) )/ handles.gridX +1) + 1;
rightcolX = fix(( p1(1)+Offset(1)-limX(1,1) )/ handles.gridX )+1;
bottomrowY =  fix(( p1(2)-limY(1,1) )/ handles.gridY+1 )+1;
uprowY = fix(( p1(2) + Offset(2) - limY(1,1) )/ handles.gridY)+1;


plotstateX=0;plotstateY=0;
if leftcolX<1     leftcolX=1;
    plotstateY= 1;
end;
rightLimit=fix((limX(1,2)-limX(1,1))/handles.gridX)+1;
if rightcolX>rightLimit  rightcolX=rightLimit; end;
uprowLimit=fix((limY(1,2)-limY(1,1))/handles.gridY)+1;
if bottomrowY<1  bottomrowY=1;
    plotstateX= 1;
end
if uprowY>uprowLimit     uprowY=uprowLimit; end;

sizeI = size(handles.i,1);
sizeJ = size(handles.j,1);
numofcols = rightcolX-leftcolX+1;
numofrows = uprowY-bottomrowY+1;


if ~isempty(handles.previousSel)
    a = handles.previousSel;
    if ((rightcolX-leftcolX) == a(2)-a(1) & a(2) == rightcolX & handles.rowlock~=1)
        handles.columnlock=1;
    elseif    ((uprowY-bottomrowY)==a(4)-a(3) & a(4)==uprowY & handles.columnlock~=1)
        handles.rowlock=1;
    else
        warndlg('Your Selection is Invalid...','Error','modal');
        set(findobj(handles.select_controls,'type','uicontrol'),'Enable','On');
        set(handles.region_text,'Visible','off');
        return;
        return;
    end;
end;

if ismember([bottomrowY leftcolX],[handles.i handles.j],'rows') | ismember([bottomrowY rightcolX],[handles.i handles.j],'rows') | ...
        ismember([uprowY leftcolX],[handles.i handles.j],'rows') | ismember([uprowY rightcolX],[handles.i handles.j],'rows')
    warndlg('Your Selection is Invalid...','Error','modal');
    set(findobj(handles.select_controls,'type','uicontrol'),'Enable','On');

    set(handles.region_text,'Visible','off');
    return;
end

for i1 = bottomrowY:uprowY
    handles.i(sizeI+1:sizeI+numofcols,1)    =   i1;
    handles.j(sizeJ+1:sizeJ+numofcols,1)    =   leftcolX:rightcolX;
    sizeI   =   sizeI+numofcols;
    sizeJ   =   sizeJ+numofcols;
end

lx_box=limX(1,1)+(leftcolX-1)*handles.gridX*~plotstateY;
rx_box=limX(1,1)+(rightcolX-1)*handles.gridX;
uy_box=limY(1,1)+(uprowY-1)*handles.gridY;
by_box=limY(1,1)+(bottomrowY-1)*handles.gridY*~plotstateX;


x1 = [lx_box rx_box rx_box lx_box lx_box];
y1 = [by_box by_box uy_box uy_box by_box];
hold on
handles.selectionbox = plot(x1,y1,'--b','LineWidth',1.5);
hold off
handles.previousSel=[leftcolX rightcolX bottomrowY uprowY];

set(findobj(handles.select_controls,'type','uicontrol'),'Enable','On');
set(handles.pushbutton_selectreg,'Enable','Off');
set(handles.pushbutton_selectall,'Enable','Off');
set(handles.region_text,'Visible','off');

sizeU = (handles.i(length(handles.i))-handles.i(1)+1)*(handles.j(length(handles.j))-handles.j(1)+1);
if (sizeU > handles.N)
    set(handles.checkbox_DirectSnapshot,'Value',0);
else
    set(handles.checkbox_DirectSnapshot,'Value',1);
end
%       set(handles.checkbox_DirectSnapshot,'Enable','off');

guidata(handles.fig,handles);

function pushbutton_selectall_Callback(hObject, eventdata, handles)
set(handles.pushbutton_selectreg,'Enable','Off');
set(handles.pushbutton_selectall,'Enable','Off');
handles.Allselected=1;
update_gui(hObject,[],guidata(hObject));
handles.i=[]; handles.j=[]; handles.previousSel=[];
limX=xlim; limY=ylim;
x1 = [limX(1,1) limX(1,2) limX(1,2) limX(1,1) limX(1,1)];
y1 = [limY(1,1) limY(1,1) limY(1,2) limY(1,2) limY(1,1)];
hold on
handles.selectionbox = plot(x1,y1,':b','LineWidth',4);
hold off
leftcolX    =   1;
rightcolX   =   fix((limX(1,2)-limX(1,1))/handles.gridX)+1;
bottomrowY  =   1;
uprowY      =   fix((limY(1,2)-limY(1,1))/handles.gridY)+1;
numofcols=rightcolX-leftcolX+1;
sizeI=size(handles.i,1);
sizeJ=size(handles.j,1);
for i1 = bottomrowY:uprowY
    handles.i(sizeI+1:sizeI+numofcols,1)=i1;
    handles.j(sizeJ+1:sizeJ+numofcols,1)=leftcolX:rightcolX;
    sizeI=sizeI+numofcols; sizeJ=sizeJ+numofcols;
end
sizeU = (handles.i(length(handles.i))-handles.i(1)+1)*(handles.j(length(handles.j))-handles.j(1)+1);
if (sizeU > handles.N)
    set(handles.checkbox_DirectSnapshot,'Value',0);
else
    set(handles.checkbox_DirectSnapshot,'Value',1);
end

%  set(handles.checkbox_DirectSnapshot,'Enable','off');

guidata(handles.fig,handles);

function pushbutton_reset_Callback(hObject, eventdata, handles)

handles.i = []; handles.j = [];
handles.rowlock=0; handles.columnlock=0;
handles.previousSel=[];
set(handles.pushbutton_selectreg,'Enable','on');
set(handles.pushbutton_selectall,'Enable','on');
set(findobj(handles.uipanel_relEnergy,'type','uicontrol'),'Enable','Off');
set(findobj(handles.uipanel_plotoptions,'type','uicontrol'),'Enable','Off');
guidata(handles.fig,handles);
update_gui(gcbo,[],guidata(gcbo));


function figure_pod_CreateFcn(hObject, eventdata, handles)

load CIL_small_logo.mat
imshow(im,map);
axis off


function axes_main_CreateFcn(hObject, eventdata, handles)

handles.axes_main = hObject;
axis ij;
guidata(hObject, handles);


function hh = quiverc(varargin)
alpha = 0.33;
beta = 0.33;
autoscale = 1;
plotarrows = 1;
sym = '';

filled = 0;
ls = '-';
ms = '';
col = '';

nin = nargin;

while isstr(varargin{nin}),
    vv = varargin{nin};
    if ~isempty(vv) & strcmp(lower(vv(1)),'f')
        filled = 1;
        nin = nin-1;
    else
        [l,c,m,msg] = colstyle(vv);
        if ~isempty(msg),
            error(sprintf('Unknown option "%s".',vv));
        end
        if ~isempty(l), ls = l; end
        if ~isempty(c), col = c; end
        if ~isempty(m), ms = m; plotarrows = 0; end
        if isequal(m,'.'), ms = ''; end
        nin = nin-1;
    end
end

error(nargchk(2,6,nin));


if nin<4,
    [msg,x,y,u,v] = xyzchk(varargin{1:2});
else
    [msg,x,y,u,v] = xyzchk(varargin{1:4});
end
if ~isempty(msg), error(msg); end

if nin==4 | nin==6,
    autoscale = varargin{nin-1};
    z = varargin{nin};
end

if prod(size(u))==1, u = u(ones(size(x))); end
if prod(size(v))==1, v = v(ones(size(u))); end

if autoscale,
    if min(size(x))==1
        n=sqrt(prod(size(x)));
        m=n;
    else
        [m,n]=size(x);
    end
    delx = diff([min(x(:)) max(x(:))])/n;
    dely = diff([min(y(:)) max(y(:))])/m;
    del = delx.^2 + dely.^2;
    if del>0
        len = sqrt((u.^2 + v.^2)/del);
        maxlen = max(len(:));
    else
        maxlen = 0;
    end

    if maxlen>0
        autoscale = autoscale*0.9 / maxlen;
    else
        autoscale = autoscale*0.9;
    end
    u = u*autoscale; v = v*autoscale;
end


ax = newplot;
next = lower(get(ax,'NextPlot'));
hold_state = ishold;

x = x(:).'; y = y(:).';
u = u(:).'; v = v(:).';
uu = [x;x+u;repmat(NaN,size(u))];
vv = [y;y+v;repmat(NaN,size(u))];

z = [z(:)';z(:)';NaN*z(:)'];

h1 = patch([uu(:),uu(:)],[vv(:),vv(:)], [z(:),z(:)],'Parent',ax,'EdgeColor','Flat','FaceColor','None');

if plotarrows,
    hu = [x+u-alpha*(u+beta*(v+eps));x+u; ...
        x+u-alpha*(u-beta*(v+eps));repmat(NaN,size(u))];
    hv = [y+v-alpha*(v-beta*(u+eps));y+v; ...
        y+v-alpha*(v+beta*(u+eps));repmat(NaN,size(v))];
    hold on
    z = [z(1,:); z];
    h2 = patch([hu(:),hu(:)],[hv(:),hv(:)], [z(:),z(:)],'Parent',ax,'EdgeColor','Flat','FaceColor','None');

else
    h2 = [];
end

if ~isempty(ms),
    hu = x; hv = y;
    hold on
    h3 = plot(hu(:),hv(:),[col ms]);
    if filled, set(h3,'markerfacecolor',get(h1,'color')); end
else
    h3 = [];
end

if ~hold_state, hold off, view(2); set(ax,'NextPlot',next); end

if nargout > 0, hh = [h1;h2;h3]; end

function ed_max_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function export2figure_Callback(hObject, eventdata, handles)
handles.export_figure = figure;
copyobj(handles.axes_main,handles.export_figure);

set(handles.export_figure,'Units','normalized');
set(get(handles.export_figure,'children'),'Units','normalized');
set(get(handles.export_figure,'children'),'Position',[0.13 0.11 0.775 0.815]);
set(get(handles.export_figure,'children'),'Box','on');

% if isfield(handles,'color_flag')
if handles.colorbar_flag
    hcol=colorbar('v6');
    set(handles.axes_main,'Units','normalized');
    axpos = get(gca,'Position');
    set(hcol,'Units','normalized','Position',[axpos(1)+axpos(3)+0.018+0.04,axpos(2),0.020,axpos(4)]);
    set(gca,'Position',[axpos(1),axpos(2),axpos(3)+0.04,axpos(4)]);
end
% end
guidata(handles.fig, handles);


function pushbutton_start_Callback(hObject, eventdata, handles)


if ~isempty(handles.i)

    size_x = size(handles.x);

    sel_row_start = size_x(1) - handles.i(length(handles.i))+1;
    sel_row_end   = size_x(1) - handles.i(1)+1;

    handles.x = handles.x(sel_row_start:sel_row_end, handles.j(1):handles.j(length(handles.j)) );
    handles.y = handles.y(sel_row_start:sel_row_end, handles.j(1):handles.j(length(handles.j)) );
    handles.u = handles.u(sel_row_start:sel_row_end, handles.j(1):handles.j(length(handles.j)),: );
    handles.v = handles.v(sel_row_start:sel_row_end, handles.j(1):handles.j(length(handles.j)),:);

    if min(size(handles.x)) < 2
        warndlg('The region is N x 1, select at least 2 rows or 2 columns','Error','modal');
        return
    end

    set(handles.pushbutton_reset,'Enable','off');

    handles.METHOD_FLAG = get(handles.checkbox_DirectSnapshot,'Value');

    clear pod
    try
        [L] = poduv(handles,1);
    catch
        warndlg('Computation of POD modes failed due to memory problem');
    end

    axes(handles.axes_main);
    set(handles.export2figure,'Enable','on');
    delete(get(handles.axes_main,'children'));
    handles.Erel = cumsum(L(1:end))/sum(L(1:end));
    plot(1:length(handles.Erel),handles.Erel*100)

    set(handles.checkbox_DirectSnapshot,'Enable','off');
    set(handles.pushbutton_start,'Enable','off');


    set(get(handles.axes_main,'xlabel'),'string','Number of modes')
    set(get(handles.axes_main,'ylabel'),'string','Cummulative relative energy, %')

    set(handles.uipanel_relEnergy,'Visible','On');
    set(get(handles.uipanel_relEnergy,'Children'),'Visible','On','Enable','On');

    set(handles.uipanel_plotoptions,'Visible','On');
    set(get(handles.uipanel_plotoptions,'Children'),'Visible','On','Enable','On');

    handles.relEnergy = max(handles.Erel);
    set(handles.edit_relEnergy,'String',num2str(100*handles.relEnergy));
    set(handles.edit_numOfModes,'String',num2str(length(L)));
    handles.Energy=L;
    guidata(handles.fig,handles);
else
    warndlg('Select region of interest','Error','modal');
end



function edit_relEnergy_Callback(hObject, eventdata, handles)
handles.relEnergy = str2double(get(hObject,'String'))/100;
if handles.relEnergy > 1 | isnan(handles.relEnergy)
    handles.relEnergy = 1;
    set(handles.edit_relEnergy,'String',int2str(handles.relEnergy*100));
elseif handles.relEnergy < 0.01
    handles.relEnergy = 0.01;
    set(handles.edit_relEnergy,'String',int2str(handles.relEnergy*100));
end
handles.numOfModes = min(find(handles.Erel >= handles.relEnergy));
set(handles.edit_numOfModes,'String',int2str(handles.numOfModes));
handles.METHOD_FLAG = get(handles.checkbox_DirectSnapshot,'Value');
guidata(handles.fig,handles);

function edit_relEnergy_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_numOfModes_Callback(hObject, eventdata, handles)

handles.numOfModes = str2double(get(hObject,'String'));
if handles.numOfModes > handles.N | isnan(handles.numOfModes)
    handles.numOfModes = handles.N;
    set(handles.edit_numOfModes,'String',int2str(handles.numOfModes));
elseif handles.numOfModes < 1
    handles.numOfModes = 1;
    set(handles.edit_numOfModes,'String',int2str(handles.numOfModes));
end
handles.relEnergy = handles.Erel(handles.numOfModes);
set(handles.edit_relEnergy,'String',sprintf('%3.0f',100*handles.relEnergy));
guidata(handles.fig,handles);


function edit_numOfModes_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_continue_Callback(hObject, eventdata, handles)
edit_numOfModes_Callback(handles.edit_numOfModes,[], handles)
handles.numOfModes = str2double(get(handles.edit_numOfModes,'String'));

[handles.umodes,handles.vmodes] = poduv(handles,2);

handles.current = 1;
set(handles.edit_current,'String',handles.current);
set(handles.edit_numfields,'String',handles.numOfModes);
set(handles.edit_multimode,'String',['1:',int2str(handles.numOfModes)]);
set(handles.edit_SelectedModes,'String',['1:',int2str(handles.numOfModes)]);
handles.numcolors = 10;
set(handles.edit_numcolors,'String', handles.numcolors);

handles.arrow_scale = 1;
set(handles.edit_arrow_size,'String',handles.arrow_scale);

set(handles.checkbox_modes,'Value',1);


handles.color = 0;
handles.alltodisp = 0;
handles.allfields = 0;
handles.labelit = 0;
handles.colorbar_flag = 0;
handles.current_index = handles.current;
handles.distribOn = 0;
handles.rowlock = 0;
handles.columnlock = 0;
handles.previousSel = [];

set(handles.spatial_controls,'Visible','on');
set(handles.select_controls,'Visible','Off');
set(handles.uipanel_relEnergy,'Visible','Off');
set(handles.uipanel_plotoptions,'Visible','Off');

set(findobj(handles.spatial_controls,'type','uicontrol'),'Enable','On');
set(findobj(handles.select_controls,'type','uicontrol'),'Enable','Off');
set(findobj(handles.uipanel_relEnergy,'type','uicontrol'),'Enable','Off');
set(findobj(handles.uipanel_plotoptions,'type','uicontrol'),'Enable','Off');
set(handles.pushbutton_pod,'FontWeight','bold');
set(handles.pushbutton_select,'FontWeight','normal');
set(handles.pushbutton_select,'String','Select');
set(handles.pushbutton_select,'Enable','Off');
set(handles.pushbutton_pod,'String','>POD<');
set(handles.pushbutton_pod,'Enable','on');
set(handles.pushbutton_pod,'Enable','Off');

set(handles.popupmenu_quantity,'Visible','on');
set(handles.popupmenu_quantity,'Value',1);
set(handles.popupmenu_contour_type,'Visible','on');
set(handles.popupmenu_contour_type,'Value',1);
set(handles.popupmenu_eachfield,'Visible','on');
set(handles.popupmenu_eachfield,'Value',1);

set(handles.checkbox_arrow,'Enable','On');
set(handles.edit_arrow_size,'Enable','On');
set(handles.checkbox_reconstruction,'Enable','On');
set(handles.edit_SelectedModes,'Enable','off','Visible','off');
set(handles.checkbox_modes,'Enable','On');
set(handles.radiobutton_weights,'Value',0, 'Enable','off');
set(handles.popupmenu_quantity,'Enable','On');
set(handles.pushbutton_previous,'Enable','On');
set(handles.pushbutton_next,'Enable','On');
set(handles.edit_current,'Enable','On');
set(handles.pushbutton_animate,'Enable','On');
set(handles.pushbutton_save_movie,'Enable','on');

set(handles.popupmenu_quantity,'String',handles.inst_list);

handles.property = [];

set(handles.fig,'pointer','arrow');

% set(handles.checkbox_reconstruction,'Value',0, 'Enable','off');
% set(handles.radiobutton_multimode,'Value',0, 'Enable','off');
%menuhandle=get(handles.File,'Children');
set(get(handles.File,'Children'),'Enable','on');

guidata(handles.fig,handles);

update_gui(handles.fig,[],handles);


function radiobutton_multimode_Callback(hObject, eventdata, handles)
set(handles.radiobutton_multimode,'Value',1);
% if get(hObject,'Value') == 1
set(handles.checkbox_modes,'Value',0);
set(handles.checkbox_reconstruction,'Value',0);
set(handles.edit_multimode,'Visible','on','Enable','on');
set(handles.edit_SelectedModes,'Visible','off','Enable','off');
set(handles.radiobutton_weights,'Visible','on','Enable','on','Value',0);
set(handles.edit_min_clim,'Visible','Off');
set(handles.edit_max_clim,'Visible','Off');
set(handles.pushbutton_set_clim,'Visible','Off');
handles.alltodisp = 0;
handles.allfields = 0;
% end

set(findobj(handles.flow_field_panel,'type','uicontrol'),'Enable','off');
% handles.uRec = sum(handles.umodes(:,:,handles.multimode(1):handles.multimode(2)),3);  % sum of all modes
% handles.vRec =
% sum(handles.vmodes(:,:,handles.multimode(1):handles.multimode(2)),3);

try
    handles.multimode = sort(eval(['[',get(handles.edit_multimode,'String'),']']));
catch
    warndlg('Wrong input: e.g. 1 5 or 1,5 or 1:5 or 1:2:5','Error','modal');
end

if min(size(handles.multimode)) ~= 1 | ~isempty(findstr(get(handles.edit_multimode,'String'),'.')) %  | max(size(handles.multimode)) ~= 2
    warndlg('Wrong input: e.g. 1 5 or 1,5 or 1:5 or 1:2:5','Error','modal');
elseif (handles.multimode(1) < 1 | max(handles.multimode) > handles.numOfModes)
    warndlg('Input must be in the range of 1 - number of modes','Error','modal');
end

handles.uRec = sum(handles.umodes(:,:,handles.multimode),3);  % sum of all modes
handles.vRec = sum(handles.vmodes(:,:,handles.multimode),3);
handles.current = 1;
set(handles.popupmenu_eachfield,'String','Automatic|---|---|Manual');

set(handles.popupmenu_quantity,'Value',1);
handles.property = [];  handles.C = []; handles.CH = [];

guidata(handles.fig,handles);
update_gui(handles.fig,[],handles);


function edit_multimode_Callback(hObject, eventdata, handles)

try
    handles.multimode = sort(eval(['[',get(handles.edit_multimode,'String'),']']));
catch
    warndlg('Wrong input: e.g. 1 5 or 1,5 or 1:5 or 1:2:5','Error','modal');
end

if min(size(handles.multimode)) ~= 1 | ~isempty(findstr(get(handles.edit_multimode,'String'),'.')) %  | max(size(handles.multimode)) ~= 2
    warndlg('Wrong input: e.g. 1 5 or 1,5 or 1:5 or 1:2:5','Error','modal');
elseif (handles.multimode(1) < 1 | max(handles.multimode) > handles.numOfModes)
    warndlg('Input must be in the range of 1 - number of modes','Error','modal');
else
    if get(handles.radiobutton_weights,'Value') == 0
        handles.uRec = sum(handles.umodes(:,:,handles.multimode),3);
        handles.vRec = sum(handles.vmodes(:,:,handles.multimode),3);
        %         handles.vRec = sum(handles.vmodes(:,:,handles.multimode(1):handles.multimode(2)),3);

    else
        [handles.uRec,handles.vRec] = poduv(handles,4);
    end
    handles.current = 1;
    guidata(handles.fig,handles);
    popupmenu_quantity_Callback(handles.fig, [], handles);
end

function edit_multimode_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function radiobutton_weights_Callback(hObject, eventdata, handles)

if get(handles.radiobutton_weights,'Value') == 0
    %     handles.uRec = sum(handles.umodes(:,:,handles.multimode(1):handles.multimode(2)),3);
    %     handles.vRec = sum(handles.vmodes(:,:,handles.multimode(1):handles.multimode(2)),3);
    handles.uRec = sum(handles.umodes(:,:,handles.multimode),3);
    handles.vRec = sum(handles.vmodes(:,:,handles.multimode),3);
else
    [handles.uRec,handles.vRec] = poduv(handles,4);
end
guidata(handles.fig,handles);
popupmenu_quantity_Callback(handles.fig, [], handles);



function edit_numfields_Callback(hObject, eventdata, handles)
guidata(handles.fig,handles);

function checkbox_DirectSnapshot_Callback(hObject, eventdata, handles)
guidata(handles.fig,handles);


% --------------------------------------------------------------------
function export2csv_Callback(hObject, eventdata, handles)
% hObject    handle to export2csv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% LEARN MATLAB TRICKS: VECTORIZE YOUR LOOPS :-)
% in addition, it was some mismatch between ind and
% the size of matr.
% Alex, 05.10.2005

% ind=1;
%          for x_val=1:length(handles.x);
%              for y_val=1:length(handles.y);
%                  matr(ind,1)=x_val;
%                  matr(ind,2)=y_val;
%                  ind=ind+1;
%              end;
%          end;

matr = zeros(length(handles.x(:)),5);
matr(:,1) = handles.x(:);
matr(:,2) = handles.y(:);

if get(handles.checkbox_modes,'Value') == 1 % in case of single mode
    matr(:,3) = reshape(handles.umodes(:,:,handles.current),[],1);
    matr(:,4) = reshape(handles.vmodes(:,:,handles.current),[],1);
else % in case of multimode or reconstruction
    matr(:,3) = reshape(handles.uRec,[],1);
    matr(:,4) = reshape(handles.vRec,[],1);
end;

if (get(handles.popupmenu_quantity,'Value') > 1 | handles.color == 1) %save quantity if needed
    matr(:,5) = reshape(handles.property,[],1);
else
    matr = matr(:,1:4);
end

clear file
file = inputdlg('File Name','Input Name for CSV File');
if ~isempty(file)
    csvwrite(file{1},matr);
else
    warndlg('Choose a valid file name !!! ','Error','modal');
end;




% --- Executes on button press in SaveCVSEnergy.
function SaveCVSEnergy_Callback(hObject, eventdata, handles)
matr(:,1) = 1:length(handles.Energy);
matr(:,2) = handles.Energy;
clear file
file = inputdlg('File Name','Input Name for CSV File');
if ~isempty(file)
    csvwrite(file{1},matr);
else
    warndlg('Choose a valid file name !!! ','Error','modal');
end;


% hObject    handle to SaveCVSEnergy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox_loglog.
function checkbox_loglog_Callback(hObject, eventdata, handles)
axes(handles.axes_main);
delete(get(handles.axes_main,'children'));
if get(handles.checkbox_loglog,'Value') == 1
    loglog(1:length(handles.Erel),handles.Erel*100);
    grid on;
else
    plot(1:length(handles.Erel),handles.Erel*100);
end;
set(get(handles.axes_main,'xlabel'),'string','Number of modes')
set(get(handles.axes_main,'ylabel'),'string','Cummulative relative energy, %')
% hObject    handle to checkbox_loglog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_loglog





function edit_SelectedModes_Callback(hObject, eventdata, handles)
% hObject    handle to edit_SelectedModes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_SelectedModes as text
%        str2double(get(hObject,'String')) returns contents of edit_SelectedModes as a double

try
    handles.SelectedModes =  sort(eval(['[',get(handles.edit_SelectedModes,'String'),']',]));
catch
    warndlg('Wrong input: e.g. 1,3,5 or 1:2:5 or 1:5','Error','modal');
end

if min(size(handles.SelectedModes)) ~= 1 | ~isempty(findstr(get(handles.edit_SelectedModes,'String'),'.'))% | max(size(handles.SelectedModes)) ~= 2
    warndlg('Wrong input: e.g. 1,3,5 or 1:2:5 or 1:5','Error','modal');
elseif ( handles.SelectedModes(1) < 1 | max(handles.SelectedModes) > handles.numOfModes)
    warndlg('Input must be in the range of 1:number of modes','Error','modal');
else
    [handles.uRec, handles.vRec] = poduv(handles,3);
    % handles.current = 1;
    % handles.property    =   [];
    % handles.C           =   [];
    % handles.CH          =   [];
    guidata(handles.fig,handles);
    popupmenu_quantity_Callback(handles.fig, [], handles);
    % update_gui(handles.fig,[],handles);
end



% --- Executes during object creation, after setting all properties.
function edit_SelectedModes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_SelectedModes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


