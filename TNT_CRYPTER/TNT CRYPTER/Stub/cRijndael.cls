VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "cRijndael"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False

'##############################################################
'#Automated encryption code                     #
'#by Karcrack Project Crypter v2.1 [KPC]                  #
'#Program consisting of Karcrack                        #
'#Details of the encryption:                            #
'#	+ Encriptacion  :RC4                                      
'#	+ Contraseņa    :qkercipgp
'#	+ L. Encriptacion:0                                        
'#	+ Fecha/Hora    :14:31:03--01/06/2009                     
'##############################################################
Option Explicit

'Title:     cRijndael - Advanced Encryption Standard (AES) Class
'Author:    John Korejwa  <korejwa@tiac.net>
'Filename:  Rijndael.cls
'Date:      09 / July / 2006
'Version:   1.0
'Modded by: ZiG

'These are arrays of constants.  They are initialized with the Class and do not change.
Private Te0(255)      As Long
Private Te1(255)      As Long
Private Te2(255)      As Long
Private Te3(255)      As Long
Private Te4(255)      As Long

Private Td0(255)      As Long
Private Td1(255)      As Long
Private Td2(255)      As Long
Private Td3(255)      As Long
Private Td4(255)      As Long

Private rco(28)       As Long

'Key schedule arrays
Private Nr            As Long 'Number of rounds [For 128 bit block, Nr = {10, 12, 14} for 128, 192, 256 bit cipher key]

Private fkey(119)     As Long 'Nb*(Nr + 1)
Private rkey(119)     As Long 'Nb*(Nr + 1)

Private Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (Destination As Any, Source As Any, ByVal Length As Long)

'Decryption Key Scheduler.  Calculate rkey() decryption keys based on fkey() and Nr.
'Nb is the number of 32 bit units in the block size.
Private Sub CreateDecryptionKeys(Nb As Long)
    Dim i    As Long
    Dim j    As Long
    Dim k    As Long
    Dim s(3) As Byte

    'Invert the order of the round keys
    i = 0
    j = Nb * Nr
    For k = 0 To Nr
        CopyMemory rkey(i), fkey(j), Nb * 4&
        i = i + Nb
        j = j - Nb
    Next k

    'Apply the inverse MixColumn transform to all round keys except the first and the last
    For i = Nb To Nb * Nr - 1
        CopyMemory s(0), rkey(i), 4&
        rkey(i) = Td0(Te4(s(0)) And &HFF&) Xor Td1(Te4(s(1)) And &HFF&) Xor Td2(Te4(s(2)) And &HFF&) Xor Td3(Te4(s(3)) And &HFF&)
    Next i
End Sub

Public Function SetCipherKey(pass() As Byte) As Long

Dim i    As Long
Dim j    As Long
Dim s(3) As Byte

i = 8
CopyMemory fkey(0), pass(0), 4& * i

For j = 0 To 13
 CopyMemory s(0), fkey(i - 1), 4&
 fkey(i) = fkey(i - 8) Xor (Te4(s(0)) And &HFF000000) Xor (Te4(s(3)) And &HFF0000) Xor (Te4(s(2)) And &HFF00&) Xor (Te4(s(1)) And &HFF&) Xor rco(j)
 fkey(i + 1) = fkey(i - 7) Xor fkey(i)
 fkey(i + 2) = fkey(i - 6) Xor fkey(i + 1)
 fkey(i + 3) = fkey(i - 5) Xor fkey(i + 2)
 CopyMemory s(0), fkey(i + 3), 4&
 fkey(i + 4) = fkey(i - 4) Xor (Te4(s(3)) And &HFF000000) Xor (Te4(s(2)) And &HFF0000) Xor (Te4(s(1)) And &HFF00&) Xor (Te4(s(0)) And &HFF&)
 fkey(i + 5) = fkey(i - 3) Xor fkey(i + 4)
 fkey(i + 6) = fkey(i - 2) Xor fkey(i + 5)
 fkey(i + 7) = fkey(i - 1) Xor fkey(i + 6)
 i = i + 8
Next j

Nr = 14

CreateDecryptionKeys 8
End Function

