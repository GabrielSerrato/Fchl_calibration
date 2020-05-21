function [teta]=angle2(ux,uy)

vetu=[ux,0];
vety=[0,uy];
res=vetu+vety;
ref=[0,1];

a=dot(res,ref,2);
b=sqrt(res(1)^2+res(2)^2);
c=sqrt(ref(1)^2+ref(2)^2);


q=acos(a/(b*c));
teta=q*180/pi;

end
