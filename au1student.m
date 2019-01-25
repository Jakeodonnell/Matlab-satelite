function au1student(action)
%   This program makes a simple simulation of the
%   docking of two satelites. The program
%   opens a Matlab figure object, defines various
%   buttons and text frames in the figure.
%
%   The satelite motion is animated by repeatedly
%   redrawing a graph, where the satelite positions
%   are illustrated by marker points.

%   Johan Helgesson, Malm? University, August 2005

% Variables:
%   docked     Keeps track of if the satelites are docked or not
%   play       Keeps track of if the simulation is on or off
global docked
play= 1;

% At start up the program is called without any arguments (nargin<1)
if nargin<1,
    action='initialize';
end

switch action

% ===============================================================    
% ===============================================================    
    case 'initialize'

% ------------------------------------------------------------        
% Define figure and graph

        figNumber=figure( ...
            'Name','Satelite docking', ...
            'NumberTitle','off', ...
            'Units','centimeters',...
            'Position',[5.0 7.0 20.0 10.0],...
            'Visible','off');
        colordef(figNumber,'black')
        axes( ...
            'Units','normalized', ...
            'Position',[0.05 0.10 0.75 0.75], ...
            'Visible','off');

        text(0,0,'Press the "Start" button to start the satelite docking', ...
            'HorizontalAlignment','center');
        axis([-1 1 -1 1]);

% ------------------------------------------------------------        
% Define buttons
      
        %.....................................................
        % Information for all buttons
        xPos=0.85;              % x-position for all buttons
        btnLen=0.10;            % length of all buttons (in normalized units)
        btnWid=0.10;            % width of all buttons (in normalized units)
        spacing=0.05;           % spacing between buttons (in normalized units)

        %.....................................................
        % The CONSOLE frame (all buttons are placed in the console frame)
        frmBorder=0.02;
        yPos=0.05-frmBorder;
        frmPos=[xPos-frmBorder yPos btnLen+2*frmBorder 0.9+2*frmBorder];   % [x y length height]
        uicontrol( ...
            'Style','frame', ...
            'Units','normalized', ...
            'Position',frmPos, ...
            'BackgroundColor',[0.50 0.50 0.50]);

        %.....................................................
        % The START button
        % When the start button is pressed this porgram is called with the
        % input string variable 'start'
        %
        btnNumber=1;
        yPos=0.90-(btnNumber-1)*(btnWid+spacing);
        labelStr='Start';
        callbackStr='au1student(''start'');';

        % Generic button information
        btnPos=[xPos yPos-spacing btnLen btnWid];
        startHndl=uicontrol( ...
            'Style','pushbutton', ...
            'Units','normalized', ...
            'Position',btnPos, ...
            'String',labelStr, ...
            'Interruptible','on', ...
            'Callback',callbackStr);

        %.....................................................
        % The THRUST increase button
        % When this button is pressed the Userdata varaible of the
        % graph is changed to 2. In the main loop the Userdata variable
        % is checked, and if equal to 2, the force on sattelite 1 is
        % increased with 300 N.
        %
        btnNumber=2;
        yPos=0.90-(btnNumber-1)*(btnWid+spacing);
        labelStr='Thrust+';
        callbackStr='set(gca,''Userdata'',2)';

        % Generic  button information
        btnPos=[xPos yPos-spacing btnLen btnWid];
        thrustiHndl=uicontrol( ...
            'Style','pushbutton', ...
            'Units','normalized', ...
            'Position',btnPos, ...
            'Enable','off', ...
            'String',labelStr, ...
            'Callback',callbackStr);

        %.....................................................
        % The THRUST decrease button
        % When this button is pressed the Userdata varaible of the
        % graph is changed to 3. In the main loop the Userdata variable
        % is checked, and if equal to 3, the force on sattelite 1 is
        % decreased with 300 N.
        %
        btnNumber=3;
        yPos=0.90-(btnNumber-1)*(btnWid+spacing);
        labelStr='Thrust-';
        callbackStr='set(gca,''Userdata'',3)';

        % Generic  button information
        btnPos=[xPos yPos-spacing btnLen btnWid];
        thrustdHndl=uicontrol( ...
            'Style','pushbutton', ...
            'Units','normalized', ...
            'Position',btnPos, ...
            'Enable','off', ...
            'String',labelStr, ...
            'Callback',callbackStr);

        %.....................................................
        % The STOP button
        % Setting userdata to -1 (=stop) will stop the demo.
        btnNumber=4;
        yPos=0.90-(btnNumber-1)*(btnWid+spacing);
        labelStr='Stop';
        callbackStr='set(gca,''Userdata'',-1)';

        % Generic  button information
        btnPos=[xPos yPos-spacing btnLen btnWid];
        stopHndl=uicontrol( ...
            'Style','pushbutton', ...
            'Units','normalized', ...
            'Position',btnPos, ...
            'Enable','off', ...
            'String',labelStr, ...
            'Callback',callbackStr);

        %.....................................................
        % The CLOSE button (will close the figure)
        labelStr='Close';
        callbackStr='close(gcf)';
        closeHndl=uicontrol( ...
            'Style','push', ...
            'Units','normalized', ...
            'position',[xPos 0.05 btnLen 0.10], ...
            'string',labelStr, ...
            'call',callbackStr);

