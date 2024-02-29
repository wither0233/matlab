clear
for year=2013
    if (year==2004)||(year==2008)||(year==2012)||(year==2016)||(year==2020)
        end_day1=366;
    else
        end_day1=365;
    end
    T=52;
    s=-3;
    datex=32;
    start_day=datex-4;
    end_day=datex+3;
    count=0;
    count1=start_day;
    for day=start_day:1:end_day
        if day<=0
            year1=year-1;
            if (year1==2004)||(year1==2008)||(year1==2012)||(year1==2016)
                day1=366+day;
            else
                day1=365+day;
            end
        elseif day>end_day1
            year1=year+1;
            day1=day-end_day1;
        else
            year1=year;
            day1=day;
        end
        if day1<10
            strday='00';
        elseif (day1>=10)&&(day1<100)
            strday='0';
        else
            strday='';
        end
        if year1<=2017
            strday1='_03_07A';
        else
            strday1='_03_07';
        end
        if (year-1==2004)||(year-1==2008)||(year-1==2012)||(year-1==2016)
            end_day2=366;
        else
            end_day2=365;
        end
%         INPUT='/Volumes/qinyusong/Data/TIDI/';
        INPUT='D:\code\data\';
        ncname=[INPUT,num2str(year1),'\TIDI_VEC_',num2str(year1),strday,num2str(day1),strday1,'.ncdf'];
        fid=exist(ncname,'file');
        if (fid==0)&&(day~=count1)
            count=count+1;
        elseif (fid==0)&&(day==count1)
            count=count+1;
            count1=start_day+1;
        else
            if year1==year-1
                ut_time1=double(ncread(ncname,'ut_time'))'./(3600*1000)+(day1-1)*24;   % time from Jan 1st 00:00:00 of the year h
            elseif year1==year
                ut_time1=double(ncread(ncname,'ut_time'))'./(3600*1000)+(day1-1)*24+end_day2*24;
            else
                ut_time1=double(ncread(ncname,'ut_time'))'./(3600*1000)+(day1-1)*24+(end_day1+end_day2)*24;
            end
            alt=double(ncread(ncname,'alt_retrieved'));                         % altitude km
            lat1=double(ncread(ncname,'lat'))';                                 % latitude deg
            lon1=double(ncread(ncname,'lon'))';                                 % longitude deg
            u_p91=double(ncread(ncname,'u_p9'));                                % neutral zonal wind m/s
            v_p91=double(ncread(ncname,'v_p9'));                                % neutral meridional wind m/s
            ascending1=ncread(ncname,'ascending')';                             % True if spacecraft is on the ascending (northbound) leg
            measure_track1=ncread(ncname,'measure_track')';                     % identifies the side of the spacecraft viewed,either warm side or cold side
            if  day==count1
                ut_time=ut_time1;
                lat=lat1;
                lon=lon1;
                u_p9=u_p91;
                v_p9=v_p91;
                ascending=ascending1;
                measure_track=measure_track1;
            else
                ut_time=[ut_time ut_time1];
                lat=[lat lat1];
                lon=[lon lon1];
                u_p9=[u_p9 u_p91];
                v_p9=[v_p9 v_p91];
                ascending=[ascending ascending1];
                measure_track=[measure_track measure_track1];
            end
        end
    end
    if count>=5
        break
    else
        for m=15:1:23
            for focus_lat=-45:5:45
                x=u_p9(m,:);
                j=find((lat>=focus_lat-5)&(lat<=focus_lat+5));
                x1=x(j);
                t1=ut_time(j);
                lon1=lon(j)./360;
                j1=find((x1==0)|(x1==-999));
                x1(j1)=[];
                t1(j1)=[];
                lon1(j1)=[];
                d=[0 0 0];
                f=@(d,t)d(1)+d(2)*cos(2*pi.*(1/T.*t(1,:)-s.*t(2,:)))+d(3)*sin(2*pi.*(1/T.*t(1,:)-s.*t(2,:)));
                [A,~,~,~,~,~]=nlinfit([t1;lon1],x1,f,d);
                B(m-14,(focus_lat+50)./5)=sqrt(A(2).^2+A(3).^2);
            end
        end
    end
%     subplot(1,2,1)
    [C,h]=contourf(-45:5:45,alt(15:1:23),B,'LineStyle','none','LevelStep',4.5);
    caxis([0 45])
    clabel(C,h)
%     caxis([0 30])
    colorbar
    colormap(jet)
    xlabel('Latitude(deg)')
    ylabel('Altitude(km)');
    ylabel(colorbar,'m/s');
    set(gca,'ytick',85:2.5:105);
    set(gca,'xtick',-40:10:40);
    if s>0
        wn=['E',num2str(s)];
    elseif s<0
        wn=['W',num2str(abs(s))];
    else
        wn='S0';
    end
    title(['TIMED/TIDI U ',num2str(year),' Day ',num2str(start_day),'-',num2str(end_day),' ',wn,' T=',num2str(T),'h'])
    set(gca,'FontSize',20)
end