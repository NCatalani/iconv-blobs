# iconv-blobs
Simple bash/shell script made to parse huge files with iconv

Heavily inspired by https://github.com/mla/iconv-chunks

# Examples

./iconv_blobs.sh -f ISO88591 -t UTF8 my_file.csv > my_output

./iconv_blobs.sh - -f ISO88591 -t UTF8 < my_file.csv > my_output

./iconv_blobs.sh - -f ISO2022CN -t UTF8 < file1.txt file2.txt file3.txt > output.txt

### Todo

- [ ] Add custom separator to output expression
- [ ] Add evaluation
