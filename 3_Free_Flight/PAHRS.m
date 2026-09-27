%% Polarization-Based AHRS

clear
close all
clc

load("log_data.mat")

% IMU Data
% 1. time (sec), 2. gyroscope (rad/sec), 3. accelerometer (m/s^2)

% Magnetometer Data
% 1. time (sec), 2. magnetic field (Guass)

% Euler Data
% 1. time (sec) 2. Euler angles (deg)

% Velocity Data
% 1. time (sec), 2. v_n (m/s), 3. v_e (m/s), 4. v_d (m/s)

% Polarization Data
% 1. time (sec), 2. yaw_mes1 (deg), 3. yaw_mes2 (deg)

%% Data

g = 9.81;
time_imu = IMU(:,1);
gyro = IMU(:,2:4);
acc = IMU(:,5:7);

time_euler = Euler(:,1);
euler = deg2rad(Euler(:,2:4));

time_mag = Magnetometer(:,1);
mag = Magnetometer(:,2:4);

time_vel = Velocity(:,1);
vel = Velocity(:,2:4);
v_n_sync = interp1(time_vel, vel(:,1), time_imu, 'pchip', 'extrap');
v_e_sync = interp1(time_vel, vel(:,2), time_imu, 'pchip', 'extrap');
v_d_sync = interp1(time_vel, vel(:,3), time_imu, 'pchip', 'extrap');
vel_sync = [v_n_sync, v_e_sync, v_d_sync];

time_pol = Polarization(2:end,1) - 1.7; % Time eeror 
yaw_m1 = deg2rad(wrapTo180(Polarization(2:end,2)-28));
yaw_m2 = deg2rad(wrapTo180(Polarization(2:end,3)-28));

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
else
    psi_est(1) = (yaw_m2(1));
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

    [phi_m(epoch_imu), theta_m(epoch_imu)] = Attitude_Measurement( ...
        acc(epoch_imu,:), g, ...
        vel_sync(epoch_imu,:), vel_sync(epoch_imu-1,:), dt, ...
        gyro(epoch_imu,:), ...
        phi_p, theta_p, psi_p, ...                                    
        phi_est(epoch_est-1), theta_est(epoch_est-1), psi_est(epoch_est-1));

    [d_phi_est, d_theta_est, P_est_att] = Attitude_Filter( ...
        P_est_att, phi_p, theta_p, psi_p, gyro_prop, ...
        phi_m(epoch_imu), theta_m(epoch_imu), dt);

    time_est(epoch_est)  = time_imu(epoch_imu);
    phi_est(epoch_est)   = wrapToPi(phi_p + d_phi_est);
    theta_est(epoch_est) = wrapToPi(theta_p + d_theta_est);
    psi_est(epoch_est)   = (psi_p);

    gyro_prop = gyro(epoch_imu,:);

    epoch_est = epoch_est + 1;
    
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

    epoch_imu = epoch_imu + 1;

end
