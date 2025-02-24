use dep::std::println;

global UPPERCASE_A_INDEX: u8 = 65;
global UPPERCASE_Z_INDEX: u8 = 90;
global LOWERCASE_A_INDEX: u8 = 97;
global LOWERCASE_Z_INDEX: u8 = 122;
global ZERO_INDEX: u8 = 48;
global NINE_INDEX: u8 = 57;
global ASCII_TABLE_START_INDEX: u8 = 0;
global SORTED_ASCII_TABLE: [str<1>; 127] = [    
    "\0","\0","\0","\0","\0","\0","\0","\0","\0","\t","\n","\0","\0","\r","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0",
    " ","!","\"","#","$","%","&","'","(",")","*","+",",","-",".","/",
    "0","1","2","3","4","5","6","7","8","9",
    ":",";","<","=",">","?","@",
    "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
    "[","\\","]","^","_","`",
    "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
    "{","|","}","~"
];

// Functions 
fn code_at<let N: u32>(s: str<N>, index: u64) -> u8 {
    assert(index < N as u64);
    s.as_bytes()[index]
}

fn char_at<let N: u32>(s: str<N>, index: u64) -> str<1> {
    let byte = code_at(s, index);
    let ascii_index = byte - ASCII_TABLE_START_INDEX;
    SORTED_ASCII_TABLE[ascii_index]
}

fn index_of<let N: u32, let M: u32>(s: str<N>, substr: str<M>) -> i64 {
    assert(M <= N, "Substring length must be less than or equal to string length");
    let substr_bytes = substr.as_bytes();
    let str_bytes = s.as_bytes();
    let mut index = -1 as i64;
    // To keep track of how many characters of the substring
    // have been found
    let mut match_count = 0;
    for i in 0..N {
        // If the current character matches the first character of the substring
        // and the index is not set, then set the index to the current index
        if (index == -1) & (str_bytes[i] == substr_bytes[0]) {
            index = i as i64;
            match_count += 1;
        } else if (index != -1) & (i as i64 - index < M as i64) {
            if (str_bytes[i] != substr_bytes[i as i64 - index]) {
                // If any of the subsequent characters don't match, reset the index
                // as this means it's not the right substring
                if (str_bytes[i] == substr_bytes[0]) {
                    // If the current character matches the first character
                    // of the substring, then set the index to the current
                    index = i as i64;
                    match_count = 1;
                } else {
                    // Otherwise, reset the index
                    index = -1;
                    match_count = 0;
                }
            } else {
                // Here the characters match, so we increment the match count
                match_count += 1;
            }
        }
    }

    // If the match count is not equal to the length of the substring,
    // then the substring is not in the string
    // Can happen when looking at a substring that is at the end of the string
    // but the match is only partial
    if match_count != M {
        index = -1;
    }

    index
}

fn last_index_of<let N: u32, let M: u32>(s: str<N>, substr: str<M>) -> i64 {
    assert(M <= N, "Substring length must be less than or equal to string length");
    let substr_bytes = substr.as_bytes();
    let str_bytes = s.as_bytes();
    let mut temp_index = -1 as i64;
    let mut final_index = -1 as i64;
    // To keep track of how many characters of the substring
    // have been found
    let mut match_count = 0;
    for i in 0..N {
        if (match_count == M) {
            final_index = temp_index;
            temp_index = -1;
            match_count = 0;
        }

        // If the current character matches the first character of the substring
        // and the index is not set, then set the index to the current index
        if (temp_index == -1) & (str_bytes[i] == substr_bytes[0]) {
            temp_index = i as i64;
            match_count += 1;
        } else if (temp_index != -1) & (i as i64 - temp_index < M as i64) {
            if (str_bytes[i] != substr_bytes[i as i64 - temp_index]) {
                // If any of the subsequent characters don't match, reset the index
                // as this means it's not the right substring
                if (str_bytes[i] == substr_bytes[0]) {
                    // If the current character matches the first character
                    // of the substring, then set the index to the current
                    temp_index = i as i64;
                    match_count = 1;
                } else {
                    // Otherwise, reset the index
                    temp_index = -1;
                    match_count = 0;
                }
            } else {
                // Here the characters match, so we increment the match count
                match_count += 1;
            }
        }
    }

    if (match_count == M) & (temp_index != -1) {
        final_index = temp_index;
    }

    final_index
}

