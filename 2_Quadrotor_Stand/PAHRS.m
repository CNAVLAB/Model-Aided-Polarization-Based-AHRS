%% Polarization-Based AHRS

clear
close all
clc
load("test_data.mat")
% IMU Data
% 1. time (sec), 2. accelerometer (g), 3. gyroscope (deg/sec),
% 4. Euler angle (deg), 5. magnetic field (micro tesla)
% Polarization Data
% 1. time (sec), 2. yaw_mes1 (deg), 3. yaw_mes2 (deg)

%% Data

g = 9.81;
time_imu = IMU(:,1);
acc = IMU(:,2:4)*g;
gyro = deg2rad(IMU(:,5:7));
euler = deg2rad(IMU(:,8:10));
mag = IMU(:,11:13);

time_pol = Polarization(:,1);
yaw_m1 = deg2rad(wrapTo180(Polarization(:,2))-5);
yaw_m2 = deg2rad(wrapTo180(Polarization(:,3))-5);

%% Remove duplicate timestamps

keep = [true; diff(time_imu) > 0];
time_imu = time_imu(keep);
acc      = acc(keep,:);
gyro     = gyro(keep,:);
euler    = euler(keep,:);
mag      = mag(keep,:);

%% Rotation
% These body and world rotations is performed for 2 reasons
% 1- The x,y and z axis of Body frame is different with the x,y and z axis of the Sensor frame
% 2- The Euler angles of the sensor (Ground truth, Reference) is calculated based on Body to ENU transformation, 
%    while the Calculated angle (This Propagation, integration algorithm) is calculated based on Body to NED transformation.

% So, two rotation is performed, one is for sensor data to change from mounting position to Body position
% and the other rotation is for Transformation matrix to turn the Reference angle from [T]^{ENU-S} to [T]^{NED-B}.

R_body = diag([1, -1, -1]); % NEW mounting: x->x, y->-y, z->-z

R_world = [0 1 0;
           1 0 0;
           0 0 -1]; % sensor's ENU -> NED (unchanged, mounting-independent)

acc = (R_body * acc')';
gyro = (R_body * gyro')';
mag = (R_body * mag')';

euler_rot = zeros(size(euler));
for k = 1:length(time_imu)
    Cbn = eul2rotm(euler(k,[3 2 1]), 'ZYX');
    Cbn_new = R_world * Cbn * R_body';
    eul_new = rotm2eul(Cbn_new,'ZYX');
    euler_rot(k,:) = eul_new([3 2 1]);
end
euler = euler_rot;

%% Initialization

time_est(1) = time_imu(1);

ax = acc(1,1);
ay = acc(1,2);
az = acc(1,3);

theta_est(1) = atan2(ax, sqrt(ay^2 + az^2));
phi_est(1)   = atan2(-ay, -az);

mx = mag(1,1);
my = mag(1,2);
mz = mag(1,3);

num_psi = -my*cos(phi_est(1)) + mz*sin(phi_est(1));
den_psi = mx*cos(theta_est(1)) + ...
    my*sin(theta_est(1))*sin(phi_est(1)) + ...
    mz*sin(theta_est(1))*cos(phi_est(1));
yaw_mag = wrapToPi(atan2(num_psi, den_psi));

if abs(wrapToPi((yaw_m1(1))-yaw_mag)) < abs(wrapToPi((yaw_m2(1))-yaw_mag))
    psi_est(1) = (yaw_m1(1));
    % column = 1;
else
    psi_est(1) = (yaw_m2(1));
    % column = 2;
end

P_est_att = diag([deg2rad(5)^2, deg2rad(5)^2]);
P_est_psi = deg2rad(10)^2;

%% Main Run

gyro_prop = gyro(1,:);

epoch_imu = 2;
epoch_pol = 2;
epoch_est = 2;

while epoch_imu <= length(time_imu)

    % IMU update

    dt = time_imu(epoch_imu) - time_est(epoch_est-1);

    [phi_p, theta_p, psi_p] = Euler_Propagation( ...
        phi_est(epoch_est-1), theta_est(epoch_est-1), psi_est(epoch_est-1), ...
        gyro_prop, dt);

    [phi_m(epoch_imu), theta_m(epoch_imu)] = ...
        Attitude_Measurement(acc(epoch_imu,:));

    [d_phi_est, d_theta_est, P_est_att] = Attitude_Filter( ...
        P_est_att, phi_p, theta_p, psi_p, gyro_prop, ...
        phi_m(epoch_imu), theta_m(epoch_imu), dt);

    time_est(epoch_est)  = time_imu(epoch_imu);
    phi_est(epoch_est)   = wrapToPi(phi_p + d_phi_est);
    theta_est(epoch_est) = wrapToPi(theta_p + d_theta_est);
    psi_est(epoch_est)   = (psi_p);

    gyro_prop = gyro(epoch_imu,:);

    epoch_est = epoch_est + 1;
    epoch_imu = epoch_imu + 1;

    % Polarization update

    if epoch_pol <= length(time_pol) ...
            && time_pol(epoch_pol) <= time_imu(epoch_imu)

        dt = time_pol(epoch_pol) - time_imu(epoch_imu-1);

        [phi_p, theta_p, psi_p] = Euler_Propagation( ...
            phi_est(epoch_est-1), theta_est(epoch_est-1), psi_est(epoch_est-1), ...
            gyro(epoch_imu-1,:), dt);

        if abs(wrapToPi((yaw_m1(epoch_pol))-psi_est(epoch_est-1))) < ...
        abs(wrapToPi((yaw_m2(epoch_pol))-psi_est(epoch_est-1)))
            psi_m(epoch_pol) = (yaw_m1(epoch_pol));
        else
            psi_m(epoch_pol) = (yaw_m2(epoch_pol));
        end

        if abs(wrapToPi(psi_m(epoch_pol)-psi_est(epoch_est-1))) < 20*pi/180

            [d_psi_est, P_est_psi] = Heading_Filter( ...
                P_est_psi, phi_p, theta_p, psi_p, gyro(epoch_imu-1,:), ...
                psi_m(epoch_pol), dt);

            time_est(epoch_est)  = time_pol(epoch_pol);
            phi_est(epoch_est)   = phi_p;
            theta_est(epoch_est) = theta_p;
            psi_est(epoch_est)   = wrapToPi(psi_p + d_psi_est);

        else

            time_est(epoch_est)  = time_pol(epoch_pol);
            phi_est(epoch_est)   = phi_p;
            theta_est(epoch_est) = theta_p;
            psi_est(epoch_est)   = (psi_p);

        end

        % Extrapolated gyro at polarization timestamp

        tp = time_pol(epoch_pol);
        t1 = time_imu(epoch_imu-2);
        t2 = time_imu(epoch_imu-1);

        gyro_t1 = gyro(epoch_imu-2,:);
        gyro_t2 = gyro(epoch_imu-1,:);

        gyro_prop = gyro_t2 + ...
            (gyro_t2 - gyro_t1) * ((tp - t2)/(t2 - t1));

        epoch_est = epoch_est + 1;
        epoch_pol = epoch_pol + 1;

    end

end
