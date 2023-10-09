%pkg load image % needed for imdilate/imerode
%rand("seed",230987865);  % make noise reproducable

function vT = CreateMSCases(vT1,vT2,MSCaseList,alpha,type)

if (nargin <= 2) || strcmp(MSCaseList,'default')
  MSCaseList = {'.\MarchingSquares\Case00.png',
  '.\MarchingSquares\Case01.png',
  '.\MarchingSquares\Case02.png',
  '.\MarchingSquares\Case03.png',
  '.\MarchingSquares\Case04.png',
  '.\MarchingSquares\Case05a.png',
  '.\MarchingSquares\Case06.png',
  '.\MarchingSquares\Case07.png',
  '.\MarchingSquares\Case08.png',
  '.\MarchingSquares\Case09.png',
  '.\MarchingSquares\Case10a.png',
  '.\MarchingSquares\Case11.png',
  '.\MarchingSquares\Case12.png',
  '.\MarchingSquares\Case13.png',
  '.\MarchingSquares\Case14.png',
  '.\MarchingSquares\Case15.png',
  '.\MarchingSquares\Case05b.png',
  '.\MarchingSquares\Case10b.png'};
end

if (nargin < 2)
  alpha = 3; % this coefficient is the exponent that sharpens the gradient (higher means a sharper transition)
  tPath2 = '.\';
  tT1 = 'Ptrn3.png'; % this will be the top texture (land)
  tT2 = 'Ptrn2.png'; % this will be the bottom texture (shallow water)
  type = 1;
  vT1 = imread([tPath2,tT1]);
  vT2 = imread([tPath2,tT2]);
end

if (nargin == 2)
  alpha = 3; % this coefficient is the exponent that sharpens the gradient (higher means a sharper transition)
end

if (nargin == 3)
  alpha = 3;
  type = 1;
end
if (nargin == 4)
  type = 1;
end

rPattern = rand(32,32);
vT = cell([]);

if (type == 1) % transition from water to land
  for iEdge = 1:length(MSCaseList)
    img = mat2gray(imread(MSCaseList{iEdge}));
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
    vTMix(repmat(foam1,[1,1,3])) = 2.0*vTMix(repmat(foam1,[1,1,3]));
    vTMix(repmat(foam2,[1,1,3])) = 1.6*vTMix(repmat(foam2,[1,1,3]));
    vTMix(repmat(foam3,[1,1,3])) = 1.2*vTMix(repmat(foam3,[1,1,3]));
    vTMix(repmat(foam4,[1,1,3])) = 2.0*vTMix(repmat(foam4,[1,1,3]));
    vTMix(repmat(foam5,[1,1,3])) = 1.6*vTMix(repmat(foam5,[1,1,3]));
    vTMix(repmat(foam6,[1,1,3])) = 1.2*vTMix(repmat(foam6,[1,1,3]));
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
    border5 = zeros(32,32);
    border2(1:31,1:32) = border(2:32,1:32);
    border3(1:30,1:32) = border(3:32,1:32);
    border4(1:29,1:32) = border(4:32,1:32);
    border5(1:28,1:32) = border(5:32,1:32);
    bwpositive = ~bwindex;
    shadowmap = ones(32,32);
    shadowmap(bwpositive & border2) = shadowmap(bwpositive & border2)-1.0;
    shadowmap(bwpositive & border3) = shadowmap(bwpositive & border3)-0.8;
    shadowmap(bwpositive & border4) = shadowmap(bwpositive & border4)-0.7;
    shadowmap(bwpositive & border5) = shadowmap(bwpositive & border5)-0.6;
    shadowmap(shadowmap < 0.0) = 0.0;
    % at the top of the top texture we create a light gradient
    % create light map
    border = xor(bwindex,imerode(bwindex,strel('disk',1,0)));
    border2 = zeros(32,32);
    border3 = zeros(32,32);
    border4 = zeros(32,32);
    border5 = zeros(32,32);
    border2(2:32,1:32) = border(1:31,1:32);
    border3(3:32,1:32) = border(1:30,1:32);
    border4(4:32,1:32) = border(1:29,1:32);
    border5(5:32,1:32) = border(1:28,1:32);
    bwpositive = ~bwindex;
    lightmap = ones(32,32);
    lightmap(bwpositive & border2) = lightmap(bwpositive & border2)+0.1*0.5;
    lightmap(bwpositive & border3) = lightmap(bwpositive & border3)+0.05*0.5;
    lightmap(bwpositive & border4) = lightmap(bwpositive & border4)+0.025*0.5;
    lightmap(bwpositive & border5) = lightmap(bwpositive & border5)+0.01*0.5;
    % multiply texture with shadowmap
    shadowmap = (shadowmap+1.0) / 2.0;
    vTMix(:,:,1) = vTMix(:,:,1) .* shadowmap .* lightmap;
    vTMix(:,:,2) = vTMix(:,:,2) .* shadowmap .* lightmap;
    vTMix(:,:,3) = vTMix(:,:,3) .* shadowmap .* lightmap;
    % render final image
    [A,B,C] = arrayfun(@redistribute_rgb,double(vTMix(:,:,1))*conversionfactor,double(vTMix(:,:,2))*conversionfactor,double(vTMix(:,:,3))*conversionfactor);
    vTMix(:,:,1) = uint8(A*255);
    vTMix(:,:,2) = uint8(B*255);
    vTMix(:,:,3) = uint8(C*255);
    vT{iEdge} = uint8(vTMix);
    % imwrite(vTMix,[tPath,strrep(Tc{iEdge},'.png','-out.png')]);
  end
