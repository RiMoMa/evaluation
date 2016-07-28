
function [claseSel,ClassName] = evaluacionporimagen(model,number_layer_aux,window_size_aux,im)

confusiones={};


load (model);
rutas_test={};
%fprintf(' %d de %d \n', ii, length(indices_casos));


  
%%%%%%recibe una imagen y la clasifica %%%%%%%%%
hist_aux={};
hist_sum=0;
 hists_aux{1} = getImageDescriptor(model,im ,window_size_aux,number_layer_aux);
 aux_sum=cell2mat(hists_aux(1));
 hist_sum=hist_sum+aux_sum;
 hist = hist_sum / sum(hist_sum) ;
 %%%%% clasificacion %%%%%%
 [className, score] = classify(model, hist);
 claseSel=className;
scoring=score;


function hist = getImageDescriptor(model, im,window_size_aux,number_layer_aux)
% -------------------------------------------------------------------------

%im = standarizeImage(im) ;
width = size(im,2) ;
height = size(im,1) ;
numWords = size(model.vocab, 2) ;

% get PHOW features
%[frames, descrs] = vl_phow(im, model.phowOpts{:}) ;
[frames, descrs] = GetDescriptors(im,window_size_aux,number_layer_aux) ;

% quantize local descriptors into visual words
switch model.quantizer
  case 'vq'
    [drop, binsa] = min(vl_alldist(model.vocab, single(descrs)), [], 1) ;
  case 'kdtree'
    binsa = double(vl_kdtreequery(model.kdtree, model.vocab, ...
                                  single(descrs), ...
                                  'MaxComparisons', 50)) ;
end

for i = 1:length(model.numSpatialX)
  binsx = vl_binsearch(linspace(1,width,model.numSpatialX(i)+1), frames(1,:)) ;
  binsy = vl_binsearch(linspace(1,height,model.numSpatialY(i)+1), frames(2,:)) ;

  % combined quantization
  bins = sub2ind([model.numSpatialY(i), model.numSpatialX(i), numWords], ...
                 binsy,binsx,binsa) ;
  hist = zeros(model.numSpatialY(i) * model.numSpatialX(i) * numWords, 1) ;
  hist = vl_binsum(hist, ones(size(bins)), bins) ;
  hists{i} = single(hist / sum(hist)) ;
end
hist = cat(1,hists{:}) ; 




% -------------------------------------------------------------------------
function [f_mrdescr,c] = GetDescriptors (im,window_size_aux,number_layer_aux)
% -------------------------------------------------------------------------

 aux=im;
   %separación H&E

    [Inorm1 H1 E1] = normalizeStaining(aux);
%%%%%%%Inorm1=medfilt2(Inorm1);
       RGB_image=Inorm1;
RGB_filter = [];
RGB_filter(:,:,1)=medfilt2(RGB_image(:,:,1));
RGB_filter(:,:,2)=medfilt2(RGB_image(:,:,2));
RGB_filter(:,:,3)=medfilt2(RGB_image(:,:,3));
Inorm1=RGB_filter;

%%%%%%%%%%%%%

    rgb_aux=rgb2gray(H1);
    rgb_aux=medfilt2(rgb_aux);
    I=uint8(rgb_aux);
    I=impyramid(I,'reduce');
    I=impyramid(I,'expand');
    rgb_aux=I;
     %%%%%%% MSER %%%%%%% (omito el mapa binario)
     disp('Calculando MSER features...');
     [r,f]=vl_mser(rgb_aux,'Delta',5,'DarkOnBright',1,'BrightOndark',0,'MaxArea',0.0016, 'MinDiversity',0.8,'MinArea',0.0001);
    %%corte de los candidatos
       %cortar
              f=vl_ertr(f);

       
       nCandidatos=size(r,1);
    fprintf('Numero total de candidatos %d \n', nCandidatos);

%%%%%%% Lo de los filtros y toda a vaina

  M_3 = zeros(size(I));
    for x=r'


    s = vl_erfill(I,x) ;

    M_3(s)=M_3(s)+1;
    %entrop=[entrop,entropy(immultiply(I,uint8(M_3)))];
   end
M_3=imfill(M_3,'holes');
    se=strel('disk',2);
    M_3=imerode(M_3,se);
    M_3=imopen(M_3,se);
    M_3=bwareaopen(M_3,500);
s  = regionprops(M_3, 'centroid');
 centroids = cat(1, s.Centroid);
f=centroids';
 nCandidatos=size(centroids,1);

fprintf('Numero total de candidatos al procesar %d \n', nCandidatos);


%%%%% Hasta aqui y veamos que pasa



    
    %%%%%gg%%%%% Cortar los parches %%%%%%%%%%
im=rgb_aux;
   %im=rgb2gray(H1);
  %  im=single(im);
    d={};
   % parfor x=1:length(f)
   aux_sel=randperm(size(f,2));
   
   
   if length(aux_sel)<1600
       palabras=length(aux_sel);
   else
       palabras=1600;
   end
   
       vector1 = f(1,[aux_sel]);
       vector2 = f(2,[aux_sel]);

	fc=[vector1;vector2];
       %fc = [vector1;vector2;32*ones(size(vector1));zeros(size(vector1))];
       %[f_sift,c]=vl_sift(im,'frames',fc);  

	[f_mrdescr, c]=extractMrDescriptor2(number_layer_aux,window_size_aux,Inorm1,fc);  
        %eliminar info en 5 8 irrelevante
 %c=c(window_size_aux*window_size_aux+1:end,:);
    
   
   
 

   



%%%%%%%%recibe una imagen y la clasifica %%%%%%%%%

% -------------------------------------------------------------------------
 function [className, score] = classify(model, hist)
% % -------------------------------------------------------------------------
psix = vl_homkermap(hist, 1, 'kchi2', 'gamma', .5) ;
scores = model.w' * psix + model.b' ;
[score, best] = max(scores) ;
className = model.classes{best} ;
