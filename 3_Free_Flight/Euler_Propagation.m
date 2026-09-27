function [phi_p, theta_p, psi_p] = Euler_Propagation( ...
    phi_est, theta_est, psi_est, gyro, dt)

p = gyro(1);
q = gyro(2);
r = gyro(3);

%% Protect against singularity

theta_est = max(min(theta_est, deg2rad(89.9)), deg2rad(-89.9));

%% Euler Kinematics

phidot = p + ...
    q*sin(phi_est)*tan(theta_est) + ...
    r*cos(phi_est)*tan(theta_est);
thetadot = q*cos(phi_est) - ...
    r*sin(phi_est);
psidot = q*sin(phi_est)/cos(theta_est) + ...
    r*cos(phi_est)/cos(theta_est);

%% Propagation

phi_p = phi_est + phidot*dt;
theta_p = theta_est + thetadot*dt;
psi_p = psi_est + psidot*dt;

phi_p = wrapToPi(phi_p);
theta_p = wrapToPi(theta_p);
psi_p = wrapToPi(psi_p);

end