end

if (type == 0) % transition from deep to shallow water
  for iEdge = 1:length(MSCaseList)
    img = mat2gray(imread(MSCaseList{iEdge}));
    img = img(:,:,1)-0.5;
    img = sign(img).*abs(img).^(1/alpha)+0.5;
    bwindex = img<rPattern;
    iindex = repmat(bwindex,[1,1,3]);
    vTMix = vT1;
    vTMix(iindex) = vT2(iindex);
    % set transition (blend one line of pixels together) ToDo: make the number of pixels of the transition a variable (instead of hard coded 3)
    transline1 = xor(bwindex,imdilate(bwindex,strel('disk',1,0)));
    transline_all = transline1;
    vTMix = uint16(vTMix);
    vTMix(repmat(transline_all,[1,1,3])) = .5*(vT1(repmat(transline_all,[1,1,3]))+vT2(repmat(transline_all,[1,1,3])));
    % rescale values if necessary
    [A,B,C] = arrayfun(@redistribute_rgb,double(vTMix(:,:,1))*0.00392,double(vTMix(:,:,2))*0.00392,double(vTMix(:,:,3))*0.00392);
    vTMix(:,:,1) = uint8(A*255);
    vTMix(:,:,2) = uint8(B*255);
    vTMix(:,:,3) = uint8(C*255);
    vTMix = uint8(vTMix);
    vT{iEdge} = uint8(vTMix);
  end
end

if (type == 2)
  for iEdge = 1:length(MSCaseList)
  img = mat2gray(imread(MSCaseList{iEdge}));
  if length(unique(img(:))) == 1
    img = imread(MSCaseList{iEdge});
    img = im2uint8(img);
    img = double(mat2gray(img))*double(img(1))/255.0;
  end
  img = img(:,:,1)-0.5;
	img = sign(img).*abs(img).^(1/alpha)+0.5;
	bwindex = img<rPattern;
	iindex = repmat(bwindex,[1,1,3]);
	vTMix = vT1;
	vTMix(iindex) = vT2(iindex);
	% set transition (foam) ToDo: make the number of pixels of the transition a variable (instead of hard coded 3)
	foam1 = xor(bwindex,imdilate(bwindex,strel('disk',1,0)));
	foam_all = foam1;
	vTMix = uint16(vTMix);
	vTMix(repmat(foam_all,[1,1,3])) = .5*(vT1(repmat(foam_all,[1,1,3]))+vT2(repmat(foam_all,[1,1,3])));
	%vTMix(repmat(foam4,[1,1,3])) = .5*(vT1(repmat(foam4,[1,1,3]))+vT2(repmat(foam4,[1,1,3])));
	% rescale values if necessary
	[A,B,C] = arrayfun(@redistribute_rgb,double(vTMix(:,:,1))*0.00392,double(vTMix(:,:,2))*0.00392,double(vTMix(:,:,3))*0.00392);
	vTMix(:,:,1) = uint8(A*255);
	vTMix(:,:,2) = uint8(B*255);
	vTMix(:,:,3) = uint8(C*255);
	vTMix = uint8(vTMix);
	vT{iEdge} = uint8(vTMix);
end
end

