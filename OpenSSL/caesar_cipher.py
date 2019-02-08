import string

def reverse_dict(d):
    return {v:k for k,v in d.items()}

def simplify_n(number, max_n):
    """
    this should simply or adapt secret numbers
    """
    n = abs(number)
    while max_n % n:
        if n - max_n < 0:
            return n
        n -= max_n
    if number < 0:
        return -n
    return n

def ord_map(letters=string.printable, reverse=False):
    """letters is upper and lower case ascii by default"""
    ord_chars = dict()
    for char in letters:
        ord_chars[char] = ord(char)
    if reverse:
        return reverse_dict(ord_chars)
    return ord_chars

def get_shifted(offset, chars=string.printable, reverse=False):
    """
    offset can be negative or positive integer
    char_map is the char table
    """
    assert isinstance(offset, int)
    char_map = ord_map(chars)
    len_char_map = len(char_map)
    char_n_list = sorted(list(char_map.values()))
    offset = simplify_n(offset, len(chars))
    shifted_ord_chars = dict()
    for char,number in char_map.items():
        shifted_pos = char_n_list.index(number) + offset
        if shifted_pos in range(len_char_map):
            shifted_ord_chars[char] = char_n_list[shifted_pos]
        else:
            if shifted_pos < 0:
                shifted_ord_chars[char] = char_n_list[shifted_pos]
            else:
                pos = shifted_pos - len_char_map
                shifted_ord_chars[char] = char_n_list[pos]
    if reverse:
        return reverse_dict(shifted_ord_chars)
    return shifted_ord_chars

def crypt(text, secret, chars=string.printable):
    enc_map = get_shifted(secret, ord_map(chars))
    try:
        l = [ord_map(chars, reverse=1)[p] for p in [enc_map[i] for i in text]]
    except Exception as e:
        print(e)
        raise ValueError('element not available in char map')
    return ''.join(l)

def decrypt(text, secret, chars=string.printable):
    enc_map = get_shifted(secret, chars, reverse=1)
    l = [enc_map[ord(i)] for i in text]
    return ''.join(l)


if __name__ == '__main__':
    text = "Frasi sconcie ma che facciano ridere, tipo 'vulva'."
    secret = -5

    enc_text = crypt(text, secret)
    print(enc_text)

    dec_text = decrypt(enc_text, secret)
    print(dec_text)
