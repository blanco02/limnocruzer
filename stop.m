function stop()
global c;


if(isempty(c))%if c doesn't exit, just exit.
    return;
end

%check that these objects were actually created before trying to cleanup
if(isfield(c,'sonde') && ~isempty(c.sonde))
    c.sonde.delete();
end
if(isfield(c,'gps') && ~isempty(c.gps))
    c.gps.delete();
end

if(isfield(c,'outfile') && ~isempty(c.outfile))
    fclose(c.outfile);
end

close all;
clear global p;
clear global c;

end