// We use Field instead of integers for the Vector here as integers 
// don't seem to work well with Vectors at the moment
fn indexes_of<let N: u32, let M: u32>(s: str<N>, substr: str<M>) -> Vec<Field> {
    assert(M <= N, "Substring length must be less than or equal to string length");
    let substr_bytes = substr.as_bytes();
    let str_bytes = s.as_bytes();
    let mut temp_index = -1 as i64;
    // To keep track of how many characters of the substring
    // have been found
    let mut match_count = 0;
    let mut indexes: Vec<Field> = Vec::new();
    for i in 0..N {
        if (match_count == M) {
            indexes.push(temp_index as Field);
            temp_index = -1;
            match_count = 0;
        }

        // If the current character matches the first character of the substring
        // and the index is not set, then set the index to the current index
        if (temp_index == -1) & (str_bytes[i] == substr_bytes[0]) {
            temp_index = i as i64;
            match_count += 1;
        } else if (temp_index != -1) & (i as i64 - temp_index < M as i64) {
            if (str_bytes[i] != substr_bytes[i as i64 - temp_index]) {
                // If any of the subsequent characters don't match, reset the index
                // as this means it's not the right substring
                if (str_bytes[i] == substr_bytes[0]) {
                    // If the current character matches the first character
                    // of the substring, then set the index to the current
                    temp_index = i as i64;
                    match_count = 1;
                } else {
                    // Otherwise, reset the index
                    temp_index = -1;
                    match_count = 0;
                }
            } else {
                // Here the characters match, so we increment the match count
                match_count += 1;
            }
        }
    }

    if (match_count == M) & (temp_index != -1) {
        indexes.push(temp_index as Field);
    }

    indexes
}

fn contains<let N: u32, let M: u32>(s: str<N>, substr: str<M>) -> bool {
    index_of(s, substr) != -1
}

fn occurrences_of<let N: u32, let M: u32>(s: str<N>, substr: str<M>) -> u64 {
    assert(M <= N, "Substring length must be less than or equal to string length");
    let substr_bytes = substr.as_bytes();
    let str_bytes = s.as_bytes();
    let mut temp_index = -1 as i64;
    // To keep track of how many characters of the substring
    // have been found
    let mut match_count = 0;
    let mut occurrences = 0;
    for i in 0..N {
        if (match_count == M) {
            temp_index = -1;
            match_count = 0;
            occurrences += 1;
        }

        // If the current character matches the first character of the substring
        // and the index is not set, then set the index to the current index
        if (temp_index == -1) & (str_bytes[i] == substr_bytes[0]) {
            temp_index = i as i64;
            match_count += 1;
        } else if (temp_index != -1) & (i as i64 - temp_index < M as i64) {
            if (str_bytes[i] != substr_bytes[i as i64 - temp_index]) {
                // If any of the subsequent characters don't match, reset the index
                // as this means it's not the right substring
                if (str_bytes[i] == substr_bytes[0]) {
                    // If the current character matches the first character
                    // of the substring, then set the index to the current
                    temp_index = i as i64;
                    match_count = 1;
                } else {
                    // Otherwise, reset the index
                    temp_index = -1;
                    match_count = 0;
                }
            } else {
                // Here the characters match, so we increment the match count
                match_count += 1;
            }
        }
    }

    if (match_count == M) & (temp_index != -1) {
        occurrences += 1;
    }

    occurrences
}

fn digit_at<let N: u32>(s: str<N>, index: u64) -> u8 {
    let byte = s.as_bytes()[index];
    assert((byte >= ZERO_INDEX) & (byte <= NINE_INDEX), "Character is not a digit");
    byte - ZERO_INDEX
}

fn hex_digit_at<let N: u32>(s: str<N>, index: u64) -> u8 {
    let byte = s.as_bytes()[index];
    if (byte >= ZERO_INDEX) & (byte <= NINE_INDEX) {
        byte - ZERO_INDEX
    } else if (byte >= UPPERCASE_A_INDEX) & (byte <= UPPERCASE_Z_INDEX) {
        byte - UPPERCASE_A_INDEX + 10
    } else if (byte >= LOWERCASE_A_INDEX) & (byte <= LOWERCASE_Z_INDEX) {
        byte - LOWERCASE_A_INDEX + 10
    } else {
        assert(false, "Character is not a hex digit");
        0
    }
}