% ------------------------------------------------------------        
% Define text frames
%
        yPos=0.90;
        txtLen=0.20;
        txtWid=0.06;
        spacing=0.2;

        %.....................................................
        % Thrust; contains the present value of the force
        % acting on satelite 1.
        
        txtNumber=1;
        xPos=0.27 +(txtNumber-1)*(txtWid+spacing);
        labelStr='Thrust=300 N';  % Initial text

        % Generic text frame information
        txtPos=[xPos-spacing yPos txtLen txtWid];
        txt_th_Hndl=uicontrol( ...
            'Style','text', ...
            'Units','normalized', ...
            'Position',txtPos, ...
            'BackgroundColor',[1 1 1], ...
            'Fontsize',12,...
            'String',labelStr);

        %.....................................................
        % Velocity; contains the present value of the relative
        % velocity between the two satelites.
        
        txtNumber=2;
        xPos=0.27 +(txtNumber-1)*(txtWid+spacing);
        labelStr='v1x-v2x=0.00 m/s';    % Initial text

        % Generic button information
        txtPos=[xPos-spacing yPos txtLen txtWid];
        txt_vx_Hndl=uicontrol( ...
            'Style','text', ...
            'Units','normalized', ...
            'Position',txtPos, ...
            'BackgroundColor',[1 1 1], ...
            'Fontsize',12,...
            'String',labelStr);

        %.....................................................
        % Distance; contains the present value of the distance
        % between the two satelites.
        
        txtNumber=3;
        xPos=0.27 +(txtNumber-1)*(txtWid+spacing);
        labelStr='d=100 m';       % Initial text

        % Generic button information
        txtPos=[xPos-spacing yPos txtLen txtWid];
        txt_d_Hndl=uicontrol( ...
            'Style','text', ...
            'Units','normalized', ...
            'Position',txtPos, ...
            'BackgroundColor',[1 1 1], ...
            'Fontsize',12,...
            'String',labelStr);

        
% ------------------------------------------------------------        
        % Uncover the figure
        hndlList=[startHndl thrustiHndl thrustdHndl stopHndl closeHndl ...
                  txt_th_Hndl txt_vx_Hndl txt_d_Hndl];
        set(figNumber,'Visible','on', ...
            'UserData',hndlList);


