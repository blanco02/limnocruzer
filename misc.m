%% Experimentation

cm = serial('com5','BaudRate',19200,'RequestToSend','on','DataTerminalReady','on');
fopen(cm);
set(cm,'RequestToSend','on','DataTerminalReady','on');

%%
fprintf(cm,'%s',[char(1)])
fprintf(cm,'%s',['d'])
%fprintf(cm,'%s',[char(0) char(10)])


fprintf(cm,'%s',[char(0) char(10) char(192)]);


%%
fprintf(cm,'%s',[char(1) 'd' char(0) char(10) char(192)])




%% 
fwrite(cm,[char(0) '@' char(0) '@' char(0)],'char');


%% Screw that let's play around with TTY mode
cm = serial('com5','BaudRate',19200,'RequestToSend','off','DataTerminalReady','off');
fopen(cm);

dLine = fscanf(cm);



