% function to hue preserving redistribute rgb values
function [rr,rg,rb] = redistribute_rgb(r,g,b)
	m = max([r,g,b]);
	if m <= 1.0
		rr=r; rg=g; rb=b;
    return
	end
	total = r+g+b;
	if total >= 3.0
		rr = 1.0;rg=1.0;rb=1.0;
    return
	end
	x = (3.0 - total) / (3*m - total);
	gray = 1.0 - x*m;
	rr = gray + x*r; rg = gray + x*g; rb= gray + x*b;
end