fn to_uint_slice<let N: u32>(s: str<N>, start: u64, end: u64) -> u64 {
    let mut result = 0;
    for i in start..end {
        let digit = digit_at(s, i);
        result = result * 10 + digit as u64;
    }
    result
}

fn to_uint<let N: u32>(s: str<N>) -> u64 {
    to_uint_slice(s, 0, N as u64)
}

fn to_int<let N: u32>(s: str<N>) -> i64 {
    if char_at(s, 0) == "-" {
        -1 * to_uint_slice(s, 1, N as u64) as i64
    } else {
        to_uint_slice(s, 0, N as u64) as i64
    }
}

fn from_hex_to_uint_slice<let N: u32>(s: str<N>, start: u64, end: u64) -> u64 {
    let mut result = 0;
    for i in start..end {
        let digit = hex_digit_at(s, i);
        result = result * 16 + digit as u64;
    }
    result
}

fn from_hex_to_uint<let N: u32>(s: str<N>, with_prefix: bool) -> u64 {
    if with_prefix {
        from_hex_to_uint_slice(s, 2, N as u64)
    } else {
        from_hex_to_uint_slice(s, 0, N as u64)
    }
}

fn to_array_of_chars<let N: u32>(s: str<N>) -> [str<1>; N] {
    let mut result: [str<1>; N] = [" "; N];
    for i in 0..N {
        result[i] = char_at(s, i as u64);
    }
    result
}

// Struct

struct String<let N: u32> {
    value: str<N>,
    len: u64,
}

// Implementation over String struct

impl<let N: u32> String<N> {
    fn new(value: str<N>) -> Self {
        Self { value, len: N as u64 }
    }

    fn code_at(self: Self, index: u64) -> u8 {
        code_at(self.value, index)
    }

    fn char_at(self: Self, index: u64) -> str<1> {
        char_at(self.value, index)
    }

    fn index_of<let M: u32>(self: Self, substr: str<M>) -> i64 {
        index_of(self.value, substr)
    }

    fn last_index_of<let M: u32>(self: Self, substr: str<M>) -> i64 {
        last_index_of(self.value, substr)
    }

    fn indexes_of<let M: u32>(self: Self, substr: str<M>) -> Vec<Field> {
        indexes_of(self.value, substr)
    }

    fn contains<let M: u32>(self: Self, substr: str<M>) -> bool {
        contains(self.value, substr)
    }

    fn occurrences_of<let M: u32>(self: Self, substr: str<M>) -> u64 {
        occurrences_of(self.value, substr)
    }

    fn digit_at(self: Self, index: u64) -> u8 {
        digit_at(self.value, index)
    }

    fn hex_digit_at(self: Self, index: u64) -> u8 {
        hex_digit_at(self.value, index)
    }

    fn to_uint_slice(self: Self, start: u64, end: u64) -> u64 {
        to_uint_slice(self.value, start, end)
    }

    fn to_uint(self: Self) -> u64 {
        to_uint_slice(self.value, 0, self.len)
    }

    fn to_int(self: Self) -> i64 {
        to_int(self.value)
    }

    fn from_hex_to_uint_slice(self: Self, start: u64, end: u64) -> u64 {
        from_hex_to_uint_slice(self.value, start, end)
    }

    fn from_hex_to_uint(self: Self, with_prefix: bool) -> u64 {
        from_hex_to_uint(self.value, with_prefix)
    }

    fn to_array_of_chars(self: Self) -> [str<1>; N] {
        to_array_of_chars(self.value)
    }
}

// Trait
trait StringTrait {
    fn code_at(self, index: u64) -> u8;
    fn char_at(self, index: u64) -> str<1>;
    fn index_of<let M: u32>(self, substr: str<M>) -> i64;
    fn last_index_of<let M: u32>(self, c: str<M>) -> i64;
    fn indexes_of<let M: u32>(self, c: str<M>) -> Vec<Field>;
    fn contains<let M: u32>(self, substr: str<M>) -> bool;
    fn occurrences_of<let M: u32>(self, c: str<M>) -> u64;
    fn digit_at(self, index: u64) -> u8;
    fn hex_digit_at(self, index: u64) -> u8;
    fn to_uint_slice(self, start: u64, end: u64) -> u64;
    fn to_uint(self) -> u64;
    fn to_int(self) -> i64;
    fn from_hex_to_uint_slice(self, start: u64, end: u64) -> u64;
    fn from_hex_to_uint(self, with_prefix: bool) -> u64;
}

