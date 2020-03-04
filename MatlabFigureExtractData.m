function MatlabFigureExtractData(filename, ofnames)
% figstruct = MatlabFigureExtractData(filename,ofnames);
% input: filename to a MATLAB fig file.
% output: structure loaded from the Fig file
%   save data from 'graph2d.lineseries' in separate text files.
%
% by E.Sergeicheva, 2020-02-04
% inspired by OpenMatlabFigureInOctave.m from Peter Adamczyk
%
  figstruct = load(filename,'-mat');

  mainfield = fieldnames(figstruct); 
  figstruct = figstruct.(mainfield{1});

  for ii = 1:length(figstruct)
    for jj = 1:length(figstruct(ii).children)
        oftxtname = [ofnames "_" num2str(jj) "_labels"];
        oftxtid=fopen(oftxtname,"w");
        switch figstruct(ii).children(jj).type
        case {'axes', 'scribe.scribeaxes'}
            for kk = 1:length(figstruct(ii).children(jj).children)
                switch figstruct(ii).children(jj).children(kk).type
                    case 'graph2d.lineseries'
                        ofname = [ofnames "_" num2str(jj)  "_" num2str(kk) ".txt"];
                        ofid=fopen(ofname,"w");
                        ff = figstruct(ii).children(jj).children(kk).properties;
                        xx=ff.XData; yy=ff.YData;
                        fprintf(ofid,"%f %f\n",[xx',yy']');
                        fclose(ofid);
                    case 'graph3d.lineseries'
                    case 'specgraph.scattergroup'
                        continue
                    case 'specgraph.contourgroup'
                        continue
                    case 'graph3d.surfaceplot'
                    case 'patch'
                    case 'text'
                        kidind = find(figstruct(ii).children(jj).special == kk) ;
                        if isempty(kidind)
                            hkid(ii,jj,kk) = text(0, 0, 0, '');
                        else
                            labeln = "";
                            switch kidind
                                case 1
                                    labeln = "title";
                                case 2
                                    labeln = "xlabel";
                                case 3
                                    labeln = "ylabel";
                                case 4
                                    labeln = "zlabel";
                                otherwise
                                    continue;
                            end
                            leg = figstruct(ii).children(jj).children(kk).properties.String;
                            fprintf(oftxtid, "%s_txt='%s'\n", labeln, leg);
                        end

                        continue % Maybe don't set properties for the Xlabel, Ylabel, Zlabel, Title. They don't need it, and some of the properties mess things up. 
                end

            end % end loop over Axes children

        case 'scribe.legend'
            leg = figstruct(ii).children(jj).properties.UserData.lstrings;
            fprintf(oftxtid, "legend_txt='%s'\n", leg);
            otherwise % not Axes or Legend. 
            continue
        end
        fclose(oftxtid);
    end
  end
endfunction
