function [ vector ] = generate_alphabet_vector(vector_size)
%GENERATE_ALPHABEL_VECTOR generates a cell array with letters:
% A, ..., Z, AA, ..., AZ, ..., ZZ

    vector = {};
    if vector_size > 702
        return;
    end
    
    alpha_vector = char('A'+(1:26)-1)';
    k = 0;
    L = 0;
    for i = 1:vector_size
        if k <= 25 && L == 0
            letter = char('A' + k);
            k = k + 1;
        else
            if k > 25
                k = 0;
                L = L + 1;
            end
            letter = char('A' + k);
            letter = strcat(alpha_vector(L),letter);
            k = k + 1;
        end    
        vector = [vector , letter];
    end
end