// Implementation for str type
impl<let N: u32> StringTrait for str<N> {
    fn code_at(self: Self, index: u64) -> u8 {
        code_at(self, index)
    }

    fn char_at(self: Self, index: u64) -> str<1> {
        char_at(self, index)
    }

    fn index_of<let M: u32>(self: Self, substr: str<M>) -> i64 {
        index_of(self, substr)
    }

    fn last_index_of<let M: u32>(self: Self, substr: str<M>) -> i64 {
        last_index_of(self, substr)
    }

    fn indexes_of<let M: u32>(self: Self, substr: str<M>) -> Vec<Field> {
        indexes_of(self, substr)
    }

    fn contains<let M: u32>(self: Self, substr: str<M>) -> bool {
        contains(self, substr)
    }

    fn occurrences_of<let M: u32>(self: Self, substr: str<M>) -> u64 {
        occurrences_of(self, substr)
    }

    fn digit_at(self: Self, index: u64) -> u8 {
        digit_at(self, index)
    }

    fn hex_digit_at(self: Self, index: u64) -> u8 {
        hex_digit_at(self, index)
    }

    fn to_uint_slice(self: Self, start: u64, end: u64) -> u64 {
        to_uint_slice(self, start, end)
    }

    fn to_uint(self: Self) -> u64 {
        to_uint_slice(self, 0, N as u64)
    }

    fn to_int(self: Self) -> i64 {
        to_int(self)
    }

    fn from_hex_to_uint_slice(self: Self, start: u64, end: u64) -> u64 {
        from_hex_to_uint_slice(self, start, end)
    }

    fn from_hex_to_uint(self: Self, with_prefix: bool) -> u64 {
        from_hex_to_uint(self, with_prefix)
    }
}

// Tests for String struct
#[test]
fn test_init() {
    let s = String::new("hello");
    assert(s.len == 5);
    assert(s.value == "hello");
}

#[test]
fn test_char_at() {
    let s = String::new("hello");
    assert(s.char_at(0) == "h");
    assert(s.char_at(1) == "e");
    assert(s.char_at(2) == "l");
    assert(s.char_at(3) == "l");
    assert(s.char_at(4) == "o");
}

#[test]
fn test_code_at() {
    let s = String::new("hello");
    assert(s.code_at(0) == 104);
    assert(s.code_at(1) == 101);
    assert(s.code_at(2) == 108);
    assert(s.code_at(3) == 108);
    assert(s.code_at(4) == 111);
}

#[test]
fn test_index_of() {
    let s = String::new("hello");
    // Characters
    assert(s.index_of("h") == 0);
    assert(s.index_of("e") == 1);
    assert(s.index_of("l") == 2);
    assert(s.index_of("o") == 4);
    assert(s.index_of("a") == -1);

    // Substrings
    assert(s.index_of("he") == 0);
    assert(s.index_of("el") == 1);
    assert(s.index_of("ll") == 2);
    assert(s.index_of("lo") == 3);
    assert(s.index_of("hello") == 0);
    assert(s.index_of("ow") == -1);

    let sentence = String::new("some sentence with some repetition");
    assert(sentence.index_of("some") == 0);
    assert(sentence.index_of("sentence") == 5);
    assert(sentence.index_of("with") == 14);
    assert(sentence.index_of("repetition") == 24);
    assert(sentence.index_of("some sentence with some repetition") == 0);
    assert(sentence.index_of("ti") == 28);
}

#[test]
fn test_last_index_of() {
    let s = String::new("hello");
    assert(s.last_index_of("h") == 0);
    assert(s.last_index_of("e") == 1);
    assert(s.last_index_of("l") == 3);
    assert(s.last_index_of("o") == 4);
    assert(s.last_index_of("a") == -1);

    // Substrings
    assert(s.last_index_of("he") == 0);
    assert(s.last_index_of("el") == 1);
    assert(s.last_index_of("ll") == 2);
    assert(s.last_index_of("lo") == 3);
    assert(s.last_index_of("hello") == 0);
    assert(s.last_index_of("ow") == -1);

    let sentence = String::new("some sentence with some repetition");
    assert(sentence.last_index_of("some") == 19);
    assert(sentence.last_index_of("sentence") == 5);
    assert(sentence.last_index_of("with") == 14);
    assert(sentence.last_index_of("repetition") == 24);
    assert(sentence.last_index_of("some sentence with some repetition") == 0);
    assert(sentence.last_index_of("ti") == 30);
}

