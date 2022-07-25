plaintext='catholic';
key='secure$7';

%% plain 패리티 비트 추가
temp_plain = [];
for i = 1:length(plaintext)
    temp=fn_dec2bin(plaintext(i), 7);
    if mod(sum(temp), 2) == 0
       temp_plain = [temp_plain, temp, 1];
    else
        temp_plain = [temp_plain, temp, 0];
    end
end

%% key 패리티 비트 추가
temp_key = [];
for i = 1:length(key)
    tmp = fn_dec2bin(key(i), 7);
    if mod(sum(tmp), 2) == 0
        temp_key = [temp_key, tmp, 1];
    else
        temp_key = [temp_key, tmp, 0];
    end
end




IP = [ 58 50 42 34 26 18 10 2 ...
     60 52 44 36 28 20 12 4 ...
     62 54 46 38 30 22 14 6 ...
     64 56 48 40 32 24 16 8 ...
     57 49 41 33 25 17 9 1 ...
     59 51 43 35 27 19 11 3 ...
     61 53 45 37 29 21 13 5 ...
     63 55 47 39 31 23 15 7]; 

FP = [ 40 8 48 16 56 24 64 32 ...
    39 7 47 15 55 23 63 31 ...
    38 6 46 14 54 22 62 30 ...
    37 5 45 13 53 21 61 29, ...
    36 4 44 12 52 20 60 28 ...
    35 3 43 11 51 19 59 27 ...
    34 2 42 10 50 18 58 26 ...
    33 1 41 9 49 17 57 25]; 


L = zeros(17, 32); 
R = zeros(17, 32); 
roundkey = fn_roundkey(temp_key); 

for i = 1:32 
    L(1, i)=temp_plain(IP(i)); 
    R(1, i)=temp_plain(IP(i+32)); 
end


for i = 2:17 
    L(i, :) = R(i-1, :);
    func_out=fn_f(R(i-1,:),roundkey(i-1,:));
    R(i, :) = xor(func_out, L(i-1, :));
end

all = zeros(1, 64);
all(1:32) = R(17, :);
all(33:64) = L(17, :);
cipher = zeros(1, 64);

for i = 1:64 
    cipher(i) = all(FP(i));
end
fn_bin2hex(cipher)




L_d = zeros(17, 32); R_d = zeros(17, 32);
for i = 1:32 
    R_d(17, i) = cipher(IP(i)); 
    L_d(17, i) = cipher(IP(i+32)); 
end


for i = 17:-1:2
    R_d(i-1,:) = L_d(i,:);
    func_out = fn_f(R_d(i-1,:), roundkey(i-1,:));
    L_d(i-1,:) = xor(func_out,R_d(i,:));
end

all = zeros(1, 64);
all(1:32) = L_d(1, :);
all(33:64) = R_d(1, :);
plain_d = zeros(1, 64);


for i = 1:64 
    plain_d(i) = all(FP(i)); 
end

fn_bin2hex(plain_d)



%%사용된 함수들
%% Add Parity Bit
key_bit=[];
for i=1:length(key)
    tmp=fn_dec2bin(key(i),7);
    if mod(sum(tmp),2)==0
        key_bit=[key_bit, tmp, 1];
    else
        key_bit=[key_bit, tmp, 0];
    end
end

%% fn_dec2bin.m
function y=fn_dec2bin(x,m)
y=[];
for i=1:m
    if x/(2^(m-i))>=1
        y=[y,1]; 
        x=x-2^(m-i);
    else
        y=[y,0];
    end
end
end

%% fn_bin2dec.m
function y=fn_bin2dec(x)
y=0;
N=length(x);
for i=1:N
    if x(i)==1, y=y+2^(N-i); end
end
end

%% fn_bin2hex.m
function s=fn_bin2hex(b)
% change binary bits to hexadecimal number
r=mod(length(b),4);
if r==0, x=b; else x=[zeros(1,4-r), b]; end
N=length(x);
s=[];
for i=1:4:N
    d=fn_bin2dec(x(i:i+3));
    if d<10
        s=[s,num2str(d)];
    else
        switch d
            case 10, s=[s,'a'];
            case 11, s=[s,'b'];
            case 12, s=[s,'c'];
            case 13, s=[s,'d'];
            case 14, s=[s,'e'];
            case 15, s=[s,'f'];
        end
    end
end
end 

%% fn_hex2bin.m
function y=fn_hex2bin(str)
% change hexadecimal number to binary bits
N=length(str);
y=[];
for i=1:N
    if str(i)>=48 && str(i)<=57
        y=[y,fn_dec2bin(str2num(str(i)),4)];
    elseif str(i)>=97 && str(i)<=102
        switch str(i)
            case 'a', y=[y,1 0 1 0];
            case 'b', y=[y,1 0 1 1];
            case 'c', y=[y,1 1 0 0];
            case 'd', y=[y,1 1 0 1];
            case 'e', y=[y,1 1 1 0];
            case 'f', y=[y,1 1 1 1];
        end
    elseif str(i)>=65 && str(i)<=70
        switch str(i)
            case 'A', y=[y,1 0 1 0];
            case 'B', y=[y,1 0 1 1];
            case 'C', y=[y,1 1 0 0];
            case 'D', y=[y,1 1 0 1];
            case 'E', y=[y,1 1 1 0];
            case 'F', y=[y,1 1 1 1];
        end        
    end
end
end

%% fn_f.m
function f_out=fn_f(R,K) 
% DES f function

