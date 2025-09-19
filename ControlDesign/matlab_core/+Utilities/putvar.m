function putvar(varargin)
% Assigns variables from the current workspace down into the base MATLAB workspace


if nargin < 1
  % no variables requested for the assignment,
  % so this is a no-op
  return
end

% how many variables do we need to assign?
nvar = numel(varargin);

% get the list of variable names in the caller workspace.
% callervars will be a cell array that lists the names of all
% variables in the caller workspace.
callervars = evalin('caller','who');

% likewise, basevars is a list of the names of all variables
% in the base workspace.
basevars = evalin('base','who');

% loop over the variables supplied
for i = 1:nvar
  % what was this variable called in the caller workspace?
  varname = inputname(i);
  vari = varargin{i};
  
  if ~isempty(varname)
    % We have a variable name, so assign this variable
    % into the base workspace
    
    % First though, check to see if the variable is
    % already there. If it is, we will need to set
    % a warning.
    if ismember(varname,basevars)
      warning('PUTVAR:overwrite', ...
        ['Input variable #',num2str(i),' (',varname,')', ...
        ' already exists in the base workspace. It will be overwritten.'])
    end
    
    % do the assign into the indicated name
    assignin('base',varname,varargin{i})
    
  elseif ischar(vari) && ismember(vari,callervars)
    % the i'th variable was a character string, that names
    % a variable in the caller workspace. We can assign
    % this variable into the base workspace.
    
    % First though, check to see if the variable is
    % already there. If it is, we will need to set
    % a warning.
    varname = vari;
    if ismember(varname,basevars)
      warning('PUTVAR:overwrite', ...
        ['Input variable #',num2str(i),' (',varname,')', ...
        ' already exists in the base workspace. It will be overwritten.'])
    end
    
    % extract the indicated variable contents from
    % the caller workspace.
    vari = evalin('caller',varname);
    
    % do the assign into the indicated name
    assignin('base',varname,vari)
    
  else
    % we cannot resolve this variable
    warning('PUTVAR:novariable', ...
      ['Did not assign input variable #',num2str(i), ...
      ' as no caller workspace variable was available for that input.'])
    
  end
  
end


