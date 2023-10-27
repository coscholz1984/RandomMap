function vTMix = CreateRoad(vT1,vT2,img,alpha)

tPath = '.\';

if (nargin < 2)
tT1 = 'Ptrn3.png'; % this will be the top texture (land)
tT2 = 'Ptrn2.png'; % this will be the bottom texture (shallow water)
vT1 = imread([tPath,tT1]);
vT2 = imread([tPath,tT2]);
alpha = 2.5; % this coefficient is the exponent that sharpens the gradient (higher means a sharper transition)
for iMap = 1:12
  Tc{iMap} = ['./IsleMaps/IsleMap-',num2str(iMap,'%01d'),'.png'];
end
img = mat2gray(imread([tPath, Tc{randi(12)}]));
end

if (nargin == 2)
  alpha = 2.5; % this coefficient is the exponent that sharpens the gradient (higher means a sharper transition)
  for iMap = 1:12
    Tc{iMap} = ['./IsleMaps/IsleMap-',num2str(iMap,'%01d'),'.png'];
  end
  img = mat2gray(imread([tPath, Tc{randi(12)}]));
end

if (nargin == 3)
  alpha = 2.5;
end

rPattern = rand(32,32);
%import fundamental textures
img = img(:,:,1)-0.5;
img = sign(img).*abs(img).^(1/alpha)+0.5;
bwindex = img<rPattern;
iindex = repmat(bwindex,[1,1,3]);
vTMix = vT1;
vTMix(iindex) = vT2(iindex);
% first we simulate a symmetric transition gradient (foam in the case of water/shadow for trees)
% set transition (foam) ToDo: make the number of pixels of the transition a variable (instead of hard coded 3)
% the xor between n-dilated and n-1 dilated image gives a perimeter line that can be colored as desired
foam1 = xor(bwindex,imdilate(bwindex,strel('disk',1,0)));
foam2 = xor(imdilate(bwindex,strel('disk',1,0)),imdilate(bwindex,strel('disk',2,0)));
foam3 = xor(imdilate(bwindex,strel('disk',2,0)),imdilate(bwindex,strel('disk',3,0)));
foam4 = xor(~bwindex,imdilate(~bwindex,strel('disk',1,0)));
foam5 = xor(imdilate(~bwindex,strel('disk',1,0)),imdilate(~bwindex,strel('disk',2,0)));
foam6 = xor(imdilate(~bwindex,strel('disk',2,0)),imdilate(~bwindex,strel('disk',3,0)));
vTMix = uint16(vTMix);
% for each perimeter line we increase the intensity by factors (2.0,1.6,1.2)
vTMix(repmat(foam1,[1,1,3])) = 0.8*vTMix(repmat(foam1,[1,1,3]));
vTMix(repmat(foam2,[1,1,3])) = 0.9*vTMix(repmat(foam2,[1,1,3]));
vTMix(repmat(foam3,[1,1,3])) = 0.98*vTMix(repmat(foam3,[1,1,3]));
vTMix(repmat(foam4,[1,1,3])) = 0.8*vTMix(repmat(foam4,[1,1,3]));
vTMix(repmat(foam5,[1,1,3])) = 0.9*vTMix(repmat(foam5,[1,1,3]));
vTMix(repmat(foam6,[1,1,3])) = 0.98*vTMix(repmat(foam6,[1,1,3]));
% rescale values if necessary
conversionfactor = 1/255.0;
[A,B,C] = arrayfun(@redistribute_rgb,double(vTMix(:,:,1))*conversionfactor,double(vTMix(:,:,2))*conversionfactor,double(vTMix(:,:,3))*conversionfactor);
vTMix(:,:,1) = uint8(A*255);
vTMix(:,:,2) = uint8(B*255);
vTMix(:,:,3) = uint8(C*255);
% underneath the top texture we create a shadow gradient
% create shadow map
border = xor(bwindex,imerode(bwindex,strel('disk',1,0)));
border2 = zeros(32,32);
border3 = zeros(32,32);
border4 = zeros(32,32);
border2(1:31,1:32) = border(2:32,1:32);
border3(1:30,1:32) = border(3:32,1:32);
border4(1:29,1:32) = border(4:32,1:32);
bwpositive = ~bwindex;
shadowmap = ones(32,32);
shadowmap(bwpositive & border2) = shadowmap(bwpositive & border2)-1.0;
shadowmap(bwpositive & border3) = shadowmap(bwpositive & border3)-0.4;
shadowmap(bwpositive & border4) = shadowmap(bwpositive & border4)-0.2;
shadowmap(shadowmap < 0.0) = 0.0;
% multiply texture with shadowmap
shadowmap = (shadowmap+0.6) / 1.6;
vTMix(:,:,1) = vTMix(:,:,1) .* shadowmap;
vTMix(:,:,2) = vTMix(:,:,2) .* shadowmap;
vTMix(:,:,3) = vTMix(:,:,3) .* shadowmap;
% render final image
vTMix = uint8(vTMix);

end

