%%메시지 입력
file = fopen('message_long.txt', 'r');
ori_plain = fread(file);
fclose(file);

N = length(ori_plain);
temp = zeros(1, N);
j = 0;
for i = 1 : N
    if ((ori_plain(i) >= 'A') && (ori_plain(i) <= 'Z')) % if capital letter
        j = j + 1;
        temp(j) = char(mod(ori_plain(i) - 'a', 26) + 'a' );
    elseif ((ori_plain(i) >= 'a') && (ori_plain(i) <= 'z')) % if small letter
        j = j + 1;
        temp(j) = ori_plain(i);
    end
end

%% W ->메시지 쪼개기
if mod(N, 128) < 112
    W_f = zeros(16 * (fix(N / 128) + 1), 64);
else
    W_f = zeros(16 * (fix(N / 128) + 2), 64);
end

  
for i = 1 : N
  temp_W = fn_dec2bin(temp(i), 8);
  W_f(fix((i - 1) / 8) + 1, (8 * (i - 8 * fix((i - 1) / 8)) - 7) : (8 * (i - 8 * fix((i - 1) / 8)))) = temp_W;
end
if mod(N, 8) == 0
     W_f(fix(N / 8) + 1, 1) = 1;
else
    W_f(fix(N / 8), (8 * (N - 8 * fix(N / 8)) + 1)) = 1;
end


W_num = fn_dec2bin(8 * N, 128);
W_f(16 * (numel(W_f) / 1024) - 1, :) = W_num(1:64);
W_f(16 * (numel(W_f) / 1024), :) = W_num(65:128);


%% 초기 H0
ha = '6a09e667f3bcc908'; a = fn_hex2bin(ha); f_a = fn_hex2bin(ha); 
hb = 'bb67ae8584caa73b'; b = fn_hex2bin(hb); f_b = fn_hex2bin(hb);
hc = '3c6ef372fe94f82b'; c = fn_hex2bin(hc); f_c = fn_hex2bin(hc);
hd = 'a54ff53a5f1d36f1'; d = fn_hex2bin(hd); f_d = fn_hex2bin(hd);
he = '510e527fade682d1'; e = fn_hex2bin(he); f_e = fn_hex2bin(he);
hf = '9b05688c2b3e6c1f'; f = fn_hex2bin(hf); f_f = fn_hex2bin(hf);
hg = '1f83d9abfb41bd6b'; g = fn_hex2bin(hg); f_g = fn_hex2bin(hg);
hh = '5be0cd19137e2179'; h = fn_hex2bin(hh); f_h = fn_hex2bin(hh);

