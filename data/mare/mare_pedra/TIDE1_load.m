
cd('C:\Users\fribeiro\Desktop\Gabi')

file=strcat('data\raw_data.txt');
D=load(file);

[lin,col]=size(D);

dd=D(:,1); 
mm=D(:,2); 
aa=D(:,3);
hh=D(:,4); %----UTC
min=D(:,5); 
sec=zeros(lin,1);
elev=D(:,6);
mtime=datenum(aa,mm,dd,hh,min,sec);

elev_norm=(elev-mean(elev));

eval (['save ','data/','raw_tide.mat ', 'mtime elev elev_norm']);



