function [d_psi_est, P_est] = Heading_Filter( ...
    P_est_old, phi_p, theta_p, psi_p, gyro, psi_m, dt)

p = gyro(1);
q = gyro(2);
r = gyro(3);

%% Noise matrices

sigma_g   = deg2rad(0.1);
sigma_pol = deg2rad(1);

Q = sigma_g^2 * eye(3);
R = sigma_pol^2;

H = 1;

%% Propagation phase

A = 0;

B = [ ...
    0, ...
    sin(phi_p)/cos(theta_p), ...
    cos(phi_p)/cos(theta_p)];

F = 1 + dt*A;
Gamma = dt*B;

P_prop = F*P_est_old*F' + Gamma*Q*Gamma';

%% Update phase

K = P_prop*H'/(H*P_prop*H' + R);

deltaz = wrapToPi(psi_m - psi_p);

d_psi_est = K*deltaz;

P_est = (1-K*H)*P_prop*(1-K*H)' + K*R*K';

end