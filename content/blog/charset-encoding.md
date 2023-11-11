---
title: Character Sets and Encodings
description: ASCII, UNICODE, UTF-8, Base64
date: 2023-11-12
tags:
  - computer science
layout: layouts/post.njk
---

## ASCII
- [RFC 20 ASCII format for Network Interchange](https://datatracker.ietf.org/doc/html/rfc20)
- ASCII is a character set
   -  Codes 0-31 are unprintable control codes and are used to control peripherals such as printers.
   - Codes 32-127 are called printable characters, they are for all the [different variations of the ASCII table](#eascii)
- use 8 bits to represent individual characters. (7-bit in early age)
- [HTTP 1.1](https://datatracker.ietf.org/doc/html/rfc2616) uses `US-ASCII` as basic character set for the [request line](https://datatracker.ietf.org/doc/html/rfc2616#section-4.2) in requests, the [status line](https://datatracker.ietf.org/doc/html/rfc2616#section-6.1.1) in responses (except the [reason phrase](https://datatracker.ietf.org/doc/html/rfc2616#section-6.1.1)) and the [field names](https://datatracker.ietf.org/doc/html/rfc2616#section-4.2) but allows any octet in the field values and the [message body](https://datatracker.ietf.org/doc/html/rfc2616#section-4.3).

### EASCII
-  extended ASCII codes

## UNICODE
- [RFC 5198: Unicode Format for Network Interchange](https://www.rfc-editor.org/rfc/rfc5198)
- [unicode org](https://home.unicode.org/)
- > The Unicode Standard refers to the standard character set that represents all natural language characters. Unicode can encode up to roughly 1.1 million characters, allowing it to support all of the world’s languages and scripts in a single, universal standard.
- UNICODE is `ASCII` compatible (`U+0000` to `U+007F`)



## UTF-8
- [RFC 3629: UTF-8, a transformation format of ISO 10646](https://datatracker.ietf.org/doc/html/rfc3629)
- UTF-8 is defined by the Unicode Standard [[UNICODE](https://datatracker.ietf.org/doc/html/rfc3629#ref-UNICODE)]
- In UTF-8, characters from the `U+0000..U+10FFFF` range  are encoded using sequences of 1 to 4 octets.
```
   Char. number range  |        UTF-8 octet sequence
      (hexadecimal)    |              (binary)
   --------------------+------------------------------------
   0000 0000-0000 007F | 0xxxxxxx
   0000 0080-0000 07FF | 110xxxxx 10xxxxxx
   0000 0800-0000 FFFF | 1110xxxx 10xxxxxx 10xxxxxx
   0001 0000-0010 FFFF | 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
```
### Example
- HTML header: `Content-Type: text/plain; charset="UTF-8"`
- Golang: [Rune literals](https://go.dev/ref/spec#Source_code_representation) use UTF-8
- Rust: [Struct std::string::String](https://doc.rust-lang.org/std/string/struct.String.html) A UTF-8–encoded, growable string.

## Base64
- RFC: [rfc4648#section-4](https://datatracker.ietf.org/doc/html/rfc4648#section-4)
- 24 bits byte sequence can be represented by four **6-bit Base64 digits**.
    - 4 chars are used to represent `4 * 6 = 24 bits = 3 bytes` (if we ignore the [padding](https://datatracker.ietf.org/doc/html/rfc4648#section-3.2) and round-up detail)
    - 3-char string will become 4-char string after the encoding, which the means size will increase by about 33%.

- Used when there was a need to encode **binary data** so that it can be stored and transferred over mediums that primarily designed to deal with ASCII text. E-Mail attachments are sent out as base64 encoded strings.
- IS: case sensitive
- In Unix system, [crypt()](https://en.wikipedia.org/wiki/Crypt_(C)) uses a special Base64-type of encoding. It uses `./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz` to encode the hashed password.

### Example:
- In binary, "cat" is `01100011 01100001 01110100` ( 3 bytes)
- base 64 "cat" would be 
    ```
    011000 110110 000101 110100
    |      |      |      |
    Y      2      F      0
    ```

### Example - Generate random password
> Language-specific characters are typically avoided by password generators because they would not be universally available (US keyboards don't have accented characters, for instance). So don't take their omission from these tools as an indication that they might be weak or problematic.
    - [Is it bad to use special characters in passwords? [duplicate]](https://security.stackexchange.com/questions/225346/is-it-bad-to-use-special-characters-in-passwords)
```go
package main
import (
	"crypto/rand"
	"encoding/base64"
	"fmt"
	"log"
)

func main() {
	buf := make([]byte, 32)
	_, err := rand.Read(buf)
	if err != nil {
		log.Fatalf("error while generating random string: %s", err)
	}
	// fmt.Println(string(buf)) // not printable

	printable_password := base64.StdEncoding.EncodeToString(buf)
	fmt.Println("generated password", printable_password)
}

```

## Base64Url
- [RFC4648: Section 5: Base 64 Encoding with URL and Filename Safe Alphabet](https://datatracker.ietf.org/doc/html/rfc4648#section-5)
- [standard Base64](#base64) uses `+` and `/` for the last 2 characters, and `=` for padding.
- Base64Url uses `-` and `_` for the last 2 characters, and makes padding optional.
### Usage
- If the Base64-encoded text needs to be transmitted/saved where `+`, `/`, or `=` have special meaning, e.g. in URLs where all 3 does, then it is better to use `Base64Url`.
- If the Base64-encoded text needs to be transmitted/saved where `-` or `_` have special meaning, then it is better to use Standard Base64.


### Ref
- [Youtube:  Unicode, in friendly terms: ASCII, UTF-8, code points, character encodings, and more ](https://youtu.be/ut74oHojxqo?si=XBBGiFS1kw4Q7Mj2)
- [Why is a base 64 encoded file 33% larger than the original?](https://bharatkalluri.com/posts/base64-size-increase-explanation)
- [The Absolute Minimum Every Software Developer Absolutely, Positively Must Know About Unicode and Character Sets (No Excuses!)](https://www.joelonsoftware.com/2003/10/08/the-absolute-minimum-every-software-developer-absolutely-positively-must-know-about-unicode-and-character-sets-no-excuses/)