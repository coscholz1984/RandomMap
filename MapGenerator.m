pkg load image
rand("seed",1);
randn("seed",6);
imBW = im2bw(mat2gray(imsmooth(fbm(151,11),1.5)),0.5);

for iY = 1:(size(imBW,1)-6)
  if length(unique(imBW(iY:(iY+6),:))) == 1
    disp("Found patch without variation");
    % Adding islands or lakes
    isles = randi(30,size(imBW(iY:(iY+6),:),1),size(imBW(iY:(iY+6),:),2))<2;
    for iA = 1:size(isles,1)
      for iB = 1:size(isles,2)
        if (isles(iA,iB) == 1)
          if (randi(4,1)<2)
            isles(max(iA-1,1),iB) = 1;
          end
          if (randi(4,1)<2)
            isles(min(iA+1,size(isles,1)),iB) = 1;
          end
          if (randi(4,1)<2)
            isles(iA,max(iB-1,1)) = 1;
          end
          if (randi(4,1)<2)
            isles(iA,min(iB+1,size(isles,2))) = 1;
          end
        end
      end
    end
    imBW(iY:(iY+6),:) = xor(imBW(iY:(iY+6),:),isles);
  end
end

[vHut,vMap,vAlpha] = imread('./Assets/Hut2.png');

%figure;imagesc(imBW);axis image;

% generate high ground
imBW2 = imerode(imBW,strel('disk',3,0))*2;

% generate deep sea
imBW3 = imerode(~imBW,strel('disk',3,0))*(-1);

imBW = int8(imBW);
imBW(imBW2(:) == 2) = imBW2(imBW2(:) == 2);
imBW(imBW3(:) == -1) = imBW3(imBW3(:) == -1);
imBW = imBW + 1;

%imBW2(imBW(:)) = 1.0;

figure;imagesc(imBW);axis image;

% generate trial map:
%imBW_ = imBW>=2;
%map = nlfilter(im2bw(imBW_),[2,2],@(x) MarchingSquaresCase(x));

imBW1_ = imBW>=1;
imBW2_ = imBW>=2;
imBW3_ = imBW>=3;
map1_ = nlfilter(im2bw(imBW1_),[2,2],@(x) MarchingSquaresCase(x));
map2_ = nlfilter(im2bw(imBW2_),[2,2],@(x) MarchingSquaresCase(x));
map3_ = nlfilter(im2bw(imBW3_),[2,2],@(x) MarchingSquaresCase(x));
% discard last columns
map1_ = map1_(1:end-1,1:end-1);
map2_ = map2_(1:end-1,1:end-1);
map3_ = map3_(1:end-1,1:end-1);

% ToDo:

% Add a path map, this needs some more complex texture merging

% generate map
% create MS cases:
tPath = '.\';
vTWater = CreateMSCases(imread([tPath,'Ptrn2.png']),imread([tPath,'Ptrn1.png']),'default',1.75,0); % transitions from deep to shallow water
vTLand = CreateMSCases(); % transitions from shallow water to land
vTGras = CreateMSCases(imread([tPath,'Ptrn4.png']),imread([tPath,'Ptrn3.png']),'default',1.5,2); % transitions from land to gras
map_image = uint8(ones([(size(map1_))*32 3]));
map_image_land = uint8(ones([(size(map2_))*32 3]));
map_image_water = uint8(ones([(size(map1_))*32 3]));
map_image_gras = uint8(ones([(size(map3_))*32 3]));
for iH = 0:(size(map1_,2)-1)
  for iW = 0:(size(map1_,1)-1)