#[test]
fn test_indexes_of() {
    let s = String::new("hello");
    assert(s.indexes_of("h").get(0) == 0);
    assert(s.indexes_of("e").get(0) == 1);
    assert(s.indexes_of("l").get(0) == 2);
    assert(s.indexes_of("l").get(1) == 3);
    assert(s.indexes_of("o").get(0) == 4);
    assert(s.indexes_of("a").len() == 0);

    let sentence = String::new("some sentence with some repetition");
    assert(sentence.indexes_of("some").get(0) == 0);
    assert(sentence.indexes_of("some").get(1) == 19);
    assert(sentence.indexes_of("sentence").get(0) == 5);
    assert(sentence.indexes_of("with").get(0) == 14);
    assert(sentence.indexes_of("repetition").get(0) == 24);
    assert(sentence.indexes_of("some sentence with some repetition").get(0) == 0);
    assert(sentence.indexes_of("ti").get(0) == 28);
    assert(sentence.indexes_of("ti").get(1) == 30);
    assert(sentence.indexes_of("a").len() == 0);
}

#[test]
fn test_contains() {
    let s = String::new("hello");
    assert(s.contains("h"));
    assert(s.contains("e"));
    assert(s.contains("l"));
    assert(s.contains("o"));
    assert(!s.contains("a"));

    let sentence = String::new("some sentence with some repetition");
    assert(sentence.contains("some"));
    assert(sentence.contains("sentence"));
    assert(sentence.contains("with"));
    assert(sentence.contains("repetition"));
    assert(sentence.contains("ti"));
    assert(!sentence.contains("hello"));
    assert(!sentence.contains("a"));
}

#[test]
fn test_occurrences_of() {
    let s = String::new("hello");
    assert(s.occurrences_of("h") == 1);
    assert(s.occurrences_of("e") == 1);
    assert(s.occurrences_of("l") == 2);
    assert(s.occurrences_of("o") == 1);
    assert(s.occurrences_of("a") == 0);

    let sentence = String::new("some sentence with some repetition");
    assert(sentence.occurrences_of("some") == 2);
    assert(sentence.occurrences_of("sentence") == 1);
    assert(sentence.occurrences_of("with") == 1);
    assert(sentence.occurrences_of("repetition") == 1);
    assert(sentence.occurrences_of("ti") == 2);
    assert(sentence.occurrences_of("hello") == 0);
    assert(sentence.occurrences_of("a") == 0);
}

#[test]
fn test_digit_at() {
    let s = String::new("20231219");
    assert(s.digit_at(0) == 2);
    assert(s.digit_at(1) == 0);
    assert(s.digit_at(2) == 2);
    assert(s.digit_at(3) == 3);
    assert(s.digit_at(4) == 1);
    assert(s.digit_at(5) == 2);
    assert(s.digit_at(6) == 1);
    assert(s.digit_at(7) == 9);
}

#[test]
fn test_hex_digit_at() {
    let s = String::new("0x1324ABCDEF");
    assert(s.hex_digit_at(2) == 1);
    assert(s.hex_digit_at(3) == 3);
    assert(s.hex_digit_at(4) == 2);
    assert(s.hex_digit_at(5) == 4);
    assert(s.hex_digit_at(6) == 10);
    assert(s.hex_digit_at(7) == 11);
    assert(s.hex_digit_at(8) == 12);
    assert(s.hex_digit_at(9) == 13);
    assert(s.hex_digit_at(10) == 14);
    assert(s.hex_digit_at(11) == 15);
}

#[test]
fn test_to_uint() {
    let s = String::new("20231219");
    assert(s.to_uint() == 20231219);
}

#[test]
fn test_to_int() {
    let s = String::new("-25");
    assert(s.to_int() == -25);

    let s = String::new("25");
    assert(s.to_int() == 25);
}

#[test]
fn test_to_uint_slice() {
    let s = String::new("2023/12/19");
    assert(s.to_uint_slice(0, 4) == 2023);
    assert(s.to_uint_slice(5, 7) == 12);
    assert(s.to_uint_slice(8, 10) == 19);
}

#[test]
fn test_from_hex_to_uint_slice() {
    let s = String::new("0x1324ABCDEF");
    assert(s.from_hex_to_uint_slice(2, 6) == 0x1324);
    assert(s.from_hex_to_uint_slice(6, 9) == 0xABC);
    assert(s.from_hex_to_uint_slice(9, 12) == 0xDEF);
}

