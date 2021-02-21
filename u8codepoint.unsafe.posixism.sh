#!/bin/sh

# written by TpaeFawzen

export LC_ALL=C

cat ${1:+"$@"} |
od -A n -t x1 -v |
tr ABCDEF abcdef |
tr -Cd abcdef0123456789\\n |
fold -w 2 |
grep . |
sed '
  /^[0-7].$/s/U+00&/
  t
  
  # 110xxxxx 10xxxxxx
  # o   x    r   -
  /^[cd]$/{
    $!N
    # SUSv2 supports the following line!
    s/\n//
    # s/[^0-9a-f]//
    s/^\(.\)\(.\)\([89ab]\)\(.\)$/'\
'''''''o\1''''x\2''''r\3''''\4''/
    t tob
    b fail
  }
  # 1110xxxx 10xxxxxx 10xxxxxx
  #     x    r   x    r   -
  /^e/{
    $!N
    $!N
    s/[^0-9a-f]//g
    s/^.\(.\)\([89ab]\)\(.\)\([89ab]\)\(.\)$/'\
'''''''''x\1''r\2''''''''x\3''''r\4''''\5''/
    t tob
    b fail
  }
  # 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
  #     x    r   x    r   x    r   x     
  /^f[0-7]$/{
    $!N
    $!N
    $!N
    s/[^0-9a-f]//g
    s/^.\(.\)\([89ab]\)\(.\)\([89ab]\)\(.\)\([89ab]\)\(.\)$/'\
'''''''''x\1''r\2''''''''x\3''''r\4''''x\5''''''r\6''''\7''''''/
    t tob
    b fail
  }
  
  : fail
  s/^/! /
  b
  
  : tob
  # x to 4bits binary
  # o[cd] to [01]
  # r[89ab] to 00 01 10 11
  s/x0/0000/g
  s/x1/0001/g
  s/x2/0010/g
  s/x3/0011/g
  s/x4/0100/g
  s/x5/0101/g
  s/x6/0110/g
  s/x7/0111/g
  s/x8/1000/g
  s/x9/1001/g
  s/xa/1010/g
  s/xb/1011/g
  s/xc/1100/g
  s/xd/1101/g
  s/xe/1110/g
  s/xf/1111/g
  s/oc/0/
  s/od/1/
  s/r8/00/g
  s/r9/01/g
  s/ra/10/g
  s/rb/11/g
  
  s/.$/U+&/
  : toX
  s/0\{1,4\}U+/U+0/
  t toX
  s/0\{,3\}1U+/U+1/
  t toX
  s/0\{,2\}1U+/U+2/
  t toX
  s/0\{,2\}11U+/U+3/
  t toX
  s/0\{,1\}100U+/U+4/
  t toX
  s/0\{,1\}101U+/U+5/
  t toX
  s/0\{,1\}110U+/U+6/
  t toX
  s/0\{1,\}111U+/U+7/
  t toX
  s/1000U+/U+8/
  t toX
  s/1001U+/U+9/
  t toX
  s/1010U+/U+a/
  t toX
  s/1011U+/U+b/
  t toX
  s/1100U+/U+c/
  t toX
  s/1101U+/U+d/
  t toX
  s/1110U+/U+e/
  t toX
  s/1111U+/U+f/
  t toX
  
  s/^..\(..\)$/U+00\1/
  s/^..\(...\)$/U+0\1/
' |
case $mayrmbom in (yes)
  sed '
    1{
      s/ef$/&/
      t yes0
      b
      : yes0
      $!N
      s/bb$//
      t yes
      b
      : yes
      $!N
      s/^.*bf$/U+FEFF/
    }
  '
;;(*)
  cat
;;esac |
tr abcdef ABCDEF |
tee "$(tty)" |
{ ! grep -q '!' ; }

exit $?
