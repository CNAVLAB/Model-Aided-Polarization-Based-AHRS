function [phi_m, theta_m] = Attitude_Measurement(acc)

ax = acc(1);
ay = acc(2);
az = acc(3);

%% Attitude Measurement

theta_m = atan2(ax,sqrt(ay^2+az^2));
phi_m = atan2(-ay,-az);

end