function y = fn_hw3_201821349 (A,M)

if gcd(A,M) == 1
    
U(1) = 0; 
U(2) = 1;

V(1) = 1;
V(2) = 0;

R(1) = M;
R(2) = A;

Q(1) = floor(M / A);
i = 1;

while  R(i) ~= 0
    i = i + 1;
    R(i+1) = R(i-1) - R(i)*Q(i-1);
    U(i+1) = U(i-1) - U(i)*Q(i-1);
    V(i+1)= V(i-1) - V(i)*Q(i-1);
    Q(i)= floor(R(i) / R(i+1));
 
     
end

  y=mod(U(i-1), M);
  
 else
   y=0;

end

end