function nCase = MarchingSquaresCase(input)
% depending on the input we return the number of the case
nCase = 0;
vcase{1} = [0 0; 0 0];
vcase{2} = [0 0; 1 0];
vcase{3} = [0 0; 0 1];
vcase{4} = [0 0; 1 1];
vcase{5} = [0 1; 0 0];
vcase{6} = [0 1; 1 0];
vcase{7} = [0 1; 0 1];
vcase{8} = [0 1; 1 1];
vcase{9} = [1 0; 0 0];
vcase{10} = [1 0; 1 0];
vcase{11} = [1 0; 0 1];
vcase{12} = [1 0; 1 1];
vcase{13} = [1 1; 0 0];
vcase{14} = [1 1; 1 0];
vcase{15} = [1 1; 0 1];
vcase{16} = [1 1; 1 1];

function outp = allcmp(vin,iCase)
  cmpr = (vin == iCase);
  outp = all(cmpr(:));
end

cCase = cellfun(@(x) (allcmp(input,x)),vcase);
nCase = find(cCase);

end