#[test]
fn test_from_hex_to_uint() {
    let uppercase_hex = String::new("0x1324ABCDEF");
    assert(uppercase_hex.from_hex_to_uint(true) == 0x1324ABCDEF);

    let lowercase_hex = String::new("0x1234abcdef");
    assert(lowercase_hex.from_hex_to_uint(true) == 0x1234ABCDEF);

    let hex_without_prefix = String::new("1234abcdef");
    assert(hex_without_prefix.from_hex_to_uint(false) == 0x1234ABCDEF);

    let hex_with_leading_zeros = String::new("0x000001");
    assert(hex_with_leading_zeros.from_hex_to_uint(true) == 1);
}

#[test]
fn test_to_array_of_chars() {
    let s = String::new("hello");
    let arr = s.to_array_of_chars();
    assert(arr[0] == "h");
    assert(arr[1] == "e");
    assert(arr[2] == "l");
    assert(arr[3] == "l");
    assert(arr[4] == "o");
}

// Tests for String trait
#[test]
fn test_trait_char_at() {
    let s = "hello";
    assert(s.char_at(0) == "h");
    assert(s.char_at(1) == "e");
    assert(s.char_at(2) == "l");
    assert(s.char_at(3) == "l");
    assert(s.char_at(4) == "o");
}

#[test]
fn test_trait_code_at() {
    let s = "hello";
    assert(s.code_at(0) == 104);
    assert(s.code_at(1) == 101);
    assert(s.code_at(2) == 108);
    assert(s.code_at(3) == 108);
    assert(s.code_at(4) == 111);
}

#[test]
fn test_trait_index_of() {
    let s = "hello";
    // Characters
    assert(s.index_of("h") == 0);
    assert(s.index_of("e") == 1);
    assert(s.index_of("l") == 2);
    assert(s.index_of("o") == 4);
    assert(s.index_of("a") == -1);

    // Substrings
    assert(s.index_of("he") == 0);
    assert(s.index_of("el") == 1);
    assert(s.index_of("ll") == 2);
    assert(s.index_of("lo") == 3);
    assert(s.index_of("hello") == 0);
    assert(s.index_of("ow") == -1);

    let sentence = "some sentence with some repetition";
    assert(sentence.index_of("some") == 0);
    assert(sentence.index_of("sentence") == 5);
    assert(sentence.index_of("with") == 14);
    assert(sentence.index_of("repetition") == 24);
    assert(sentence.index_of("some sentence with some repetition") == 0);
    assert(sentence.index_of("ti") == 28);
}

#[test]
fn test_trait_last_index_of() {
    let s = "hello";
    // Characters
    assert(s.last_index_of("h") == 0);
    assert(s.last_index_of("e") == 1);
    assert(s.last_index_of("l") == 3);
    assert(s.last_index_of("o") == 4);
    assert(s.last_index_of("a") == -1);

    // Substrings
    assert(s.last_index_of("he") == 0);
    assert(s.last_index_of("el") == 1);
    assert(s.last_index_of("ll") == 2);
    assert(s.last_index_of("lo") == 3);
    assert(s.last_index_of("hello") == 0);
    assert(s.last_index_of("ow") == -1);

    let sentence = "some sentence with some repetition";
    assert(sentence.last_index_of("some") == 19);
    assert(sentence.last_index_of("sentence") == 5);
    assert(sentence.last_index_of("with") == 14);
    assert(sentence.last_index_of("repetition") == 24);
    assert(sentence.last_index_of("some sentence with some repetition") == 0);
    assert(sentence.last_index_of("ti") == 30);
}

#[test]
fn test_trait_indexes_of() {
    let s = "hello";
    assert(s.indexes_of("h").get(0) == 0);
    assert(s.indexes_of("e").get(0) == 1);
    assert(s.indexes_of("l").get(0) == 2);
    assert(s.indexes_of("l").get(1) == 3);
    assert(s.indexes_of("o").get(0) == 4);
    assert(s.indexes_of("a").len() == 0);

    let sentence = "some sentence with some repetition";
    assert(sentence.indexes_of("some").get(0) == 0);
    assert(sentence.indexes_of("some").get(1) == 19);
    assert(sentence.indexes_of("sentence").get(0) == 5);
    assert(sentence.indexes_of("with").get(0) == 14);
    assert(sentence.indexes_of("repetition").get(0) == 24);
    assert(sentence.indexes_of("some sentence with some repetition").get(0) == 0);
    assert(sentence.indexes_of("ti").get(0) == 28);
    assert(sentence.indexes_of("ti").get(1) == 30);
    assert(sentence.indexes_of("a").len() == 0);
}

