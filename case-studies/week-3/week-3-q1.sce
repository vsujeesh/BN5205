clear;
clf;
// constant variables
frequency = 0.1;  // Hz
omega = 2 * %pi * frequency;
sigma_0 = 6;  // MPa
E = 3;  // elastic modulus (MPa)
eta = 5;  // viscosity (MPa/s)
dt1 = 0.01; // s
dt2 = dt1 * 10;
dt3 = dt1 * 100;

function sigma_t = Stress(t)
  sigma_t = sigma_0 * sin(omega * t);
endfunction

function epsilon = Analytical(t)
  epsilon = sigma_0 / (E^2 + eta^2 * omega^2) * (omega * eta *...
      exp(-E / eta * t) + E * sin(omega * t) - omega * eta *...
      cos(omega * t));
endfunction

function slope = dedt(t, epsilon)
  slope = (-E * epsilon + Stress(t)) / eta;
endfunction

function y = ForwardEuler(t, y_prev, h)
  y = y_prev + h * dedt(t, y_prev);
endfunction

function y = HeunsMethod(t, y_prev, h)
  intermediate = dedt(t, y_prev);
  y = y_prev + h / 2 * (intermediate + dedt(t + h, y_prev + h *...
      intermediate));
endfunction

function y = MidpointMethod(t, y_prev, h)
  y = y_prev + h * dedt(t + h / 2, y_prev + h / 2 *...
      dedt(t, y_prev));
endfunction

function y = RK4(t, y_prev, h)
  k1 = dedt(t, y_prev);
  k2 = dedt(t + h / 2, y_prev + h / 2 * k1);
  k3 = dedt(t + h / 2, y_prev + h / 2 * k2);
  k4 = dedt(t + h, y_prev + h * k3);
  y = y_prev + h * (k1 + 2 * k2 + 2 * k3 + k4) / 6;
endfunction

// Time domains for 3 different values of dt
time1 = [0:dt1:100];
time2 = [0:dt2:100];
time3 = [0:dt3:100];
// Forward Euler using 3 different values of dt
fe_1 = zeros(time1);
fe_2 = zeros(time2);
fe_3 = zeros(time3);
// RK2 Heun's method using 3 different values of dt
hm_1 = zeros(time1);
hm_2 = zeros(time2);
hm_3 = zeros(time3);
// RK2 Midpoint method using 3 different values of dt
mm_1 = zeros(time1);
mm_2 = zeros(time2);
mm_3 = zeros(time3);
// RK4 method using 3 different values of dt
rk_1 = zeros(time1);
rk_2 = zeros(time2);
rk_3 = zeros(time3);
for t1 = 1:length(time1) - 1
  fe_1(t1 + 1) = ForwardEuler(time1(t1), fe_1(t1), dt1);
  hm_1(t1 + 1) = HeunsMethod(time1(t1), hm_1(t1), dt1);
  mm_1(t1 + 1) = MidpointMethod(time1(t1), mm_1(t1), dt1);
  rk_1(t1 + 1) = RK4(time1(t1), rk_1(t1), dt1);
  if (~modulo(t1, 10))
    t2 = t1 / 10;
    fe_2(t2 + 1) = ForwardEuler(time2(t2), fe_2(t2), dt2);
    hm_2(t2 + 1) = HeunsMethod(time2(t2), hm_2(t2), dt2);
    mm_2(t2 + 1) = MidpointMethod(time2(t2), mm_2(t2), dt2);
    rk_2(t2 + 1) = RK4(time2(t2), rk_2(t2), dt2);
  end
  if (~modulo(t1, 100))
    t3 = t1 / 100;
    fe_3(t3 + 1) = ForwardEuler(time3(t3), fe_3(t3), dt3);
    hm_3(t3 + 1) = HeunsMethod(time3(t3), hm_3(t3), dt3);
    mm_3(t3 + 1) = MidpointMethod(time3(t3), mm_3(t3), dt3);
    rk_3(t3 + 1) = RK4(time3(t3), rk_3(t3), dt3);
  end