%% K 테이블

 hK = ["428a2f98d728ae22", "7137449123ef65cd", "b5c0fbcfec4d3b2f", ... 
     "e9b5dba58189dbbc", "3956c25bf348b538", "59f111f1b605d019", ... 
     "923f82a4af194f9b", "ab1c5ed5da6d8118", "d807aa98a3030242", ... 
     "12835b0145706fbe", "243185be4ee4b28c", "550c7dc3d5ffb4e2", ... 
     "72be5d74f27b896f", "80deb1fe3b1696b1", "9bdc06a725c71235", ... 
     "c19bf174cf692694", "e49b69c19ef14ad2", "efbe4786384f25e3", ... 
     "0fc19dc68b8cd5b5", "240ca1cc77ac9c65", "2de92c6f592b0275", ... 
     "4a7484aa6ea6e483", "5cb0a9dcbd41fbd4", "76f988da831153b5", ... 
     "983e5152ee66dfab", "a831c66d2db43210", "b00327c898fb213f", ... 
     "bf597fc7beef0ee4", "c6e00bf33da88fc2", "d5a79147930aa725", ... 
     "06ca6351e003826f", "142929670a0e6e70", "27b70a8546d22ffc", ... 
     "2e1b21385c26c926", "4d2c6dfc5ac42aed", "53380d139d95b3df", ...
     "650a73548baf63de", "766a0abb3c77b2a8", "81c2c92e47edaee6", ...
     "92722c851482353b", "a2bfe8a14cf10364", "a81a664bbc423001", ...
     "c24b8b70d0f89791", "c76c51a30654be30", "d192e819d6ef5218", ...
     "d69906245565a910", "f40e35855771202a", "106aa07032bbd1b8", ...
     "19a4c116b8d2d0c8", "1e376c085141ab53", "2748774cdf8eeb99", ...
     "34b0bcb5e19b48a8", "391c0cb3c5c95a63", "4ed8aa4ae3418acb", ...
     "5b9cca4f7763e373", "682e6ff3d6b2b8a3", "748f82ee5defb2fc", ...
     "78a5636f43172f60", "84c87814a1f0ab72", "8cc702081a6439ec", ...
     "90befffa23631e28", "a4506cebde82bde9", "bef9a3f7b2c67915", ...
     "c67178f2e372532b", "ca273eceea26619c", "d186b8c721c0c207", ...
     "eada7dd6cde0eb1e", "f57d4f7fee6ed178", "06f067aa72176fba", ...
     "0a637dc5a2c898a6", "113f9804bef90dae", "1b710b35131c471b", ...
     "28db77f523047d84", "32caab7b40c72493", "3c9ebe0a15c9bebc", ...
     "431d67c49c100d4c", "4cc5d4becb3e42b6", "597f299cfc657e2a", ...
     "5fcb6fab3ad6faec", "6c44198c4a475817"];

 %W_t
 W = zeros(80, 64);
for q = 1 : (numel(W_f) / 1024)
 for j = 1 : 80
    
     
     
     if j <= 16
         W(j, :) = W_f(j + 16 * (q - 1), :);
     else
         delta_0 = xor(xor(fn_ROTR(W(j - 15, :), 1), fn_ROTR(W(j - 15, :), 8)), fn_SHR(W(j - 15, :), 7));
         delta_1 = xor(xor(fn_ROTR(W(j - 2, :), 19), fn_ROTR(W(j - 2, :), 61)), fn_SHR(W(j - 2, :), 6));
         A = fn_bit_add(delta_1, W(j - 7, :));
         B = fn_bit_add(delta_0, W(j - 16, :));
         W(j, :) = fn_bit_add(A, B);
     end
 end
 
%% 라운드 함수
for r = 1 : 80
    K = fn_hex2bin(char(hK(r)));
% T1
Ch = xor(fn_bit_and(e, f), fn_bit_and(fn_bit_comp(e), g));
Sigma1 = xor(xor(fn_ROTR(e, 14), fn_ROTR(e, 18)), fn_ROTR(e, 41));
T1 = fn_bit_add(fn_bit_add(fn_bit_add(fn_bit_add(h, Sigma1), Ch), K), W(r, :));

% T2
Maj = xor(fn_bit_and(b, c), xor(fn_bit_and(a, b), fn_bit_and(a, c)));
Sigma0 = xor(xor(fn_ROTR(a, 28), fn_ROTR(a, 34)), fn_ROTR(a, 39));
T2 = fn_bit_add(Sigma0, Maj);

% Round_0
h = g;
g = f;
f = e;
e = fn_bit_add(d, T1);
d = c;
c = b;
b = a;
a = fn_bit_add(T1, T2);


end
%% Final
a = fn_bit_add(f_a, a); 
b = fn_bit_add(f_b, b); 
c = fn_bit_add(f_c, c); 
d = fn_bit_add(f_d, d); 
e = fn_bit_add(f_e, e); 
f = fn_bit_add(f_f, f); 
g = fn_bit_add(f_g, g); 
h = fn_bit_add(f_h, h); 

f_a = a;
f_b = b;
f_c = c;
f_d = d;
f_e = e;
f_f = f;
f_g = g;
f_h = h;

end

fn_bin2hex(a)
fn_bin2hex(b)
fn_bin2hex(c)
fn_bin2hex(d)
fn_bin2hex(e)
fn_bin2hex(f)
fn_bin2hex(g)
fn_bin2hex(h)