% ===============================================================    
% Main routine for the simulation
% ===============================================================    
    case 'start'
        % get handles to figure objects
        axHndl=gca;
        figNumber=gcf;
        hndlList=get(figNumber,'UserData');
        startHndl=hndlList(1);
        thrustiHndl=hndlList(2);
        thrustdHndl=hndlList(3);
        stopHndl=hndlList(4);
        closeHndl=hndlList(5);
        txt_th_Hndl=hndlList(6);
        txt_vx_Hndl=hndlList(7);
        txt_d_Hndl=hndlList(8);
        set(startHndl,'Enable','off');
        set([thrustiHndl thrustdHndl stopHndl closeHndl],'Enable','on');

        % ~~~~~~~~~~~ Initial values  for Satelite docking ~~~~~
        X = zeros(3,2);
        X(1,1) = -100.0;
        X(1,2) = 0.0;
        V = zeros(3,2);
        F = zeros(3,2);
        F(1,1) = 300.0;
        M = zeros(2,2);
        M(1,1) = 500.0;
        M(2,2) = 1000.0;
        dt = 0.05;
        docked = 0;
        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
        % ~~~~~~~~~~~ Start of simulation ~~~~~
        set(figNumber,'Backingstore','off');
        set(axHndl, ...
            'XLim',[-110 50],'YLim',[-10 10],'ZLim',[-10 10], ...
            'XTick',[],'YTick',[],'ZTick',[], ...
            'Drawmode','fast', ...
            'Visible','on', ...
            'NextPlot','add', ...
            'Userdata',play, ...
            'View',[-37.5,30]);
        xlabel('X');
        ylabel('Y');
        zlabel('Z');

        SatFcn='update_sat_pos';
        cla;

        % ~~~~~~~~~~~ Satelite Marker ~~~~~
        sat1 = line( ...
            'color','w', ...
            'Marker','.', ...
            'markersize',30, ...
            'erase','xor', ...
            'xdata',X(1,1),'ydata',X(2,1),'zdata',X(3,1));

        sat2 = line( ...
            'color','y', ...
            'Marker','.', ...
            'markersize',30, ...
            'erase','xor', ...
            'xdata',X(1,2),'ydata',X(2,2),'zdata',X(3,2));

        % ~~~~~~~~~~~~~~~ The main loop ~~~~~~~~~~~~~~~~~~~~~
        % The main loop
        while (get(axHndl,'Userdata')>=play) && (X(1,1) < 100) ...
                && (X(1,2) < 100) && (X(1,1) > -120) && (X(1,2) > -120)

            % Update positions and velocities, as well as check satelite
            % docking
            [X V] = feval(SatFcn, X,V,F,M,dt);
            
            % Update the graph
            set(sat1,'xdata',X(1,1),'ydata',X(2,1),'zdata',X(3,1))
            set(sat2,'xdata',X(1,2),'ydata',X(2,2),'zdata',X(3,2))
            drawnow;

            % Update the text frames
            set(txt_th_Hndl,'String',['Thrust=' num2str(F(1,1),'% 6.0f') ' N' ]);
            set(txt_vx_Hndl,'String',['v1x-v2x=' num2str((V(1,1)-V(1,2)),'% 6.2f') ' m/s' ]);
            set(txt_d_Hndl,'String',['d=' num2str(X(1,2)-X(1,1),'% 6.0f') ' m' ]);

            if (docked == 1)
                text(-20,0,5,' Docked');   % Signal succesful docking
            end

            pause(0.20)  % To make the animation speed suitable  

            % Bail out if the figure was closed.
            if ~ishandle(axHndl)
                return
            end

            % Increase thrust if Thrust+ button was pushed
            if get(axHndl,'Userdata')==2  % Thrust increase
                F(1,1) = F(1,1) + 300.0;
                set(axHndl,'Userdata',1)
            end

            % Deacrese thrust if Thrust- button was pushed
            if get(axHndl,'Userdata')==3  % Thrust increase
                F(1,1) = F(1,1) - 300.0;
                set(axHndl,'Userdata',1)
            end

        end    % While; main loop ...

        set([startHndl closeHndl],'Enable','on');
        set([thrustiHndl thrustdHndl stopHndl],'Enable','off');

