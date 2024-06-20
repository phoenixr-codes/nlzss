# nlzss - (de)compression with Nintendo's [LZSS][] format

[![Pub Version](https://img.shields.io/pub/v/nlzss?style=for-the-badge)](https://pub.dev/packages/nlzss)
[![GitHub Repo stars](https://img.shields.io/github/stars/phoenixr-codes/nlzss?style=for-the-badge)](https://github.com/phoenixr-codes/nlzss)
[![Pub Likes](https://img.shields.io/pub/likes/nlzss?style=for-the-badge)](https://pub.dev/packages/nlzss)


## CLI Usage

### Compress

```bash
cat file | nlzss compress > file.bin
```

Instead of `compress` you can also use the `c` shorthand. To specify the
algorithm to use, add `--level 11` (default) or `--level 10`.


### Decompress

```bash
cat file.bin | nlzss decompress > file
```

Instead of `decompress` you can also use the `d` shorthand.


## References

- [nintendo-lz][] - The codebase was heavily inspired by this
- [nzlss][nzlss-python]

[LZSS]: http://en.wikipedia.org/wiki/Lempel%E2%80%93Ziv%E2%80%93Storer%E2%80%93Szymanski
[nintendo-lz]: https://gitlab.com/DarkKirb/nintendo-lz
[nzlss-python]: https://github.com/magical/nlzss