#[test]
fn test_trait_contains() {
    let s = "hello";
    assert(s.contains("h"));
    assert(s.contains("e"));
    assert(s.contains("l"));
    assert(s.contains("o"));
    assert(!s.contains("a"));

    let sentence = "some sentence with some repetition";
    assert(sentence.contains("some"));
    assert(sentence.contains("sentence"));
    assert(sentence.contains("with"));
    assert(sentence.contains("repetition"));
    assert(sentence.contains("ti"));
    assert(!sentence.contains("hello"));
    assert(!sentence.contains("a"));
}

#[test]
fn test_trait_occurrences_of() {
    let s = "hello";
    assert(s.occurrences_of("h") == 1);
    assert(s.occurrences_of("e") == 1);
    assert(s.occurrences_of("l") == 2);
    assert(s.occurrences_of("o") == 1);
    assert(s.occurrences_of("a") == 0);

    let sentence = "some sentence with some repetition";
    assert(sentence.occurrences_of("some") == 2);
    assert(sentence.occurrences_of("sentence") == 1);
    assert(sentence.occurrences_of("with") == 1);
    assert(sentence.occurrences_of("repetition") == 1);
    assert(sentence.occurrences_of("ti") == 2);
    assert(sentence.occurrences_of("hello") == 0);
    assert(sentence.occurrences_of("a") == 0);
}

#[test]
fn test_trait_digit_at() {
    let s = "20231219";
    assert(s.digit_at(0) == 2);
    assert(s.digit_at(1) == 0);
    assert(s.digit_at(2) == 2);
    assert(s.digit_at(3) == 3);
    assert(s.digit_at(4) == 1);
    assert(s.digit_at(5) == 2);
    assert(s.digit_at(6) == 1);
    assert(s.digit_at(7) == 9);
}

#[test]
fn test_trait_hex_digit_at() {
    let s = "0x1324ABCDEF";
    assert(s.hex_digit_at(2) == 1);
    assert(s.hex_digit_at(3) == 3);
    assert(s.hex_digit_at(4) == 2);
    assert(s.hex_digit_at(5) == 4);
    assert(s.hex_digit_at(6) == 10);
    assert(s.hex_digit_at(7) == 11);
    assert(s.hex_digit_at(8) == 12);
    assert(s.hex_digit_at(9) == 13);
    assert(s.hex_digit_at(10) == 14);
    assert(s.hex_digit_at(11) == 15);
}

#[test]
fn test_trait_to_uint() {
    let s = "20231219";
    assert(s.to_uint() == 20231219);
}

#[test]
fn test_trait_to_int() {
    let s = "-25";
    assert(s.to_int() == -25);

    let s = "25";
    assert(s.to_int() == 25);
}

#[test]
fn test_trait_to_uint_slice() {
    let s = "2023/12/19";
    assert(s.to_uint_slice(0, 4) == 2023);
    assert(s.to_uint_slice(5, 7) == 12);
    assert(s.to_uint_slice(8, 10) == 19);
}

#[test]
fn test_trait_from_hex_to_uint_slice() {
    let s = "0x1324ABCDEF";
    assert(s.from_hex_to_uint_slice(2, 6) == 0x1324);
    assert(s.from_hex_to_uint_slice(6, 9) == 0xABC);
    assert(s.from_hex_to_uint_slice(9, 12) == 0xDEF);
}

#[test]
fn test_trait_from_hex_to_uint() {
    let uppercase_hex = "0x1324ABCDEF";
    assert(uppercase_hex.from_hex_to_uint(true) == 0x1324ABCDEF);

    let lowercase_hex = "0x1234abcdef";
    assert(lowercase_hex.from_hex_to_uint(true) == 0x1234ABCDEF);

    let hex_without_prefix = "1234abcdef";
    assert(hex_without_prefix.from_hex_to_uint(false) == 0x1234ABCDEF);

    let hex_with_leading_zeros = "0x000001";
    assert(hex_with_leading_zeros.from_hex_to_uint(true) == 1);
}