end

plot(time1, Analytical(time1));
plot(time1, fe_1, 'm');
plot(time2, fe_2, 'g');
plot(time3, fe_3, 'k');
plot(time1, hm_1, 'm--');
plot(time2, hm_2, 'g--');
plot(time3, hm_3, 'k--');
plot(time1, mm_1, 'm:');
plot(time2, mm_2, 'g:');
plot(time3, mm_3, 'k:');
plot(time1, rk_1, 'm-.');
plot(time2, rk_2, 'g-.');
plot(time3, rk_3, 'k-.');
xlabel("$Time\ t$", "fontsize", 3);
ylabel("$Strain\ \epsilon$", "fontsize", 3);
title("Viscoelastic model of IVD (Analytical vs Forward Euler vs"...
    + " RK2)");
legend(["Analytical"; "FE, dt = 0.01"; "FE, dt = 0.1";...
    "FE, dt = 1"; "HM, dt = 0.01"; "HM, dt = 0.1";...
    "HM, dt = 1"; "MM, dt = 0.01"; "MM, dt = 0.1";...
    "MM, dt = 1"; "RK4, dt = 0.01"; "RK4, dt = 0.1";...
    "RK4, dt = 1"], -1);

// Old implementation
//for t1 = 1:length(time1) - 1
//  fe_1(t1 + 1) = fe_1(t1) + dt1 / eta * (-E * fe_1(t1) +...
//      Stress(time1(t1)));
//
//  // Heun's method uses Forward Euler as the intermediate value
//  hm_1(t1 + 1) = hm_1(t1) + dt1 / 2 / eta * (-E * hm_1(t1) +...
//      Stress(time1(t1)) + -E * fe_1(t1 + 1) +...
//      Stress(time1(t1 + 1)));
//
//  mm_intermediate = mm_1(t1) + dt1 / 2 / eta * (-E * mm_1(t1) +...
//      Stress(time1(t1)));
//  mm_1(t1 + 1) = mm_1(t1) + dt1 / eta * (-E * mm_intermediate +...
//      Stress(time1(t1) + dt1 / 2));
//  if (~modulo(t1, 10))
//    t2 = t1 / 10;
//    fe_2(t2 + 1) = fe_2(t2) + dt2 / eta * (-E * fe_2(t2) +...
//        Stress(time2(t2)));
//
//    hm_2(t2 + 1) = hm_2(t2) + dt2 / 2 / eta * (-E * hm_2(t2) +...
//    Stress(time2(t2)) + -E * fe_2(t2 + 1) +...
//    Stress(time2(t2 + 1)));
//
//    mm_intermediate = mm_2(t2) + dt2 / 2 / eta * (-E * mm_2(t2) +...
//        Stress(time2(t2)));
//    mm_2(t2 + 1) = mm_2(t2) + dt2 / eta * (-E * mm_intermediate +...
//        Stress(time2(t2) + dt2 / 2));
//  end
//  if (~modulo(t1, 100))
//    t3 = t1 / 100;
//    fe_3(t3 + 1) = fe_3(t3) + dt3 / eta * (-E * fe_3(t3) +...
//        Stress(time3(t3)));
//
//    hm_3(t3 + 1) = hm_3(t3) + dt3 / 2 / eta * (-E * hm_3(t3) +...
//    Stress(time3(t3)) + -E * fe_3(t3 + 1) +...
//    Stress(time3(t3 + 1)));
//
//    mm_intermediate = mm_3(t3) + dt3 / 2 / eta * (-E * mm_3(t3) +...
//        Stress(time3(t3)));
//    mm_3(t3 + 1) = mm_3(t3) + dt3 / eta * (-E * mm_intermediate +...
//        Stress(time3(t3) + dt3 / 2));
//  end
//end