E_table=[ 32 1 2 3 4 5, 4 5 6 7 8 9, 8 9 10 11 12 13, 12 13 14 15 16 17, ...
    16 17 18 19 20 21, 20 21 22 23 24 25, 24 25 26 27 28 29, 28 29 30 31 32 1];
P_table=[ 16 7 20 21, 29 12 28 17, 1 15 23 26, 5 18 31 10, ...
    2 8 24 14, 32 27 3 9, 19 13 30 6, 22 11 4 25 ];
S(1,:,:)=[14 4 13 1 2 15 11 8 3 10 6 12 5 9 0 7 ;
    0 15 7 4 14 2 13 1 10 6 12 11 9 5 3 8 ;
    4 1 14 8 13 6 2 11 15 12 9 7 3 10 5 0 ;
    15 12 8 2 4 9 1 7 5 11 3 14 10 0 6 13 ];
S(2,:,:)=[5 1 8 14 6 11 3 4 9 7 2 13 12 0 5 10 ;
    3 13 4 7 15 2 8 14 12 0 1 10 6 9 11 5 ;
    0 14 7 11 10 4 13 1 5 8 12 6 9 3 2 15 ;
    13 8 10 1 3 15 4 2 11 6 7 12 0 5 14 9 ];
S(3,:,:)=[10 0 9 14 6 3 15 5 1 13 12 7 11 4 2 8 ;
    13 7 0 9 3 4 6 10 2 8 5 14 12 11 15 1 ;
    13 6 4 9 8 15 3 0 11 1 2 12 5 10 14 7 ;
    1 10 13 0 6 9 8 7 4 15 14 3 11 5 2 12 ];
S(4,:,:)=[7 13 14 3 0 6 9 10 1 2 8 5 11 12 4 15 ;
    13 8 11 5 6 15 0 3 4 7 2 12 1 10 14 9 ;
    10 6 9 0 12 11 7 13 15 1 3 14 5 2 8 4 ;
    3 15 0 6 10 1 13 8 9 4 5 11 12 7 2 14 ];
S(5,:,:)=[2 12 4 1 7 10 11 6 8 5 3 15 13 0 14 9 ;
    14 11 2 12 4 7 13 1 5 0 15 10 3 9 8 6 ;
    4 2 1 11 10 13 7 8 15 9 12 5 6 3 0 14 ;
    11 8 12 7 1 14 2 13 6 15 0 9 10 4 5 3 ];
S(6,:,:)= [12 1 10 15 9 2 6 8 0 13 3 4 14 7 5 11 ;
    10 15 4 2 7 12 9 5 6 1 13 14 0 11 3 8 ;
    9 14 15 5 2 8 12 3 7 0 4 10 1 13 11 6 ;
    4 3 2 12 9 5 15 10 11 14 1 7 6 0 8 13 ];
S(7,:,:)=[4 11 2 14 15 0 8 13 3 12 9 7 5 10 6 1 ;
    13 0 11 7 4 9 1 10 14 3 5 12 2 15 8 6 ;
    1 4 11 13 12 3 7 14 10 15 6 8 0 5 9 2 ;
    6 11 13 8 1 4 10 7 9 5 0 15 14 2 3 12 ];
S(8,:,:)=[13 2 8 4 6 15 11 1 10 9 3 14 5 0 12 7 ;
	1 15 13 8 10 3 7 4 12 5 6 11 0 14 9 2 ;
    7 11 4 1 9 12 14 2 0 6 10 13 15 3 5 8 ;
    2 1 14 7 4 10 8 13 15 12 9 0 3 5 6 11 ];

input_S=zeros(1,48);
for i=1:48
    input_S(i)=xor(R(E_table(i)),K(i));
end

output_S=[];
for i=1:6:48
    row=fn_bin2dec([input_S(i),input_S(i+5)]);
    col=fn_bin2dec(input_S(i+1:i+4));
    output_S=[output_S, fn_dec2bin(S((i+5)/6,row+1,col+1),4)];
end

f_out=zeros(1,32);
for i=1:32
    f_out(i)=output_S(P_table(i));
end

end

%% fn_roundkey.m
function round_key=fn_roundkey(key) % 64-bit key 입력
% DES Key Schedule 

permutation_choice_1=[57 49 41 33 25 17 9, 1 58 50 42 34 26 18, ...
    10 2 59 51 43 35 27, 19 11 3 60 52 44 36, ...
    63 55 47 39 31 23 15, 7 62 54 46 38 30 22, ...
    14 6 61 53 45 37 29, 21 13 5 28 20 12 4];
permutation_choice_2=[14 17 11 24 1 5, 3 28 15 6 21 10, ...
    23 19 12 4 26 8, 16 7 27 20 13 2, ...
    41 52 31 37 47 55, 30 40 51 45 33 48, ...
    44 49 39 56 34 53, 46 42 50 36 29 32];
left_shift=[1 1 2 2 2 2 2 2 1 2 2 2 2 2 2 1];

round_key=zeros(16,48); % K1~K16
C=zeros(17,28); % C0~C16
D=zeros(17,28); % D0~D16
temp=zeros(16,56); % C1D1~C16D16

for i=1:28
    C(1,i)=key(permutation_choice_1(i));
    D(1,i)=key(permutation_choice_1(i+28));
end

for i=1:16
    C(i+1,1:28)=[C(i,left_shift(i)+1:28),C(i,1:left_shift(i))];
    D(i+1,1:28)=[D(i,left_shift(i)+1:28),D(i,1:left_shift(i))]; 
    temp(i,:)=[C(i+1,:),D(i+1,:)];
    for j=1:48
        round_key(i,j)=temp(i,permutation_choice_2(j));
    end
end

end