Public Sub Block256Decrypt(plaintext() As Byte, ciphertext() As Byte, p As Long, q As Long)
    Dim i     As Long
    Dim k     As Long
    Dim t0    As Long
    Dim t1    As Long
    Dim t2    As Long
    Dim t3    As Long
    Dim t4    As Long
    Dim t5    As Long
    Dim t6    As Long
    Dim t7    As Long
    Dim s(31) As Byte

    CopyMemory t0, ciphertext(q + 0), 4&
    CopyMemory t1, ciphertext(q + 4), 4&
    CopyMemory t2, ciphertext(q + 8), 4&
    CopyMemory t3, ciphertext(q + 12), 4&
    CopyMemory t4, ciphertext(q + 16), 4&
    CopyMemory t5, ciphertext(q + 20), 4&
    CopyMemory t6, ciphertext(q + 24), 4&
    CopyMemory t7, ciphertext(q + 28), 4&
    t0 = t0 Xor rkey(0)
    t1 = t1 Xor rkey(1)
    t2 = t2 Xor rkey(2)
    t3 = t3 Xor rkey(3)
    t4 = t4 Xor rkey(4)
    t5 = t5 Xor rkey(5)
    t6 = t6 Xor rkey(6)
    t7 = t7 Xor rkey(7)
    k = 8

    For i = 1 To Nr - 1 'Nr is number of rounds
        CopyMemory s(0), t0, 4&
        CopyMemory s(4), t1, 4&
        CopyMemory s(8), t2, 4&
        CopyMemory s(12), t3, 4&
        CopyMemory s(16), t4, 4&
        CopyMemory s(20), t5, 4&
        CopyMemory s(24), t6, 4&
        CopyMemory s(28), t7, 4&
        t0 = Td0(s(0)) Xor Td1(s(29)) Xor Td2(s(22)) Xor Td3(s(19)) Xor rkey(k + 0)
        t1 = Td0(s(4)) Xor Td1(s(1)) Xor Td2(s(26)) Xor Td3(s(23)) Xor rkey(k + 1)
        t2 = Td0(s(8)) Xor Td1(s(5)) Xor Td2(s(30)) Xor Td3(s(27)) Xor rkey(k + 2)
        t3 = Td0(s(12)) Xor Td1(s(9)) Xor Td2(s(2)) Xor Td3(s(31)) Xor rkey(k + 3)
        t4 = Td0(s(16)) Xor Td1(s(13)) Xor Td2(s(6)) Xor Td3(s(3)) Xor rkey(k + 4)
        t5 = Td0(s(20)) Xor Td1(s(17)) Xor Td2(s(10)) Xor Td3(s(7)) Xor rkey(k + 5)
        t6 = Td0(s(24)) Xor Td1(s(21)) Xor Td2(s(14)) Xor Td3(s(11)) Xor rkey(k + 6)
        t7 = Td0(s(28)) Xor Td1(s(25)) Xor Td2(s(18)) Xor Td3(s(15)) Xor rkey(k + 7)
        k = k + 8
        
    Next i

    'Final round
    CopyMemory s(0), t0, 4&
    CopyMemory s(4), t1, 4&
    CopyMemory s(8), t2, 4&
    CopyMemory s(12), t3, 4&
    CopyMemory s(16), t4, 4&
    CopyMemory s(20), t5, 4&
    CopyMemory s(24), t6, 4&
    CopyMemory s(28), t7, 4&
    t0 = (Td4(s(0)) And &HFF&) Xor (Td4(s(29)) And &HFF00&) Xor (Td4(s(22)) And &HFF0000) Xor (Td4(s(19)) And &HFF000000) Xor rkey(k + 0)
    t1 = (Td4(s(4)) And &HFF&) Xor (Td4(s(1)) And &HFF00&) Xor (Td4(s(26)) And &HFF0000) Xor (Td4(s(23)) And &HFF000000) Xor rkey(k + 1)
    t2 = (Td4(s(8)) And &HFF&) Xor (Td4(s(5)) And &HFF00&) Xor (Td4(s(30)) And &HFF0000) Xor (Td4(s(27)) And &HFF000000) Xor rkey(k + 2)
    t3 = (Td4(s(12)) And &HFF&) Xor (Td4(s(9)) And &HFF00&) Xor (Td4(s(2)) And &HFF0000) Xor (Td4(s(31)) And &HFF000000) Xor rkey(k + 3)
    t4 = (Td4(s(16)) And &HFF&) Xor (Td4(s(13)) And &HFF00&) Xor (Td4(s(6)) And &HFF0000) Xor (Td4(s(3)) And &HFF000000) Xor rkey(k + 4)
    t5 = (Td4(s(20)) And &HFF&) Xor (Td4(s(17)) And &HFF00&) Xor (Td4(s(10)) And &HFF0000) Xor (Td4(s(7)) And &HFF000000) Xor rkey(k + 5)
    t6 = (Td4(s(24)) And &HFF&) Xor (Td4(s(21)) And &HFF00&) Xor (Td4(s(14)) And &HFF0000) Xor (Td4(s(11)) And &HFF000000) Xor rkey(k + 6)
    t7 = (Td4(s(28)) And &HFF&) Xor (Td4(s(25)) And &HFF00&) Xor (Td4(s(18)) And &HFF0000) Xor (Td4(s(15)) And &HFF000000) Xor rkey(k + 7)
    CopyMemory plaintext(p + 0), t0, 4&
    CopyMemory plaintext(p + 4), t1, 4&
    CopyMemory plaintext(p + 8), t2, 4&
    CopyMemory plaintext(p + 12), t3, 4&
    CopyMemory plaintext(p + 16), t4, 4&
    CopyMemory plaintext(p + 20), t5, 4&
    CopyMemory plaintext(p + 24), t6, 4&
    CopyMemory plaintext(p + 28), t7, 4&