a_h = fn_bin2hex(a);
b_h = fn_bin2hex(b);
c_h = fn_bin2hex(c);
d_h = fn_bin2hex(d);
e_h = fn_bin2hex(e);
f_h = fn_bin2hex(f);
g_h = fn_bin2hex(g);
h_h = fn_bin2hex(h);
    
hash(1 : 16) = a_h;
hash(17 : 32) = b_h;
hash(33 : 48) = c_h;
hash(49 : 64) = d_h;
hash(65 : 80) = e_h;
hash(81 : 96) = f_h;
hash(97 : 112) = g_h;
hash(113 : 128) = h_h;

file=fopen('hash_long.txt', 'w');
fprintf(file, '%s', hash);
fclose(file);

%% 사용된 함수

function y = fn_SHR(x, n)
N = length(x);
Z = zeros(n);
y = [Z(1 : n), x(1 : N - n)];
end

function y = fn_ROTR(x, n)
N = length(x);
y = [x(N - n + 1 : N), x(1 : N - n)];
end

function s = fn_bin2hex(b)
r = mod(length(b), 4);
if r == 0, x = b; else x = [zeros(1, 4 - r), b]; end
N = length(x);
s = [];
for i = 1 : 4 : N
    d = fn_bin2dec(x(i : i + 3));
    if d < 10
        s = [s, num2str(d)];
    else
        switch d
            case 10, s = [s, 'a'];
            case 11, s = [s, 'b'];
            case 12, s = [s, 'c'];
            case 13, s = [s, 'd'];
            case 14, s = [s, 'e'];
            case 15, s = [s, 'f'];
        end
    end
end
end % function end

function z = fn_bit_add(x, y)
% x, y : binary array with the same length 
c = zeros(1, length(x));
z = zeros(1, length(x));
for i = length(x) : -1 : 1
    tmp = x(i) + y(i) + c(i);
    if i ~= 1 && tmp > 1
        c(i - 1) = 1;
    end
    z(i) = mod(tmp, 2);
end
end

function y = fn_bin2dec(x)
y = 0;
N = length(x);
for i = 1 : N
    if x(i) == 1, y = y + 2^(N - i); end
end
end

function z = fn_bit_and(x, y)
% x, y : binary array with the same length 
z = zeros(1, length(x));
for i = 1 : length(x)
    if x(i) == 1 && y(i) == 1
        z(i) = 1;
    end
end
end

function y = fn_bit_comp(x)
% x : binary array 
y = zeros(1, length(x));
for i = 1 : length(x)
    if x(i) == 0
        y(i) = 1;
    end
end
end

function y = fn_dec2bin(x, m)
y = zeros(1, m);
for i = 1 : m
    if x-2^(m - i) < 0 
    else
        y(i) = 1;
        x = x-2^(m - i);
    end
end
end

function y = fn_hex2bin(str)
% change hexadecimal number to binary bits
N = length(str);
y = [];
for i = 1 : N
    if str(i) >= 48 && str(i) <= 57
        y = [y, fn_dec2bin(str2num(str(i)), 4)];
    elseif str(i) >= 97 && str(i) <= 102
        switch str(i)
            case 'a', y = [y, 1 0 1 0];
            case 'b', y = [y, 1 0 1 1];
            case 'c', y = [y, 1 1 0 0];
            case 'd', y = [y, 1 1 0 1];
            case 'e', y = [y, 1 1 1 0];
            case 'f', y = [y, 1 1 1 1];
        end
    elseif str(i) >= 65 && str(i) <= 70
        switch str(i)
            case 'A', y=[y, 1 0 1 0];
            case 'B', y=[y, 1 0 1 1];
            case 'C', y=[y, 1 1 0 0];
            case 'D', y=[y, 1 1 0 1];
            case 'E', y=[y, 1 1 1 0];
            case 'F', y=[y, 1 1 1 1];
        end        
    end
end
end % function end