function hash = hash_combine( seed, val )
%HASH_COMBINE Summary of this function goes here
    % matlab quirks -> it deals with overflow differently than the rest of the world
    % so we compute in 64bits and then back convert to 32bits
    tmp = uint64(val) + uint64(2654435769) + uint64(bitshift(seed, 6, 'uint32') + bitshift(seed, -2, 'uint32')); % magic number is  == 0x9e3779b9
    hash = bitxor(seed, uint32(mod(tmp, 2^32)), 'uint32');
end