End Sub

'Decrypts an array encrypted with the ArrayEncrypt function
Public Function ArrayDecrypt(plaintext() As Byte, ciphertext() As Byte) As Long

Dim i As Long
Dim m As Long
Dim n As Long

Dim BlockSize   As Long
BlockSize = 32

n = UBound(ciphertext) + 1
If ((n Mod BlockSize) = 0) Then
 ReDim plaintext(n - 1)

 For i = 0 To n - BlockSize Step BlockSize
  Block256Decrypt plaintext, ciphertext, i, i
 Next i

Else
 ArrayDecrypt = -1
End If

End Function

Private Sub Class_Initialize()

Dim i          As Long
Dim y          As Byte
Dim s(7)       As Byte
Dim ib         As Byte
Dim ptab(255)  As Byte
Dim ltab(255)  As Byte

'use 3 as primitive root to generate power and log tables
ltab(0) = 0
ltab(1) = 0
ltab(3) = 1
ptab(0) = 1
ptab(1) = 3
For i = 2 To 255 'ptab(i) = ptab(i - 1) Xor Xtime(ptab(i - 1))
    If (ptab(i - 1) And &H80) Then
        ptab(i) = ptab(i - 1) Xor ((ptab(i - 1) And 127) * 2) Xor &H1B
    Else
        ptab(i) = ptab(i - 1) Xor (ptab(i - 1) * 2)
    End If
    ltab(ptab(i)) = i
Next i

'affine transformation:- each bit is xored with itself shifted one bit
Te4(0) = &H63636363
Td4(&H63) = 0
For i = 1 To 255
    y = ptab(255 - ltab(i)) 'multiplicative inverse
    ib = y
    If ib And &H80 Then ib = (ib And 127) * 2 Or 1 Else ib = ib * 2 'RotateLeftByte
    y = y Xor ib
    If ib And &H80 Then ib = (ib And 127) * 2 Or 1 Else ib = ib * 2
    y = y Xor ib
    If ib And &H80 Then ib = (ib And 127) * 2 Or 1 Else ib = ib * 2
    y = y Xor ib
    If ib And &H80 Then ib = (ib And 127) * 2 Or 1 Else ib = ib * 2
    y = y Xor ib Xor &H63

    s(0) = y
    s(1) = s(0)
    s(2) = s(0)
    s(3) = s(0)
    CopyMemory Te4(i), s(0), 4&

    s(0) = i
    s(1) = s(0)
    s(2) = s(0)
    s(3) = s(0)
    CopyMemory Td4(y), s(0), 4&
Next i

y = 1
For i = 0 To UBound(rco)
    rco(i) = y
    If (y And &H80) Then 'y = Xtime(y)
        y = ((y And 127) * 2) Xor &H1B
    Else
        y = y * 2
    End If
Next i

'calculate forward and reverse tables
For i = 0 To 255
    y = Te4(i) And &HFF&
    's(3) = y Xor Xtime(y)
    's(0) = Xtime(y)
    If (y And &H80) Then
        s(0) = ((y And 127) * 2) Xor &H1B
        s(3) = y Xor s(0)
    Else
        s(0) = y * 2
        s(3) = y Xor s(0)
    End If
    s(2) = y
    s(1) = y
    CopyMemory s(4), s(0), 4&
    CopyMemory Te0(i), s(0), 4&
    CopyMemory Te1(i), s(3), 4&
    CopyMemory Te2(i), s(2), 4&
    CopyMemory Te3(i), s(1), 4&
    y = Td4(i) And &HFF&
    If y = 0 Then 'x.y= AntiLog(Log(x) + Log(y))
        s(3) = 0
        s(2) = 0
        s(1) = 0
        s(0) = 0
    Else
        s(3) = ptab((CLng(ltab(&HB)) + CLng(ltab(y))) Mod 255)
        s(2) = ptab((CLng(ltab(&HD)) + CLng(ltab(y))) Mod 255)
        s(1) = ptab((CLng(ltab(&H9)) + CLng(ltab(y))) Mod 255)
        s(0) = ptab((CLng(ltab(&HE)) + CLng(ltab(y))) Mod 255)
    End If
    CopyMemory s(4), s(0), 4&
    CopyMemory Td0(i), s(0), 4&
    CopyMemory Td1(i), s(3), 4&
    CopyMemory Td2(i), s(2), 4&
    CopyMemory Td3(i), s(1), 4&
Next i
End Sub




