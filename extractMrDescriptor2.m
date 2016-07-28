function [finalPos, descriptorMr] = extractMrDescriptor2(nLayers, blockSize, targetImage, positions)

    if nLayers==-3
        maxResolutionBlockSize=blockSize*2^(5);
    else
        maxResolutionBlockSize=blockSize*2^(nLayers);
    end

    nullDescriptor=[];
    
    
    if (numel(size(targetImage))==2)
        descriptorMr=zeros(blockSize*blockSize*(nLayers+1),size(positions,2));
    elseif (numel(size(targetImage))==3)
        descriptorMr=zeros(blockSize*blockSize*(nLayers+1)*size(targetImage,3),size(positions,2));
    else
        return
    end
    
    for iDescriptor=1:size(positions,2)

	x=positions(1,iDescriptor)-(maxResolutionBlockSize-1)/2;
	y=positions(2,iDescriptor)-(maxResolutionBlockSize-1)/2;

    %try
        
        I2_L0 = imcrop(targetImage, [x,y,maxResolutionBlockSize-1,maxResolutionBlockSize-1]);
        %imshow(uint8(I2_L0));
        %pause();
        
        aux_size = size(I2_L0);
        aux_size = aux_size(1:2);
            if (all(aux_size==maxResolutionBlockSize))
        I2_L1 = impyramid(I2_L0, 'reduce');
        I2_L2 = impyramid(I2_L1, 'reduce');
        I2_L1 = imcrop(I2_L1, [(maxResolutionBlockSize/2-blockSize)/2+1,(maxResolutionBlockSize/2-blockSize)/2+1,blockSize-1,blockSize-1]);
        I2_L0 = imcrop(I2_L0, [(maxResolutionBlockSize-blockSize)/2+1,(maxResolutionBlockSize-blockSize)/2+1,blockSize-1,blockSize-1]);

              if nLayers==5
          I2_L3 = impyramid(I2_L2, 'reduce');
          I2_L4 = impyramid(I2_L3, 'reduce');
          I2_L5 = impyramid(I2_L4, 'reduce');
          I2_L4 = imcrop(I2_L4, [(maxResolutionBlockSize/16-blockSize)/2+1,(maxResolutionBlockSize/16-blockSize)/2+1,blockSize-1,blockSize-1]);
          I2_L3 = imcrop(I2_L3, [(maxResolutionBlockSize/8-blockSize)/2+1,(maxResolutionBlockSize/8-blockSize)/2+1,blockSize-1,blockSize-1]);
          I2_L2 = imcrop(I2_L2, [(maxResolutionBlockSize/4-blockSize)/2+1,(maxResolutionBlockSize/4-blockSize)/2+1,blockSize-1,blockSize-1]);
          descriptorMr(:,iDescriptor)=[I2_L0(:); I2_L1(:); I2_L2(:); I2_L3(:); I2_L4(:); I2_L5(:)];
              elseif nLayers==4
          I2_L3 = impyramid(I2_L2, 'reduce');
          I2_L4 = impyramid(I2_L3, 'reduce');
          I2_L3 = imcrop(I2_L3, [(maxResolutionBlockSize/8-blockSize)/2+1,(maxResolutionBlockSize/8-blockSize)/2+1,blockSize-1,blockSize-1]);
          I2_L2 = imcrop(I2_L2, [(maxResolutionBlockSize/4-blockSize)/2+1,(maxResolutionBlockSize/4-blockSize)/2+1,blockSize-1,blockSize-1]);
          descriptorMr(:,iDescriptor)=[I2_L0(:); I2_L1(:); I2_L2(:); I2_L3(:); I2_L4(:)];
              elseif nLayers==3
          I2_L3 = impyramid(I2_L2, 'reduce');
          I2_L2 = imcrop(I2_L2, [(maxResolutionBlockSize/4-blockSize)/2+1,(maxResolutionBlockSize/4-blockSize)/2+1,blockSize-1,blockSize-1]);
          descriptorMr(:,iDescriptor)=[I2_L0(:); I2_L1(:); I2_L2(:); I2_L3(:)];
              elseif nLayers==2
           descriptorMr(:,iDescriptor)=[I2_L0(:); I2_L1(:); I2_L2(:)];

               elseif nLayers==-3
                   I2_L3 = impyramid(I2_L2, 'reduce');
                   I2_L4 = impyramid(I2_L3, 'reduce');
                   I2_L5 = impyramid(I2_L4, 'reduce');
                   I2_L4 = imcrop(I2_L4, [(maxResolutionBlockSize/16-blockSize)/2+1,(maxResolutionBlockSize/16-blockSize)/2+1,blockSize-1,blockSize-1]);
                   I2_L3 = imcrop(I2_L3, [(maxResolutionBlockSize/8-blockSize)/2+1,(maxResolutionBlockSize/8-blockSize)/2+1,blockSize-1,blockSize-1]);
                   I2_L2 = imcrop(I2_L2, [(maxResolutionBlockSize/4-blockSize)/2+1,(maxResolutionBlockSize/4-blockSize)/2+1,blockSize-1,blockSize-1]);
                   descriptorMr(:,iDescriptor)=[I2_L2(:); I2_L3(:); I2_L4(:)];


                elseif nLayers==1
                    descriptorMr(:,iDescriptor)=[I2_L0(:); I2_L1(:)];
                elseif nLayers==0
                    descriptorMr(:,iDescriptor)=[I2_L0(:)];
                else
                    disp('Numero de layers no permitido (0-2)')
                return;
               end
        else
            %descriptorMr(:,iDescriptor)=0;
            nullDescriptor=[nullDescriptor iDescriptor];
            continue
        end
    end
    
    finalPos=positions;
    finalPos(:,nullDescriptor)=[];
    descriptorMr(:,nullDescriptor)=[];
    disp('Descriptores Nulos:');
    disp(size(nullDescriptor,2));
    fprintf('Feature extraction completed \n\n');
   
end
