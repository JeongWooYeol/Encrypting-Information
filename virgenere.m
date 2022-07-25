fpt = fopen('v_plain.txt', 'r');
original_plain = fread(fpt);
fclose(fpt);
% 평문 읽어오기

N = length(original_plain);
temp = zeros(1, N);
j = 0;

% 대문자 소문자로
for i = 1 : N
    if (original_plain(i) >='A' && original_plain(i) <= 'Z') 
        j = j + 1;
        temp(j) = original_plain(i);
    elseif (original_plain(i) >= 'a' && original_plain(i) <= 'z') 
        j = j + 1;
        temp(j) = char(mod(original_plain(i) - 'a', 26) + 'A' );
    end
end
plain = temp(1:j);
N = length(plain);

key = ['s' 'e' 'c' 'u' 'r' 'i' 't' 'y'];
key_length = 8;

% 암호화 진행
cipher = zeros(1,N);
for i = 0 : key_length:N-1
    for k = 1 : key_length
        if(i + k <= N)
          cipher(i + k)=char(mod(plain(i + k) - 'A'+ (key(k) - 'a'), 26) + 'A');
        end
    end
end

% 생성한 암호문 v_cipher.txt에 작성
fpt = fopen('v_cipher.txt', 'w');
fprintf(fpt, '%s', cipher);
fclose(fpt);

% 암호문 불러오기
fpt = fopen('v_cipher.txt', 'r');
cipher = fread(fpt);
fclose(fpt);

%복호화 진행
N = length(cipher);
decrypt = zeros(1, N);
for i = 0 : key_length : N - 1
    for k = 1 : key_length
        if(i + k <= N)
        decrypt(i + k) = char(mod(cipher(i + k) - 'A' - (key(k) - 'a'), 26) + 'A' );
        end
    end
end

% 복호화된 문장 v_decrypt.txt에 작성
opt=fopen('v_decrypt.txt', 'w');
fprintf(opt,'%s',decrypt);
fclose(opt);  
