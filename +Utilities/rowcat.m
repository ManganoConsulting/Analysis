function y = rowcat( a , b )
% Concatenate two vectors into a row vector regardless of whether the input
% is a column or a row vector.  Input must be a vector.
% % if ~isvector(a) || ~isvector(b)
% %     error('Inputs must have dimensions 1xN or Nx1');
% % end
% % if ~strcmp(class(a),class(b))
% %     error('Both inputs must be of the same class');
% % end

if ~isrow(a);a=a';end
if ~isrow(b);b=b';end

y = [a,b];
end