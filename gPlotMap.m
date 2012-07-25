function gPlotMap(fileName,type,vars)
    d = loadLSdata(fileName);

    
    indx = cell(length(vars),1);
    for i = 1:length(vars);
        indx{i} = find(strcmpi(d.header,vars{i}));
    end
    indx = unique([indx{:}]);
    
    
    if(isempty(indx))
        error('Var didn''t match available variable listed in header');
    end
    
    if(strcmpi(type,'1d'))
        plot(d.dist,d.data(:,indx));
        legend(d.header(indx));
    elseif(strcmpi(type,'2d'))
        
        
        
    else
        error('Unrecognised type. Must specify type as ''1d'' or ''2d''');
    end
        


end