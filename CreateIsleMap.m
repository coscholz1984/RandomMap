% in this script we pick random points and then create a decreasing whitness gradient around these points
% this can be used to create spots or "isles" of one texture within another
bSeed = false; % fix seed or use random one
nMaps = 12; % number of maps to generate
if bSeed
  rand("seed",902834);
end
pkg load image % need this for imdilate
for iMap = 1:nMaps
  rPattern = zeros(32,32);
  nIsles = 25;
  r = 5;
  dPadding = 6;
  cspots = randi(32-2*(dPadding),2,nIsles)+(dPadding);
  % set random points to white
  for iSpot = 1:nIsles
    rPattern(cspots(1,iSpot),cspots(2,iSpot)) = 1;
  end
  rBound0 = rPattern;
  % dilate and add whiteness value, i.e. create gradient around the spots
  for iExt = 1:r
      rBound = imdilate(rBound0,strel('disk',iExt,0));
      rPattern = rPattern + (r/iExt+1)*rBound;
  end
  %figure; imagesc(rPattern);
  imwrite(mat2gray(rPattern),['./IsleMaps/IsleMap-',num2str(iMap),'.png']);
end
