
procedure  calc_newx_newy(fitsXfloat,fitsYfloat: double);
var
  u,u0,v,v0,dRa,dDec,delta,ra_new,dec_new,delta_ra,det,gamma,SIN_dec_new,COS_dec_new,SIN_delta_ra,COS_delta_ra,h,
  x_new_float,y_new_float: double;
Begin

  begin {astrometric based correction}
    {6. Conversion (x,y) -> (RA,DEC)  for image to be added}
    u0:=fitsXfloat-crpix1;
    v0:=fitsYfloat-crpix2;

    u:=u0;
    v:=v0;

    dRa :=(cd1_1 * u +cd1_2 * v)*pi/180;
    dDec:=(cd2_1 * u +cd2_2 * v)*pi/180;
    delta:=cos(dec0)-dDec*sin(dec0);
    gamma:=sqrt(dRa*dRa+delta*delta);
    RA_new:=ra0+arctan(Dra/delta);
    DEC_new:=arctan((sin(dec0)+dDec*cos(dec0))/gamma);


   {5. Conversion (RA,DEC) -> (x,y) of reference image}
    sincos(dec_new,SIN_dec_new,COS_dec_new);{sincos is faster then seperate sin and cos functions}
    delta_ra:=RA_new-ra0;
    sincos(delta_ra,SIN_delta_ra,COS_delta_ra);

    H := SIN_dec_new*sin(dec0) + COS_dec_new*COS(dec0)*COS_delta_ra;
    dRA := (COS_dec_new*SIN_delta_ra / H)*180/pi;
    dDEC:= ((SIN_dec_new*COS(dec0) - COS_dec_new*SIN(dec0)*COS_delta_ra ) / H)*180/pi;

    det:=CD2_2*CD1_1 - CD1_2*CD2_1;

    u0:= - (CD1_2*dDEC - CD2_2*dRA) / det;
    v0:= + (CD1_1*dDEC - CD2_1*dRA) / det;
    begin
      x_new_float:=(CRPIX1 + u0)-1;
      y_new_float:=(CRPIX2 + v0)-1;
    end;
    mainwindow.caption:=floattostr(fitsXfloat)+' | '+floattostr(x_new_float)+' | '+floattostr(fitsYfloat)+' | '+floattostr(y_new_float);

  end;{astrometric}
end;{calc_newx_newy}  