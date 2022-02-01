c-- CALC_A1_B1_A2_B2 -----------------------------------------------------------
c
c   Calculates the direction-corrected a's and b's for CDIP's spectral file.
c   The formulas used are based on code in the original buoy_fi:
c
c     extracting a1,  from the data.
c     datawell provides spreading s, mean direction theta and a2, b2,
c     plus the following relationships (pp 9 directional waverider manual)
c
c     s = sqrt(2-2m)
c     tan(theta) = b1/a1
c     m = sqrt(a1^2 + b1^2)              (this is the correct expression!!)
c
c     (s^2)/2 = 1 - sqrt(a1^2 + b1^2)
c     (s^2)/2 = 1 - sqrt(a1^2 + (a1^2)*tan^2(theta))
c     (s^2)/2 = 1 - a1*sqrt(1 + tan^2(theta))
c     (s^2)/2 = 1 - a1/cos(theta)
c     a1 = (1 - (s^2)/2)*cos(theta)
c     similarly
c     b1 = (1 - (s^2)/2)*sin(theta)
c
c     do band = 1,bands                                !* calc a1, b1
c      direction_mean = theta(cycle,band)
c      rad_theta = theta(cycle,band)*deg2rad           !* direction radians
c      rad_spread = spread(cycle,band)*deg2rad         !* spread, radians
c      rad_spread_sq = rad_spread**2
c      temp_val = 1. - rad_spread_sq/2.                !* removed sqrt, 7/15/99
c      a1_temp = temp_val*cos(rad_theta)
c      b1_temp = temp_val*sin(rad_theta)
c      a2_temp = a2_coeff(cycle,band)
c      b2_temp = b2_coeff(cycle,band)
c 
c      a1_prime = a1_temp*cos(theta_prime) -           !* rotate to true
c    .            b1_temp*sin(theta_prime)             !* north system
c      b1_prime = a1_temp*sin(theta_prime) + 
c    .            b1_temp*cos(theta_prime)
c
c      theta_mean = atan2(b1_prime, a1_prime)     !* wrt true north
c      theta_p = 0.5*atan2(b2_temp, a2_temp)      !* unrotated principal angle
c      theta_pr = theta_mean + theta_p
c      two_theta_rotate = 2.*theta_mean
c
c      Datawell gives a2, b2 with respect to a1, b1. That is, the
c      principal angle atan(b2/a2) is wrt to the mean angle,
c      atan(b1/a1) to conform to wavdas we convert the a2, b2 and principal
c      angle to be wrt true north
c
c      a2_prime = a2_temp*cos(two_theta_rotate) -      !* a2 and b2 with respect
c    .            b2_temp*sin(two_theta_rotate)        !* to true north
c      b2_prime = a2_temp*sin(two_theta_rotate) +
c    .            b2_temp*cos(two_theta_rotate)
c
c      the DU_ variable are "datawell_utils" global variables.
c      the a1,a2,b1,b2 below are same as a1_prime, etc.
c-------------------------------------------------------------------------------

          subroutine calc_a1_b1_a2_b2(theta,spread,dw_a2,dw_b2,a1,b1,a2,b2)

            real a1, b1, dw_a2, dw_b2, real_dir, real_var, spread, 
     *        theta, temp_a1, temp_a2

c-- changes magnetic degrees variation to real radians degrees.
            real_var = to_radians(real(DU_magnetic_var))

            a1_temp = (1.-spread**2/2.)*cos(to_radians(theta-DU_magnetic_var))
            b1_temp = (1.-spread**2/2.)*sin(to_radians(theta-DU_magnetic_var))

            a1 = a1_temp*cos(real_var) - b1_temp*sin(real_var)
            b1 = a1_temp*sin(real_var) + b1_temp*cos(real_var)

            two_theta_rotate = 2. * atan2(b1,a1)		!*atan2(b1,a1)= theta_mean

c-- dw_a2 and dw_b2 are datawell given values 
            a2 = dw_a2*cos(two_theta_rotate) - dw_b2*sin(two_theta_rotate)
            b2 = dw_a2*sin(two_theta_rotate) + dw_b2*cos(two_theta_rotate)

          end subroutine 
