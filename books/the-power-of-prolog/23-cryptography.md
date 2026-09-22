# Cryptography with Prolog

## Introduction

Prolog has several features that make it extremely well-suited for **cryptographic** applications. For example, built-in [integer arithmetic](clpfd) that works for arbitrarily large numbers makes it easy to reason about large prime numbers and various operations on them that frequently arise in the context of cryptography. As another example, Prolog's built-in [search mechanism](15-sorting.md#searching) lets you easily experiment with brute-force attacks such as exhaustive search for keys, which has great didactic value. The Prolog [toplevel](03-concepts.md#toplevel) lets us interactively try various predicates and their parameters. And so on. Support for cryptographic algorithms varies between Prolog systems. In the following, we are using Scryer Prolog due to its [`library(crypto)`](https://codeberg.org/mthom/scryer-prolog/raw/master/src/lib/crypto.pl).

*Video*: [Cryptography with Prolog](https://www.metalevel.at/prolog/videos/cryptography)

In this text, we consider three aspects of cryptography that are extremely relevant in practice:

- [**hash functions**](#hash) that let us assess the [integrity](https://en.wikipedia.org/wiki/Data_integrity) of data
- [**digital signatures**](#signatures) to declare and assess the [authenticity](https://en.wikipedia.org/wiki/Authentication) of data
- [**symmetric encryption**](#symmetric-encryption) to ensure the [confidentiality](https://en.wikipedia.org/wiki/Confidentiality) of data.

We shall focus on the *practical* application of these methods, with sample code that you can try out and use. The methods I use in this document are all deemed at least *reasonably secure* in August 2026. **Beware** though: Make sure to follow best current practices when you use these methods in your own applications. This includes studying additional reference material and at least an introductory textbook on this subject. For example, consider reading [*Introduction to Modern Cryptography*](https://www.crcpress.com/Introduction-to-Modern-Cryptography-Second-Edition/Katz-Lindell/p/book/9781466570269) by Jonathan Katz and Yehuda Lindell, and the references included therein. The convention I use in this document is that information that ought to be kept *secret* is written in red.

## Data representation: characters, codes, bytes etc.

In Prolog, *lists of characters* are the preferred representation of text and also of binary data. The reason is that lists of characters can be represented very efficiently, and are amenable to reasoning with DCGs and built-in predicates for lists. Also, processing lists of characters leaves little trace in a system's *atom table*. These properties make lists of characters an ideal representation in cryptographic applications. A character is an *atom* of length 1. A list of characters is also called a *string*. Each character has a corresponding *code*, which is an integer. The standard predicate `char_code/2` relates a character to its code. In the following, we assume that the Prolog flag `double_quotes` is set to `chars`, which is the default and recommended setting in Scryer Prolog. It lets us write a string very compactly if we enclose it in double quotes. For example, the string `[a,b,c]` can be written more compactly as `"abc"`. Hexadecimal escape sequences can be used in strings to embed any character by its code. For example, the string `"\x0\\x12\\x2124\"` is the same term as the list `['\x0\','\x12\','\x2124\']`, namely a list with three characters with respective codes 0, 18 and 8484. Cryptographic methods typically work on *bytes*, and code points that are greater than 255 do not fit into a single byte. Therefore, many predicates in `library(crypto)` provide two different ways to reason about strings, specified via the `encoding/1` option:

- `encoding(`**`utf8`**`)` uses the UTF-8 encoding of the string as the sequence of bytes. This is the default.
- `encoding(`**`octet`**`)` works on the sequence of bytes that is specified by the *code* of each character in the list. Of course, this only works if all occurring characters have codes in the range 0..255.

There are conversion predicates that let us transform every Prolog term into a list of characters or bytes that can be processed with `library(crypto)`. For example, the standard predicate `atom_chars/2` relates an atom to a list of characters, and the predicate `chars_utf8bytes/2` from `library(charsio)` relates a list of characters to its UTF-8 encoding, specified as a list of bytes:

```prolog
?- atom_chars(κρυπτός, Cs).
   Cs = "κρυπτός".

?- chars_utf8bytes("κρυπτός", UTF8).
   UTF8 = [206,186,207,129,207,133,207,128,207,132|...].
    
```

In cryptographic applications, short lists of *bytes* also often need to be communicated to other programs and participants, and in these use cases it is common to represent such lists in *hexadecimal* notation. This means that each byte is represented by exactly two hexadecimal digits (between `0` and `F`) that are then stringed together. We can use **`hex_bytes/2`** to easily convert between these encodings:

```prolog
?- hex_bytes("501ACE", Bs).
   Bs = [80,26,206].

?- hex_bytes(Hex, [80,26,206]).
   Hex = "501ace".
    
```

To create a list of *cryptographically strong* pseudo-random bytes, we can use **`crypto_n_random_bytes/2`**. For example, here is a 256-bit (i.e., 32 bytes) sequence that in all likelihood nobody else has ever generated before me:

```prolog
?- crypto_n_random_bytes(32, Bs),
   hex_bytes(Key, Bs).
   Bs = [135,227,97,217,131,152,108,154,145,104|...],
   Key = "87e361d983986c9a91686ef90ccdedc22b852370612543ab99563ba92bd902b5"
    
```

Thus, we can easily generate strong keys and unique tokens when needed. To more compactly store and embed binary data in your applications, also consider Base64 encoding.

## Cryptographic hash functions

A [cryptographic hash function](https://en.wikipedia.org/wiki/Cryptographic_hash_function) lets us efficiently map data of *arbitrary* size to a bit string of *fixed* size in such a way that the mapping is infeasible to invert and collisions are very unlikely. Hash functions are needed in almost all applications of modern cryptography. In [`library(crypto)`](https://codeberg.org/mthom/scryer-prolog/raw/master/src/lib/crypto.pl), among the most important predicates for computing cryptographic hashes is `crypto_data_hash/3`. Here is an example (click on the hash to expand it):

```prolog
?- crypto_data_hash("Hello world!", Hash, [algorithm(blake2s256)]).
   Hash = "c63813a8f804abece06213a46acd04a2d738c8e7a58fbf94bfe066a9c7f89197".
    
```

We can use `hex_bytes/2` to convert such hex-encoded values to lists of *bytes*, by which we mean lists of integers between 0 and 255. For example:

```prolog
?- hex_bytes("c63813a8f804abece06213a46acd04a2d738c8e7a58fbf94bfe066a9c7f89197", Bytes).
   Bytes = [198,56,19,168,248,4,171,236,224,98|...].
    
```

*Security of default algorithms* is an important design principle of `library(crypto)`. For this reason, the only guarantee that the hash predicates give is that *the default algorithm is cryptographically secure*. The default may change in the future. To find out which algorithm was actually used, we can specify the `algorithm/1` option, and use a *variable* as argument. For example:

```prolog
?- crypto_data_hash("Hello world!", Hash, [algorithm(A)]).
   Hash = "c0535e4be2b79ffd93291305436bf889314e4a3faec05ecffcbb7df31ad9e51a",
   A = sha256.
    
```

This shows that `sha256` is *currently* the default algorithm. We can use this approach to ensure interoperability and at the same time benefit from more secure defaults that may be used in the future. A hash can be used to assess the **integrity** of data: By computing the hash and comparing it against a reference value, you can detect corruption and manipulation of your data. This raises the question: How can we be certain that such a *reference* value is actually *authentic*, i.e., truly stemming from the purported originator? One way to ensure the *authenticity* of data is to use [digital signatures](#signatures).

### Storing passwords safely

Hashes can also be used to securely store user *passwords* for the purpose of authentication. In fact, to store a password securely, the main idea is to *avoid* storing the password altogether. Instead, we store only the *hash* of the password. Later, when the user enters a password, we compute its hash, and compare that hash against the stored value. Two additional features make this process vastly more secure:

1.  First, we make computing the hash *as slow as we can*. This counteracts brute-force attacks where an attacker tries many different passwords to find one whose hash matches the stored hash. One way to do this is to compute the *N*-fold application of the hash function. For example, *N* = 2¹⁷ makes brute-force attacks more than 100 000 times slower than applying the hash only once.
2.  Second, we generate a so-called *salt*, which is a list of random bytes that we combine with the password before it is hashed. We thus ensure (with extremely high probability) that even *identical* passwords yield *different* hashes. We store the salt together with the computed hash, so that we can use it for later reference.

All of this happens completely *automatically* with **`crypto_password_hash/2`**. For example:

```prolog
?- crypto_password_hash("test", Hash).
Hash = "$pbkdf2-sha512$t=131072$Xj6ZIfB4U+QOeZr3ymE/AA$2KYXsPFI2zJVMb9PHVtN+pVwQ6f7LleXF8ehbyqgOmkINcIYjO8IFhz8LelwMjzidEtojRHmC0B5RQJDEB2/tw".

?- crypto_password_hash("test", Hash).
Hash = "$pbkdf2-sha512$t=131072$+aXCnE1r3gAFjpQ3qHcsVw$JAiD2sLbBZPQD1/FtBJUE+iWXRF0VvC/p8etsP6JGSo2dz5U+lV3a6tFDo84mluW1BufFoGZkAuaMW+K74DIaQ".
    
```

In this case, even though the password was the *same* in both queries, the hashes are different. The resulting hash encapsulates everything that is necessary to later *verify* a password and thus authenticate the user:

```prolog
?- crypto_password_hash("test", "$pbkdf2-sha512$t=131072$+aXCnE1r3gAFjpQ3qHcsVw$JAiD2sLbBZPQD1/FtBJUE+iWXRF0VvC/p8etsP6JGSo2dz5U+lV3a6tFDo84mluW1BufFoGZkAuaMW+K74DIaQ").
true.

?- crypto_password_hash("password", "$pbkdf2-sha512$t=131072$+aXCnE1r3gAFjpQ3qHcsVw$JAiD2sLbBZPQD1/FtBJUE+iWXRF0VvC/p8etsP6JGSo2dz5U+lV3a6tFDo84mluW1BufFoGZkAuaMW+K74DIaQ").
false.
    
```

Experience shows that most users choose very predictable passwords, and also reuse the same passwords for different applications. Using `crypto_password_hash/2` in your applications makes it hard for attackers to find out which passwords were used, even if they manage to obtain all hashes you store. If necessary, we can use `crypto_password_hash/3` to specify the applied algorithm, a custom salt, and the number of iterations.

## Digital signatures

To establish the *authenticity* of data, there are different signature algorithms with different strengths and weaknesses. Common to all schemes are:

1.  a *key pair* is generated by the originator. The pair consists of a *private key* and an associated *public key*.
2.  data is *signed* with the private key. This means that a *signature* is generated by performing a computation that involves the data and the private key.
3.  The signature can be *verified* by performing a computation that involves the data and the public key.

An essential property of a signature algorithm is that, realistically, only someone who is in possession of the private key can generate a signature that matches the data in such a way that it is verifiable with the corresponding public key. As the names suggest, the public key can be freely shared with everyone, while the private key must be kept absolutely secret. `library(crypto)` provides Ed25519, which is a specific instance of a digital signature scheme based on twisted Edwards curves. Ed25519 is an algorithm with very desirable cryptographic properties, and easy to use securely. For example, we can easily create a new, cryptographically strong random *key pair* using `ed25519_new_keypair/1`:

```prolog
?- ed25519_new_keypair(Pair).
   Pair = "[redacted]".
    
```

The pair is represented as a string that also includes the *private key* and must therefore be kept absolutely secret. We can relate the pair to its *public key* component with `ed25519_keypair_public_key/2`. In my case, I obtained as public key a Prolog string whose Base64 encoding is `"D/dkIG7mp6a0kbUeqjzxAitTIMthnKo+W6BCCMyGWyg="`. I now *sign* the message `"Hello!"` using `ed25519_sign/4`:

```prolog
    ed25519_sign(Pair, "Hello!", Signature, [])
    
```

where Pair is the key pair from above which only I know. You will never get to see the pair's private component, and there is no realistic way for you to compute it even if I tell you the associated *public key* (see above) and the *signature* that was computed, namely `"``480895ab0202dd9de5e967b4ea9f12757efdfb81043dbbb8d7edf065f24ff01def8095f93bda78db91f8a34a4eff814f7dbe55ee974c92f232b74563536c3f09``"`. However, if you trust that I kept the private key absolutely secret, and you are certain that you have the correct *public key* that is associated with my private key, then you can use `ed25519_verify/4` to *authenticate* the string `"Hello!"`, which is to say, to establish beyond all reasonable doubt that it is I who signed it:

```prolog
?- PublicKeyB64 = "D/dkIG7mp6a0kbUeqjzxAitTIMthnKo+W6BCCMyGWyg=",
   Message = "Hello!",
   Signature = "480895ab0202dd9de5e967b4ea9f12757efdfb81043dbbb8d7edf065f24ff01def8095f93bda78db91f8a34a4eff814f7dbe55ee974c92f232b74563536c3f09",
   chars_base64(PublicKey, PublicKeyB64, []),
   ed25519_verify(PublicKey, Message, Signature, []).
    
```

Since this *succeeds*, the signature is *valid*.

## Symmetric encryption

We now come to the topic you are probably most interested in: *symmetric* encryption. This means that *the same* key is used for encrypting and decrypting the data. For example, an important use case is encrypting files with a *password*, so that *the same* password can be used to decrypt them. Scryer Prolog makes it extremely easy to encrypt arbitrary data in a secure way, using the predicate **`crypto_data_encrypt/6`**. In addition to the data you want to encrypt, you must provide:

1.  the **algorithm** you want to use
2.  the **key** that is used for encryption
3.  the **initialization vector** (IV).

We now consider each of these parameters. An example of a symmetric encryption *algorithm* is [**AES**](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard), which is a subset of the Rijndael cipher developed by Vincent Rijmen and Joan Daemen. AES is the only publicly accessible cipher that the NSA has approved for *top secret* information. AES is a *block cipher* and can be used in several *modes* that guarantee different properties. Ideally, **key** and **IV** are *randomly* chosen, with each key and IV being equally likely. Reusing the same *combination* of key and IV typically leaks at least *some* information about the plaintext. For example, identical plaintexts will then correspond to identical ciphertexts. For some algorithms, reusing an IV with the same key has disastrous results and can cause the loss of *all* properties that are otherwise guaranteed. Especially in such cases, an IV is also called a **nonce**. This is short for "number used once" and emphasizes that for a fixed key, an IV must be used at most *once*. We can specify keys and IVs as lists of *bytes*. We can use `crypto_n_random_bytes/2` to generate *cryptographically strong* pseudo-random bytes. With extremely high likelihood, each invocation will generate a completely different key and nonce. The *key* must be kept absolutely *secret* to retain the confidentiality of the encrypted text. In contrast, the IV can be safely stored and transmitted in plain text.

### Authenticated encryption

As long as the key and IV are chosen (sufficiently) randomly, AES in CBC mode ensures *confidentiality* of the plain text. However, the cipher falls critically short in other respects: It does *not* guarantee *integrity* and therefore also not *authenticity* of the ciphertext. This means that an attacker can *change* the ciphertext during transmission or on a storage device, and we *will not notice the change* if we only rely on this cipher. This can cause highly dramatic consequences. For example, suppose the plaintext is "*Send you a kiss!*", and malicious modifications of the ciphertext yield a deviating decrypted text that reads "*Send him a kiss!*". There are several ways to solve this. We start—and end—with the *best* way to do it: Use a cipher that, in addition to confidentiality of the plaintext, *also* ensures integrity and authenticity of the ciphertext. To illustrate the idea, we now use a powerful and efficient algorithm denoted by the atom **`'chacha20-poly1305'`**: It is the [ChaCha20](https://cr.yp.to/chacha.html) stream cipher that was introduced by Daniel J. Bernstein, coupled with the [Poly1305](https://cr.yp.to/mac.html) authenticator that was also introduced by Daniel J. Bernstein. This cipher uses a 256-bit *key* and a 96-bit *nonce*, i.e., 32 and 12 *bytes*, respectively. Authenticated ciphers work by computing a **tag** that is obtained upon *encryption*, and must be supplied for *decryption*. The tag is obtained and supplied via the `tag/1` option in both cases. For example, here is a concrete encryption with ChaCha20-Poly1305, using a random key and nonce:

```prolog
?- crypto_n_random_bytes(32, Ks),
   crypto_n_random_bytes(12, IV),
   crypto_data_encrypt("test", 'chacha20-poly1305', Ks, IV, CipherText, [tag(Ts)]).
    
```

In response, we get the encrypted text, and a 128-bit *tag* which is specified as a list of 16 bytes:

```prolog
Ks = [84,148,85,236,235,183,51,68,144|...],
IV = [182,70,102,111,6,170,45,76,148|...],
CipherText = "Pç,õ",
Ts = [119,23,173,207,167,255,29,135,101|...].
    
```

Again, the key must be kept completely secret. In contrast, the tag and nonce (IV) can be safely stored and shared in plain text. Decryption only works if the correct *tag* is supplied. For example:

```prolog
?- crypto_data_decrypt($CipherText, 'chacha20-poly1305', $Ks, $IV, PlainText, [tag($Ts)]).
PlainText = "test",
CipherText = "Pç,õ",
Ks = [84,148,85,236,235,183,51,68,144|...],
IV = [182,70,102,111,6,170,45,76,148|...],
Ts = [119,23,173,207,167,255,29,135,101|...].
    
```

In contrast, even if we only *slightly* shorten, extend or modify the ciphertext, nonce, or the required tag in any way, the decryption *fails*. Thus, an attacker who changes the ciphertext must also make a *fitting* change in the tag for the change to go unnoticed. However, without knowing the secret key, such a change is extremely improbable. Prolog is well-suited for studying how such algorithms work by prototyping their implementations. For example, here is a Prolog implementation of the Poly1305 authenticator: [`poly1305aes.pl`](poly1305aes.pl). And here is the ChaCha20 core: [`chacha20.pl`](chacha20.pl). Before we continue, a few test runs are highly appropriate. For example, let us see whether we can *decrypt* the ciphertext if we supply the same algorithm, key and IV to **`crypto_data_decrypt/6`**. In addition, let us try this not only *once*, but *over and over*, with a freshly generated key and IV in each run:

```prolog
?- repeat,
      PlainText = "test",
      Algorithm = 'chacha20-poly1305',
      crypto_n_random_bytes(32, Ks),
      crypto_n_random_bytes(12, IV),
      portray_clause(verifying),
      crypto_data_encrypt(PlainText, Algorithm, Ks, IV, CipherText, [tag(Ts)]),
      crypto_data_decrypt(CipherText, Algorithm, Ks, IV, PlainText, [tag(Ts)]),
      portray_clause(ok),
      false.
    
```

As result, we get:

```prolog
verifying.
ok.
verifying.
ok.
verifying.
ok.
etc.
    
```

After a few hundred thousand iterations of this, we can be reasonably confident that what is encrypted can also be decrypted. When experimenting with different algorithms, it is a common error to specify keys or IVs that are shorter than what the chosen algorithm requires, and such test cases help us to detect these mistakes.

### Deriving keys and initialization vectors

In most actual applications, it is not enough to generate a *random* key. Instead, we typically must find a way to *derive* a key and IV from *other* information, which is called *input keying material* (IKM). For example, in the [Diffie-Hellman-Merkle key exchange](https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange), we first negotiate a *shared secret* with another participant, and then must derive a suitable key from that secret. Examples of such secrets are integers, and points on an elliptic curve. There is a standard algorithm that lets us derive keys and IVs from arbitrary input data. It is called **HKDF** (HMAC-based key derivation function), and it is described in [RFC 5869](https://tools.ietf.org/html/rfc5869). In Scryer Prolog, it is available as **`crypto_data_hkdf/4`**. For example, let us now derive a key and an IV from a *password* in such a way that entering the same password always yields the same key and IV. Using HKDF, we *could* of course derive a key *directly* from a given password. However, consider what we said about [storing passwords](#passwords): First, attackers that try to guess the password should be slowed down. Second, using a password should not leak any information even if the same password is also used elsewhere. Therefore, instead of *password* → *key*, we will do: *password and salt* → intentionally slow *hash* → *key*. Thus, we will now *combine* password-based hash derivation with HMAC-based key derivation, using `crypto_password_hash/3` and *then* `crypto_data_hkdf/4`. To ensure that *the same* key is generated also when the same password is entered later, we must *fix* all parameters of `crypto_password_hash/3`. For example, recall that by default, a *random* salt is used. Now, we will supply our own salt, and store it for later reference. We can easily generate a salt with `crypto_n_random_bytes/2`. For example, let us use a 128-bit salt (16 bytes). In addition, let us explicitly supply the algorithm we want to use (`'pbkdf2-sha512'`, which is currently the only supported option in any case) and also the number of iterations. For example, let us use 2¹⁹ iterations. From the generated *hash*, we can easily derive a key *and* an IV: The `info/1` option of `crypto_data_hkdf/4` can be used to derive several different keys and IVs from the same IKM. We also fix the *algorithm* that is used by `crypto_data_hkdf/4`. Taking all these considerations into account, we obtain for example the following predicate to derive a 128-bit (i.e., 16 bytes) key and IV from a given password and salt:

```prolog
password_salt_key_iv(Password, Salt, Ks, IV) :-
        crypto_password_hash(Password, Hash, [algorithm('pbkdf2-sha512'),
                                              cost(19),
                                              salt(Salt)]),
        crypto_data_hkdf(Hash, 16, Ks, [info("key"),algorithm(sha256)]),
        crypto_data_hkdf(Hash, 16, IV, [info("iv"),algorithm(sha256)]).
    
```

Sample usage, with a fresh 128-bit salt:

```prolog
?- crypto_n_random_bytes(16, Salt),
   password_salt_key_iv("test", Salt, Ks, IV).
    
```

This yields:

```prolog
Salt = [203,81,172,46,86,244,37,2,215|...],
Ks = [38,141,86,95,83,22,243,31,38|...],
IV = [36,149,175,179,48,192,213,175,71|...].
    
```

When we later use the same password and salt, exactly the same results are derived. Thus, we only need to store the *salt* that was used, and can later (again) use HKDF to derive all required values when the password is entered. It is safe to store the salt in plain text, since it has no discernible or realistically computable relation with the derived values, as long as the *password* is kept completely secret. A shared secret can be established over an insecure channel via elliptic-curve Diffie–Hellman (ECDH), using the elliptic curve functionality of `library(crypto)`. Curve25519 is particularly well suited for this: In `library(crypto)`, points on Curve25519 are represented as *lists of characters* that denote the *u*-coordinate of the Montgomery curve. There are two predicates that let us implement X25519, a secure key exchange algorithm using Curve25519:

- `curve25519_generator(-Gs)` *Gs* is the generator point of Curve25519.
- `curve25519_scalar_mult(+Scalar, +Ps, -Rs)` *Scalar* must be an integer between 0 and 2²⁵⁶-1, or a list of 32 bytes, and *Ps* must be a point on the curve. Computes the point *Rs = Scalar·Ps* as mandated by X25519.

Alice and Bob can establish a shared secret over an insecure channel as follows, where *Gs* is the generator point of Curve25519:

1.  Alice creates a random integer *a*, computes *As = a·Gs*, and sends *As* to Bob. Instead of an integer *a*, Alice can use `crypto_n_random_bytes/2` to generate 32 random bytes.
2.  Bob creates a random integer *b*, computes *Bs = b·Gs*, and sends *Bs* to Alice. Bob can also use `crypto_n_random_bytes/2` to generate *b*.
3.  Alice computes *Rs = a·Bs*.
4.  Bob computes *Rs = b·As*.
5.  Alice and Bob use `crypto_data_hkdf/4` on *Rs* with suitable (same) parameters to obtain lists of bytes that can be used as keys and initialization vectors for symmetric encryption.

If *a* and *b* are kept secret, this method is considered very secure. Sometimes, keys are themselves derived from keys. For example, you may have a *master key*, and derive further keys from it, such as one key per file you want to encrypt. In such cases, you can for example specify a *file name* in the `info/1` option of `crypto_data_hkdf/4`. Even if an attacker finds out one of these keys, the master key remains safe. As another example, you could prove the *authenticity* of the cipher text by deriving a further key that you use to compute an [HMAC](https://en.wikipedia.org/wiki/Hash-based_message_authentication_code) over the encrypted data and the IV. However, although this construction does not leak the primary key even if the derived key is broken, it is less error-prone and therefore safer to use a cipher with built-in support for [authenticated encryption](#authenticated-encryption) for such use cases.

## Further reading

We have barely scratched the surface of what you can and should do with Prolog in the context of cryptography. For example, [*An Efficient Cryptographic Protocol Verifier Based on Prolog Rules*](http://web.cs.wpi.edu/~cs564/f12/papers/blanchet_csfw01.pdf) by Bruno Blanchet outlines how you can use Prolog to verify properties of a cryptographic protocol. In many cases, you can benefit from cryptographic features even without knowing how they work internally. For example, if you simply want to enable encrypted traffic for your web applications, see [**LetSWICrypt**](/letswicrypt/) to set up an HTTPS server with SWI-Prolog. In other cases, you can use the available functionality to implement specific applications on your own. For example, you can use Prolog to reason about *Bitcoin* addresses. See [**Bitcoinolog**](/bitcoinolog/) for more information. You can use the above methods to *encrypt* your Bitcoin wallets and other sensitive data: Use [**Enscryerypt**](/enscryerypt/) to encrypt and decrypt files. The cryptographic functionality of Scryer Prolog is subject to continuous improvements. If you are interested in specific features, file an issue with the project, or contribute a patch!
