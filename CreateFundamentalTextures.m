% Create five fundamental textures to define the map tiles
pkg load statistics
rand("seed",230987865); % make reproducable
% set base colors of fundamental textures
c1 = [0.141,0.216,0.239]; % deep water
c2 = 1.3*[0.170,0.283,0.350]; % shallow water
c3 = [0.400,0.204,0.184]; % ground
c4 = 0.9*[0.275,0.439,0.082]; % gras
c5 = [0.377,0.306,0.262]; % path/dirt

clrs = {c1,c2,c3,c4,c5};
bhighlight = [1,1,0,0,0];
nSpots = 5;
aNoise = [0.05,0.03,0.1,0.2,0.1];

ptrns = cell([]);
for iColor = 1:length(clrs)
  ptrn_w = ones(32,32,3);
  ptrn(:,:,1) = ptrn_w(:,:,1)*clrs{iColor}(1);
  ptrn(:,:,2) = ptrn_w(:,:,2)*clrs{iColor}(2);
  ptrn(:,:,3) = ptrn_w(:,:,3)*clrs{iColor}(3);

  rPattern = aNoise(iColor)*randn(32,32,3)+1.0;
  rPattern(rPattern<0.0) = 0.0;
  ptrn_hsv = rgb2hsv(ptrn);
  ptrn_hsv = ptrn_hsv.*rPattern;
  ptrn_rgb = hsv2rgb(ptrn_hsv);
  [A,B,C] = arrayfun(@redistribute_rgb,double(ptrn_rgb(:,:,1)),double(ptrn_rgb(:,:,2)),double(ptrn_rgb(:,:,3)));
  ptrn_rgb(:,:,1) = A*255;
  ptrn_rgb(:,:,2) = B*255;
  ptrn_rgb(:,:,3) = C*255;
  ptrn_rgb = uint8(ptrn_rgb);

  % reduce color space
  ncolors = 4;
  [idx, centers, sumd, dist] = kmeans(reshape(rgb2hsv(ptrn_rgb),[32*32,3]),ncolors);
  ptrn_ind = reshape(idx,[32,32]);
  % note that centers are in hsv, so we need to double convert back to rpg
  ptrn_re = ind2rgb(ptrn_ind,centers);
  ptrn_re = hsv2rgb(ptrn_re);
  if bhighlight(iColor)
    cspots = randi(32,2,nSpots);
    for iSpot = 1:nSpots
      ptrn_re(cspots(1,iSpot),cspots(2,iSpot),:) = 1.3*ptrn_re(cspots(1,iSpot),cspots(2,iSpot),:);
    end
    ptrn_re(ptrn_re > 1.0) = 1.0;
  end
  figure;image(ptrn_re);
  ptrns{iColor} = ptrn_re;
  imwrite(uint8(ptrn_re*255.0),['Ptrn',num2str(iColor),'.png']);
end