##    iMap = map(iW+1,iH+1);
##    % in degenerate case 5 pick randomly 5 or 17

    iMap1 = map1_(iW+1,iH+1);
    iMap2 = map2_(iW+1,iH+1);
    iMap3 = map3_(iW+1,iH+1);
    iMap1 = ShuffleDegenerateCase(iMap1);
    iMap2 = ShuffleDegenerateCase(iMap2);
    iMap3 = ShuffleDegenerateCase(iMap3);
    if (iMap2 == 1) && (rand < 0.05)
      map_image(iW*32+1:(iW+1)*32,iH*32+1:(iH+1)*32,:) = CreateIsle;
    elseif (iMap2 == 16) && (rand < 0.05)
        map_image(iW*32+1:(iW+1)*32,iH*32+1:(iH+1)*32,:) = CreateTrees(imread('.\Ptrn4.png'),vTLand{iMap2});
      else
        map_image(iW*32+1:(iW+1)*32,iH*32+1:(iH+1)*32,:) = vTLand{iMap2};
    end
    %map_image(iW*32+1:(iW+1)*32,iH*32+1:(iH+1)*32,:) = vTLand{iMap2};%;map(iW+1,iH+1)*ones(32,32);
    if (map1_(iW+1,iH+1) < 16)
      if (iMap1 == 1) && (rand < 0.05)
        map_image(iW*32+1:(iW+1)*32,iH*32+1:(iH+1)*32,:) = CreateIsle(imread('.\Ptrn3.png'),imread('.\Ptrn1.png'));
      else
        map_image(iW*32+1:(iW+1)*32,iH*32+1:(iH+1)*32,:) = vTWater{iMap1};%;map(iW+1,iH+1)*ones(32,32);
      end
    end
    if map3_(iW+1,iH+1) > 1
      if (iMap3 == 16) && (rand < 0.05)
        map_image(iW*32+1:(iW+1)*32,iH*32+1:(iH+1)*32,:) = CreateTrees(imread('.\Ptrn4.png'),vTGras{iMap3});
      elseif (rand < 0.01)
        % add a hut to the land
        vMerged = MergeOverlayBackgroundTexture(vTGras{iMap3}, vHut, vAlpha);
        map_image(iW*32+1:(iW+1)*32,iH*32+1:(iH+1)*32,:) = vMerged;
      else
        map_image(iW*32+1:(iW+1)*32,iH*32+1:(iH+1)*32,:) = vTGras{iMap3};%;map(iW+1,iH+1)*ones(32,32);
      end
    end
    %map_image_land(iW*32+1:(iW+1)*32,iH*32+1:(iH+1)*32,:) = vTLand{iMap2};%;map(iW+1,iH+1)*ones(32,32);
    %map_image_water(iW*32+1:(iW+1)*32,iH*32+1:(iH+1)*32,:) = vTWater{iMap1};%;map(iW+1,iH+1)*ones(32,32);
    %map_image_gras(iW*32+1:(iW+1)*32,iH*32+1:(iH+1)*32,:) = vTGras{iMap3};%;map(iW+1,iH+1)*ones(32,32);
  end
end

% add a road to the map if possible
rIndex = [];
for iW = 0:2:(size(map2_,1)-2)
  if unique(map2_((iW+1):(iW+2),:)) == 16
    rIndex = [rIndex, iW];
  end
end
if ~isempty(rIndex)
  % add a road
  for iRd = rIndex
    if (rand < 0.3)
      for iH = 0:(size(map2_,2)-1)
        map_image(iRd*32+1:(iRd+1)*32,iH*32+1:(iH+1)*32,:) = CreateRoad(imread('.\Ptrn5.png'),map_image(iRd*32+1:(iRd+1)*32,iH*32+1:(iH+1)*32,:),mat2gray(imread('.\MarchingSquares\Case03.png')));
        map_image((iRd+1)*32+1:(iRd+1+1)*32,iH*32+1:(iH+1)*32,:) = CreateRoad(imread('.\Ptrn5.png'),map_image((iRd+1)*32+1:(iRd+1+1)*32,iH*32+1:(iH+1)*32,:),mat2gray(imread('.\MarchingSquares\Case12.png')));
      end
    end
  end
end

%figure;image(map_image_land); axis image;
%figure;image(map_image_water); axis image;
%figure;image(map_image_gras); axis image;
figure;image(map_image); axis image;
%imwrite(map_image,'tilemap.png');

