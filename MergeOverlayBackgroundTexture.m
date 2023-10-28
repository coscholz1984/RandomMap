% merge textures based on alpha channel
%vBackgroundTexture = imread('Ptrn1.png');
%[vOverlay,vMap,vAlpha] = imread('ChemicalPlant.png');
% repeat background texture to fit size of vOverlay
%if size(vBackgroundTexture,1) ~= size(vBackgroundTexture,2)
%  error('Background texture needs to be quadratic.');
%end
%[nA,nB,~] = size(vOverlay);
%nP = size(vBackgroundTexture,1);
%nA = nA/nP;
%nB = nB/nP;
%if (rem(nA,1) ~= 0) | (rem(nB,1) ~= 0)
%  error('overlay texture needs to be multiples of background texture.');
%end
function vMerged = MergeOverlayBackgroundTexture(vBackground, vOverlay, vAlpha)
%vBackground = repmat(vBackgroundTexture,[nA,nB]);
vMerged = im2double(vBackground);
vOverlay = im2double(vOverlay);
vAlpha = im2double(vAlpha);
vBackground = im2double(vBackground);
vMerged(:,:,1) = vAlpha .* vOverlay(:,:,1) + (1-vAlpha) .* vBackground(:,:,1);
vMerged(:,:,2) = vAlpha .* vOverlay(:,:,2) + (1-vAlpha) .* vBackground(:,:,2);
vMerged(:,:,3) = vAlpha .* vOverlay(:,:,3) + (1-vAlpha) .* vBackground(:,:,3);
vMerged = uint8(vMerged*255);
%figure; image(uint8(vMerged*255));
