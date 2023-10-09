% Fractal Brownian motion noise implemented by Chris Wellons:
% https://nullprogram.com/blog/2007/11/20/
function s = fbm (m, varargin)
  if (length(varargin) > 0)
    n = varargin{1};
  else
    n = m;
  end
  s = zeros(m,n);    % output image
  w = max(m,n);    % max width/height of current layer
  i = 0;           % iterations
  while w > 3
    i = i + 1;
    d = interp2(randn(w), i-1, "spline");
    s = s + i * d(1:m, 1:n);
    w -= ceil(w/2 - 1);
  end
end
% to rescale the output:
% s2 = (s-min(s(:)))/range(s(:));