end    % case
% ===============================================================    
% ===============================================================    


%===============================================================================
function [XNEW VNEW] = update_sat_pos(X,V,F,M,dt)
global docked   % ==0: Satelites NOT docked,  ==1: Satelites docked
%
% Input variables:
%
%   X is a 3 row by 2 column matrix, containing 
%     the positions of the satelites
%      X(1,1):   x-pos. of sat. 1,    X(1,2):   x-pos. of sat. 2
%      X(2,1)=0: y-pos. of sat. 1,    X(2,2)=0: y-pos. of sat. 2
%      X(3,1)=0: z-pos. of sat. 1,    X(3,2)=0: z-pos. of sat. 2
%
%   V is a 3 row by 2 column matrix, containing 
%     the velocities of the satelites
%     V(1,1):   vx of sat. 1,    V(1,2):   vx of sat. 2
%     V(2,1)=0: vy of sat. 1,    V(2,2)=0: vy of sat. 2
%     V(3,1)=0: vz of sat. 1,    V(3,2)=0: vz of sat. 2
%
%   F is a 3 row by 2 column matrix, containing 
%     the forces (thrusts) acting on the satelites
%     F(1,1):   Fx on sat. 1,    F(1,2)=0: Fx on sat. 2
%     F(2,1)=0: Fy on sat. 1,    F(2,2)=0: Fy on sat. 2
%     F(3,1)=0: Fz on sat. 1,    F(3,2)=0: Fz on sat. 2
%
%   M is a 2 row by 2 column matrix, containing 
%     the masses of the satelites
%     M(1,1): mass of sat. 1,    M(2,1) = 0
%     M(1,2) = 0,                M(2,2): mass of sat. 2
%
%   dt is the time step
%
% The variables X and V contains the positions and velocities
% of the satelites at time t. This subroutine should calculate
% the new positions (XNEW) and new velocities (VNEW) at the
% time t+dt. XNEW and VNEW are matrices defined as X and V
% respectively.
%
% To obtain new positions, use for example Eq: 2-3 in Walker
% To obtain new velocitied, use for example Eqs: 2-5 and 5-1
% in Walker.
%
% If the centers of satelites come closer than 5 m, they may
% dock. They will dock if the difference in velocity between
% them is smaller than 2 m/s, otherwise they will bounce of
% each other, like two billiard balls. If the satelites
% dock, the process should be treated as an inelastic collision
% between the satelites (see for example Eq. 9-10 in Walker), 
% if they bounce off (do not dock) the preocess should be treated 
% as an elastic collision (see for example Eq. 9-12 in Walker).
% 
% Delete the two dummy lines below and put new code here
  VNEW = V;
  XNEW = X;
% TESTNING
% Velocity of sat1
% F=m*a -> a=F/m
% Vnew = V + dt * a -> Vnew = V + dt * (F/m)
  VNEW(1,1) = V(1,1) + dt*(F(1,1)/M(1,1))
% Position of sat1
% Xnew = X + V*dt
  XNEW(1,1) = X(1,1) + VNEW(1,1)*dt
  XNEW(1,2) = X(1,2) + VNEW(1,2)*dt
  if abs(XNEW(1,1) - XNEW(1,2)) < 5
      if abs(VNEW(1,1) - VNEW(1,2)) < 2
          docked = 1
          VNEW(1,2) = V(1,1) + dt*(F(1,1)/M(1,1))
      else
          %V2e = (2m1/m1+m2)*v1f
          VNEW(1,2)=(2*M(1,1)/(M(1,1)+M(2,2)))*V(1,1)
          %V1e = (m1-m2/m1+m2)*v1f
          VNEW(1,1)=((M(1,1)-M(2,2))/(M(1,1)+M(2,2)))*V(1,1)      
      end
  end
