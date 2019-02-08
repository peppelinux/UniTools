import string

def reverse_dict(d):
    r = {}
    for k,v in d.items():
        r[v] = k
    return r

def ord_map(letters = string.printable, reverse=False):
    """letters is upper and lower case ascii by default"""
    ord_chars = dict()
    for char in letters:
        ord_chars[char] = ord(char)
    if reverse:
        return reverse_dict(ord_chars)
    return ord_chars


def get_shifted(offset, chars, reverse=False):
    """
    offset can be negative or positive integer
    char_map is ascii mapped to numbers by default
    """
    assert isinstance(offset, int)
    char_map = ord_map(chars)
    len_char_map = len(char_map)
    char_n_list = sorted(list(char_map.values()))

    bound = int(len_char_map)
    if abs(offset) > bound:
        # raise ValueError('offset must be lower than {}'.format(bound))
        offset = offset - int(len_char_map)
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


def crypt(text, secret, chars):
    enc_map = get_shifted(secret, ord_map(chars))
    try:
        l = [ord_map(chars, reverse=1)[p] for p in [enc_map[i] for i in text]]
    except Exception as e:
        print(e)
        raise ValueError('element not available in char map')
    return ''.join(l)


def decrypt(text, secret, chars):
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
