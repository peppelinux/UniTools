import string

def vigenere_matrix(chars=string.printable, debug=False):
    l = []
    for i in range(len(chars)):
         left = chars[i:]
         right = chars[:i]
         if debug:
             print('{}{}'.format(left, right))
         l.append([i for i in ''.join((left, right))])
    return l

def get_mapped_char(x, y, chars=string.ascii_uppercase+' '):
    l = vigenere_matrix_str(chars)
    return l[y][x]

def get_keystream(key, lenght):
    res = ''
    while len(res) < lenght:
        for char in key:
             if len(res) == lenght: break
             res += char
    return res

def get_mapped_position(char1, char2,
                        matrix, chars=string.printable):
    col = chars.index(char1)
    row = chars.index(char2)
    return matrix[col][row]

def get_reverse_position(char1, char2,
                         matrix, chars=string.printable):
    row = chars.index(char1)
    col = matrix[row].index(char2)
    return chars[col]

def crypt(text, key, chars=string.printable):
    res = ''
    keystream = get_keystream(key, len(text))
    matrix = vigenere_matrix(chars)
    for pos in range(len(text)):
        m = get_mapped_position(text[pos], keystream[pos], matrix, chars)
        res += m
        # print(text[pos], keystream[pos], m)
    return res

def decrypt(text, key, chars=string.printable):
    res = ''
    keystream = get_keystream(key, len(text))
    matrix = vigenere_matrix(chars)
    for pos in range(len(keystream)):
        m = get_reverse_position(keystream[pos], text[pos],
                                 matrix, chars)
        res += m
        # print(text[pos], keystream[pos], m)
    return res

if __name__ == '__main__':
    text = "ATTACK AT DAWN WITH SPACES"
    key = "avi mo ca si fforte".upper()

    crypted = crypt(text, key)
    decrypted = decrypt(crypted, key)
    print(crypted, decrypted)
