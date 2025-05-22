% Reduce size of the grid
lat_SIC=double(ncread('NSIDC0771_LatLon_PS_N25km_v1.0.nc','latitude'));
lon_SIC=double(ncread('NSIDC0771_LatLon_PS_N25km_v1.0.nc','longitude'));

lat_thres=68;
matrow=NaN(size(lat_SIC,1),2);
for irow=1:size(lat_SIC,1)
    if ~isempty(find(lat_SIC(irow,:)>=lat_thres,1))
    matrow(irow,1)=find(lat_SIC(irow,:)>=lat_thres,1,'first');
    matrow(irow,2)=find(lat_SIC(irow,:)>=lat_thres,1,'last');
    end
end
clear irow

postop=find(~isnan(matrow(:,1)),1,'first'); %everything above can be thrown away
posbottom=find(~isnan(matrow(:,1)),1,'last'); %everything below can be thrown away
posleft=nanmin(matrow(:,1)); 
posright=nanmax(matrow(:,2)); clear matrow

lat_SIC1=lat_SIC(postop:posbottom,posleft:posright);
lon_SIC1=lon_SIC(postop:posbottom,posleft:posright);
clear lat_SIC lon_SIC lat_tres

pol=h5read('polynyaloc_fortraining.h5','/polynyaloc');
pol=pol(postop:posbottom,posleft:posright,:);

sic=h5read('allNSIDC_fortraining.h5', '/sic');
sic=sic(postop:posbottom,posleft:posright,:);
sic(sic<0.15)=0;
sic(sic>1)=1;

% save these as "for testing", used by CNN2D.ipynb cell 2
h5create('polynyaloc_fortesting.h5', '/polynyaloc', size(pol))
h5write('polynyaloc_fortesting.h5', '/polynyaloc', pol)

h5create('allNSIDC_fortesting', '/sic', size(sic))
h5write('allNSIDC_fortesting', '/sic', sic)

% Generate oversampled set, used by CNN2D.ipynb cell 1
thresnb=[100 500; 200 200; 400 100; 200 50; 100 10];

polover=zeros(size(lon_SIC1,1),size(lon_SIC1,2),1000);
sicover=ones(size(lon_SIC1,1),size(lon_SIC1,2),1000);

compt=0;
for ithres=1:size(thresnb,1)
for iT=1:thresnb(ithres,1)
    posrand=randperm(size(pol,3),thresnb(ithres,2));
    sic_test=NaN(size(lon_SIC1,1),size(lon_SIC1,2));
    for ilon=1:size(lon_SIC1,1)
        for ilat=1:size(lon_SIC1,2)
            jpol=pol(ilon,ilat,posrand); jsic=sic(ilon,ilat,posrand);
            sic_test(ilon,ilat)=nanmean(jsic(jpol~=0));
            clear jpol jsic
        end
    end

    junkpol=nansum(pol(:,:,posrand),3);
    junksic=nanmean(sic(:,:,posrand),3);
    junkpol(junkpol==1)=0; junkpol(junkpol>1)=1;
    junksic(junkpol==1)=sic_test(junkpol==1);
    polover(:,:,iT+compt)=junkpol;
    sicover(:,:,iT+compt)=junksic;
    clear junkpol junksic sic_test posrand
end
compt=compt+thresnb(ithres,1);
end

posshuff=randperm(size(polover,3));
polover=polover(:,:,posshuff); sicover=sicover(:,:,posshuff);
sicover(sicover>1)=1; sicover(sicover<0.15)=0;

h5create('polynyaloc_oversampled.h5', '/polynyaloc', size(polover))
h5write('polynyaloc_oversampled.h5', '/polynyaloc', polover)
h5create('NSIDC_oversampled_from2000.h5', '/sic', size(sicover))
h5write('NSIDC_oversampled_from2000.h5', '/sic', sicover)




