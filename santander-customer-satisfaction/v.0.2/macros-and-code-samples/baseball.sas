
  *-------------------------Baseball data------------------------*
  |  Salary(1987) and performance information (1986) for         |
  |  Major League Baseball players                               |
  |  Sports Illustrated, April 20, 1987                          |
  |  Collier Books, The 1987 Baseball Encyclopedia Update        |
  *--------------------------------------------------------------*;

/* El objetivo es la variable logSalary */

data baseball;
   length name $ 18;
   length team $ 12;
   input name $ 1-18 nAtBat nHits nHome nRuns nRBI nBB
         yrMajor crAtBat crHits crHome crRuns crRbi crBB
         league $ division $ team $ position $ nOuts nAssts
         nError salary;
   label name="Player's Name"
      nAtBat="Times at Bat in 1986"
      nHits="Hits in 1986"
      nHome="Home Runs in 1986"
      nRuns="Runs in 1986"
      nRBI="RBIs in 1986"
      nBB="Walks in 1986"
      yrMajor="Years in the Major Leagues"
      crAtBat="Career times at bat"
      crHits="Career Hits"
      crHome="Career Home Runs"
      crRuns="Career Runs"
      crRbi="Career RBIs"
      crBB="Career Walks"
      league="League at the end of 1986"
      division="Division at the end of 1986"
      team="Team at the end of 1986"
      position="Position(s) in 1986"
      nOuts="Put Outs in 1986"
      nAssts="Assists in 1986"
      nError="Errors in 1986"
      salary="1987 Salary in $ Thousands";
      logSalary = log(Salary);
datalines;
Allanson, Andy       293    66     1    30    29    14
                       1   293    66     1    30    29    14
                    American East Cleveland C 446 33 20 .
Ashby, Alan          315    81     7    24    38    39
                      14  3449   835    69   321   414   375
                    National West Houston C 632 43 10 475
Davis, Alan          479   130    18    66    72    76
                       3  1624   457    63   224   266   263
                    American West Seattle 1B 880 82 14 480
Dawson, Andre        496   141    20    65    78    37
                      11  5628  1575   225   828   838   354
                    National East Montreal RF 200 11 3 500
Galarraga, Andres    321    87    10    39    42    30
                       2   396   101    12    48    46    33
                    National East Montreal 1B 805 40 4 91.5
Griffin, Alfredo     594   169     4    74    51    35
                      11  4408  1133    19   501   336   194
                    American West Oakland SS 282 421 25 750
Newman, Al           185    37     1    23     8    21
                       2   214    42     1    30     9    24
                    National East Montreal 2B 76 127 7 70
Salazar, Argenis     298    73     0    24    24     7
                       3   509   108     0    41    37    12
                    American West KansasCity SS 121 283 9 100
Thomas, Andres       323    81     6    26    32     8
                       2   341    86     6    32    34     8
                    National West Atlanta SS 143 290 19 75
Thornton, Andre      401    92    17    49    66    65
                      13  5206  1332   253   784   890   866
                    American East Cleveland DH 0 0 0 1100
Trammell, Alan       574   159    21   107    75    59
                      10  4631  1300    90   702   504   488
                    American East Detroit SS 238 445 22 517.143
Trevino, Alex        202    53     4    31    26    27
                       9  1876   467    15   192   186   161
                    National West LosAngeles C 304 45 11 512.5
Van Slyke, Andy      418   113    13    48    61    47
                       4  1512   392    41   205   204   203
                    National East StLouis RF 211 11 7 550
Wiggins, Alan        239    60     0    30    11    22
                       6  1941   510     4   309   103   207
                    American East Baltimore 2B 121 151 6 700
Almon, Bill          196    43     7    29    27    30
                      13  3231   825    36   376   290   238
                    National East Pittsburgh UT 80 45 8 240
Beane, Billy         183    39     3    20    15    11
                       3   201    42     3    20    16    11
                    American West Minneapolis OF 118 0 0 .
Bell, Buddy          568   158    20    89    75    73
                      15  8068  2273   177  1045   993   732
                    National West Cincinnati 3B 105 290 10 775
Biancalana, Buddy    190    46     2    24     8    15
                       5   479   102     5    65    23    39
                    American West KansasCity SS 102 177 16 175
Bochte, Bruce        407   104     6    57    43    65
                      12  5233  1478   100   643   658   653
                    American West Oakland 1B 912 88 9 .
Bochy, Bruce         127    32     8    16    22    14
                       8   727   180    24    67    82    56
                    National West SanDiego C 202 22 2 135
Bonds, Barry         413    92    16    72    48    65
                       1   413    92    16    72    48    65
                    National East Pittsburgh CF 280 9 5 100
Bonilla, Bobby       426   109     3    55    43    62
                       1   426   109     3    55    43    62
                    American West Chicago O1 361 22 2 115
Boone, Bob           442    98     7    48    49    43
                      15  5982  1501    96   555   702   533
                    American West California C 812 84 11 .
Brenly, Bob          472   116    16    60    62    74
                       6  1924   489    67   242   251   240
                    National West SanFrancisco C 518 55 3 600
Buckner, Bill        629   168    18    73   102    40
                      18  8424  2464   164  1008  1072   402
                    American East Boston 1B 1067 157 14 776.667
Butler, Brett        587   163     4    92    51    70
                       6  2695   747    17   442   198   317
                    American East Cleveland CF 434 9 3 765
Dernier, Bob         324    73     4    32    18    22
                       7  1931   491    13   291   108   180
                    National East Chicago CF 222 3 3 708.333
Diaz, Bo             474   129    10    50    56    40
                      10  2331   604    61   246   327   166
                    National West Cincinnati C 732 83 13 750
Doran, Bill          550   152     6    92    37    81
                       5  2308   633    32   349   182   308
                    National West Houston 2B 262 329 16 625
Downing, Brian       513   137    20    90    95    90
                      14  5201  1382   166   763   734   784
                    American West California LF 267 5 3 900
Grich, Bobby         313    84     9    42    30    39
                      17  6890  1833   224  1033   864  1087
                    American West California 2B 127 221 7 .
Hatcher, Billy       419   108     6    55    36    22
                       3   591   149     8    80    46    31
                    National West Houston CF 226 7 4 110
Horner, Bob          517   141    27    70    87    52
                       9  3571   994   215   545   652   337
                    National West Atlanta 1B 1378 102 8 .
Jacoby, Brook        583   168    17    83    80    56
                       5  1646   452    44   219   208   136
                    American East Cleveland 3B 109 292 25 612.5
Kearney, Bob         204    49     6    23    25    12
                       7  1309   308    27   126   132    66
                    American West Seattle C 419 46 5 300
Madlock, Bill        379   106    10    38    60    30
                      14  6207  1906   146   859   803   571
                    National West LosAngeles 3B 72 170 24 850
Meacham, Bobby       161    36     0    19    10    17
                       4  1053   244     3   156    86   107
                    American East NewYork SS 70 149 12 .
Melvin, Bob          268    60     5    24    25    15
                       2   350    78     5    34    29    18
                    National West SanFrancisco C 442 59 6 90
Oglivie, Ben         346    98     5    31    53    30
                      16  5913  1615   235   784   901   560
                    American East Milwaukee DH 0 0 0 .
Roberts, Bip         241    61     1    34    12    14
                       1   241    61     1    34    12    14
                    National West SanDiego 2B 166 172 10 .
Robidoux, Billy Jo   181    41     1    15    21    33
                       2   232    50     4    20    29    45
                    American East Milwaukee 1B 326 29 5 67.5
Russell, Bill        216    54     0    21    18    15
                      18  7318  1926    46   796   627   483
                    National West LosAngeles UT 103 84 5 .
Sample, Billy        200    57     6    23    14    14
                       9  2516   684    46   371   230   195
                    National West Atlanta OF 69 1 1 .
Schroeder, Bill      217    46     7    32    19     9
                       4   694   160    32    86    76    32
                    American East Milwaukee UT 307 25 1 180
Wynegar, Butch       194    40     7    19    29    30
                      11  4183  1069    64   486   493   608
                    American East NewYork C 325 22 2 .
Bando, Chris         254    68     2    28    26    22
                       6   999   236    21   108   117   118
                    American East Cleveland C 359 30 4 305
Brown, Chris         416   132     7    57    49    33
                       3   932   273    24   113   121    80
                    National West SanFrancisco 3B 73 177 18 215
Castillo, Carmen     205    57     8    34    32     9
                       5   756   192    32   117   107    51
                    American East Cleveland OD 58 4 4 247.5
Cooper, Cecil        542   140    12    46    75    41
                      16  7099  2130   235   987  1089   431
                    American East Milwaukee 1B 697 61 9 .
Davis, Chili         526   146    13    71    70    84
                       6  2648   715    77   352   342   289
                    National West SanFrancisco RF 303 9 9 815
Fisk, Carlton        457   101    14    42    63    22
                      17  6521  1767   281  1003   977   619
                    American West Chicago C 389 39 4 875
Ford, Curt           214    53     2    30    29    23
                       2   226    59     2    32    32    27
                    National East StLouis OF 109 7 3 70
Johnson, Cliff       336    84    15    48    55    52
                      15  3945  1016   196   539   699   568
                    American East Toronto DH 8 1 0 .
Lansford, Carney     591   168    19    80    72    39
                       9  4478  1307   113   634   563   319
                    American West Oakland 3B 67 147 4 1200
Lemon, Chet          403   101    12    45    53    39
                      12  5150  1429   166   747   666   526
                    American East Detroit CF 316 6 5 675
Maldonado, Candy     405   102    18    49    85    20
                       6   950   231    29    99   138    64
                    National West SanFrancisco OF 161 10 3 415
Martinez, Carmelo    244    58     9    28    25    35
                       4  1335   333    49   164   179   194
                    National West SanDiego O1 142 14 2 340
Moore, Charlie       235    61     3    24    39    21
                      14  3926  1029    35   441   401   333
                    American East Milwaukee C 425 43 4 .
Reynolds, Craig      313    78     6    32    41    12
                      12  3742   968    35   409   321   170
                    National West Houston SS 106 206 7 416.667
Ripken, Cal          627   177    25    98    81    70
                       6  3210   927   133   529   472   313
                    American East Baltimore SS 240 482 13 1350
Snyder, Cory         416   113    24    58    69    16
                       1   416   113    24    58    69    16
                    American East Cleveland OS 203 70 10 90
Speier, Chris        155    44     6    21    23    15
                      16  6631  1634    98   698   661   777
                    National East Chicago 3S 53 88 3 275
Wilkerson, Curt      236    56     0    27    15    11
                       4  1115   270     1   116    64    57
                    American West Texas 2S 125 199 13 230
Anderson, Dave       216    53     1    31    15    22
                       4   926   210     9   118    69   114
                    National West LosAngeles 3S 73 152 11 225
Baker, Dusty         242    58     4    25    19    27
                      19  7117  1981   242   964  1013   762
                    American West Oakland OF 90 4 0 .
Baylor, Don          585   139    31    93    94    62
                      17  7546  1982   315  1141  1179   727
                    American East Boston DH 0 0 0 950
Bilardello, Dann     191    37     4    12    17    14
                       4   773   163    16    61    74    52
                    National East Montreal C 391 38 8 .
Boston, Daryl        199    53     5    29    22    21
                       3   514   120     8    57    40    39
                    American West Chicago CF 152 3 5 75
Coles, Darnell       521   142    20    67    86    45
                       4   815   205    22    99   103    78
                    American East Detroit 3B 107 242 23 105
Collins, Dave        419   113     1    44    27    44
                      12  4484  1231    32   612   344   422
                    American East Detroit LF 211 2 1 .
Concepcion, Dave     311    81     3    42    30    26
                      17  8247  2198   100   950   909   690
                    National West Cincinnati UT 153 223 10 320
Daulton, Darren      138    31     8    18    21    38
                       3   244    53    12    33    32    55
                    National East Philadelphia C 244 21 4 .
DeCinces, Doug       512   131    26    69    96    52
                      14  5347  1397   221   712   815   548
                    American West California 3B 119 216 12 850
Evans, Darrell       507   122    29    78    85    91
                      18  7761  1947   347  1175  1152  1380
                    American East Detroit 1B 808 108 2 535
Evans, Dwight        529   137    26    86    97    97
                      15  6661  1785   291  1082   949   989
                    American East Boston RF 280 10 5 933.333
Garcia, Damaso       424   119     6    57    46    13
                       9  3651  1046    32   461   301   112
                    American East Toronto 2B 224 286 8 850
Gladden, Dan         351    97     4    55    29    39
                       4  1258   353    16   196   110   117
                    National West SanFrancisco CF 226 7 3 210
Heep, Danny          195    55     5    24    33    30
                       8  1313   338    25   144   149   153
                    National East NewYork OF 83 2 1 .
Henderson, Dave      388   103    15    59    47    39
                       6  2174   555    80   285   274   186
                    American West Seattle OF 182 9 4 325
Hill, Donnie         339    96     4    37    29    23
                       4  1064   290    11   123   108    55
                    American West Oakland 23 104 213 9 275
Kingman, Dave        561   118    35    70    94    33
                      16  6677  1575   442   901  1210   608
                    American West Oakland DH 463 32 8 .
Lopes, Davey         255    70     7    49    35    43
                      15  6311  1661   154  1019   608   820
                    National East Chicago 3O 51 54 8 450
Mattingly, Don       677   238    31   117   113    53
                       5  2223   737    93   349   401   171
                    American East NewYork 1B 1377 100 6 1975
Motley, Darryl       227    46     7    23    20    12
                       5  1325   324    44   156   158    67
                    American West KansasCity RF 92 2 2 .
Murphy, Dale         614   163    29    89    83    75
                      11  5017  1388   266   813   822   617
                    National West Atlanta CF 303 6 6 1900
Murphy, Dwayne       329    83     9    50    39    56
                       9  3828   948   145   575   528   635
                    American West Oakland CF 276 6 2 600
Parker, Dave         637   174    31    89   116    56
                      14  6727  2024   247   978  1093   495
                    National West Cincinnati RF 278 9 9 1041.667
Pasqua, Dan          280    82    16    44    45    47
                       2   428   113    25    61    70    63
                    American East NewYork LF 148 4 2 110
Porter, Darrell      155    41    12    21    29    22
                      16  5409  1338   181   746   805   875
                    American West Texas CD 165 9 1 260
Schofield, Dick      458   114    13    67    57    48
                       4  1350   298    28   160   123   122
                    American West California SS 246 389 18 475
Slaught, Don         314    83    13    39    46    16
                       5  1457   405    28   156   159    76
                    American West Texas C 533 40 4 431.5
Strawberry, Darryl   475   123    27    76    93    72
                       4  1810   471   108   292   343   267
                    National East NewYork RF 226 10 6 1220
Sveum, Dale          317    78     7    35    35    32
                       1   317    78     7    35    35    32
                    American East Milwaukee 3B 45 122 26 70
Tartabull, Danny     511   138    25    76    96    61
                       3   592   164    28    87   110    71
                    American West Seattle RF 157 7 8 145
Thon, Dickie         278    69     3    24    21    29
                       8  2079   565    32   258   192   162
                    National West Houston SS 142 210 10 .
Walling, Denny       382   119    13    54    58    36
                      12  2133   594    41   287   294   227
                    National West Houston 3B 59 156 9 595
Winfield, Dave       565   148    24    90   104    77
                      14  7287  2083   305  1135  1234   791
                    American East NewYork RF 292 9 5 1861.46
Cabell, Enos         277    71     2    27    29    14
                      15  5952  1647    60   753   596   259
                    National West LosAngeles 1B 360 32 5 .
Davis, Eric          415   115    27    97    71    68
                       3   711   184    45   156   119    99
                    National West Cincinnati LF 274 2 7 300
Milner, Eddie        424   110    15    70    47    36
                       7  2130   544    38   335   174   258
                    National West Cincinnati CF 292 6 3 490
Murray, Eddie        495   151    17    61    84    78
                      10  5624  1679   275   884  1015   709
                    American East Baltimore 1B 1045 88 13 2460
Riles, Ernest        524   132     9    69    47    54
                       2   972   260    14   123    92    90
                    American East Milwaukee SS 212 327 20 .
Romero, Ed           233    49     2    41    23    18
                       8  1350   336     7   166   122   106
                    American East Boston SS 102 132 10 375
Whitt, Ernie         395   106    16    48    56    35
                      10  2303   571    86   266   323   248
                    American East Toronto C 709 41 7 .
Lynn, Fred           397   114    23    67    67    53
                      13  5589  1632   241   906   926   716
                    American East Baltimore CF 244 2 4 .
Rayford, Floyd       210    37     8    15    19    15
                       6   994   244    36   107   114    53
                    American East Baltimore 3B 40 115 15 .
Stubbs, Franklin     420    95    23    55    58    37
                       3   646   139    31    77    77    61
                    National West LosAngeles LF 206 10 7 .
White, Frank         566   154    22    76    84    43
                      14  6100  1583   131   743   693   300
                    American West KansasCity 2B 316 439 10 750
Bell, George         641   198    31   101   108    41
                       5  2129   610    92   297   319   117
                    American East Toronto LF 269 17 10 1175
Braggs, Glenn        215    51     4    19    18    11
                       1   215    51     4    19    18    11
                    American East Milwaukee LF 116 5 12 70
Brett, George        441   128    16    70    73    80
                      14  6675  2095   209  1072  1050   695
                    American West KansasCity 3B 97 218 16 1500
Brock, Greg          325    76    16    33    52    37
                       5  1506   351    71   195   219   214
                    National West LosAngeles 1B 726 87 3 385
Carter, Gary         490   125    24    81   105    62
                      13  6063  1646   271   847   999   680
                    National East NewYork C 869 62 8 1925.571
Davis, Glenn         574   152    31    91   101    64
                       3   985   260    53   148   173    95
                    National West Houston 1B 1253 111 11 215
Foster, George       284    64    14    30    42    24
                      18  7023  1925   348   986  1239   666
                    National East NewYork LF 96 4 4 .
Gaetti, Gary         596   171    34    91   108    52
                       6  2862   728   107   361   401   224
                    American West Minneapolis 3B 118 334 21 900
Gagne, Greg          472   118    12    63    54    30
                       4   793   187    14   102    80    50
                    American West Minneapolis SS 228 377 26 155
Hendrick, George     283    77    14    45    47    26
                      16  6840  1910   259   915  1067   546
                    American West California OF 144 6 5 700
Hubbard, Glenn       408    94     4    42    36    66
                       9  3573   866    59   429   365   410
                    National West Atlanta 2B 282 487 19 535
Iorg, Garth          327    85     3    30    44    20
                       8  2140   568    16   216   208    93
                    American East Toronto 32 91 185 12 362.5
Matthews, Gary       370    96    21    49    46    60
                      15  6986  1972   231  1070   955   921
                    National East Chicago LF 137 5 9 733.333
Nettles, Graig       354    77    16    36    55    41
                      20  8716  2172   384  1172  1267  1057
                    National West SanDiego 3B 83 174 16 200
Pettis, Gary         539   139     5    93    58    69
                       5  1469   369    12   247   126   198
                    American West California CF 462 9 7 400
Redus, Gary          340    84    11    62    33    47
                       5  1516   376    42   284   141   219
                    National East Philadelphia LF 185 8 4 400
Templeton, Garry     510   126     2    42    44    35
                      11  5562  1578    44   703   519   256
                    National West SanDiego SS 207 358 20 737.5
Thomas, Gorman       315    59    16    45    36    58
                      13  4677  1051   268   681   782   697
                    American West Seattle DH 0 0 0 .
Walker, Greg         282    78    13    37    51    29
                       5  1649   453    73   211   280   138
                    American West Chicago 1B 670 57 5 500
Ward, Gary           380   120     5    54    51    31
                       8  3118   900    92   444   419   240
                    American West Texas LF 237 8 1 600
Wilson, Glenn        584   158    15    70    84    42
                       5  2358   636    58   265   316   134
                    National East Philadelphia RF 331 20 4 662.5
Baines, Harold       570   169    21    72    88    38
                       7  3754  1077   140   492   589   263
                    American West Chicago RF 295 15 5 950
Brooks, Hubie        306   104    14    50    58    25
                       7  2954   822    55   313   377   187
                    National East Montreal SS 116 222 15 750
Johnson, Howard      220    54    10    30    39    31
                       5  1185   299    40   145   154   128
                    National East NewYork 3S 50 136 20 297.5
McRae, Hal           278    70     7    22    37    18
                      18  7186  2081   190   935  1088   643
                    American West KansasCity DH 0 0 0 325
Reynolds, Harold     445    99     1    46    24    29
                       4   618   129     1    72    31    48
                    American West Seattle 2B 278 415 16 87.5
Spilman, Harry       143    39     5    18    30    15
                       9   639   151    16    80    97    61
                    National West SanFrancisco 1B 138 15 1 175
Winningham, Herm     185    40     4    23    11    18
                       3   524   125     7    58    37    47
                    National East Montreal OF 97 2 2 90
Barfield, Jesse      589   170    40   107   108    69
                       6  2325   634   128   371   376   238
                    American East Toronto RF 368 20 3 1237.5
Beniquez, Juan       343   103     6    48    36    40
                      15  4338  1193    70   581   421   325
                    American East Baltimore UT 211 56 13 430
Bonilla, Juan        284    69     1    33    18    25
                       5  1407   361     6   139    98   111
                    American East Baltimore 2B 122 140 5 .
Cangelosi, John      438   103     2    65    32    71
                       2   440   103     2    67    32    71
                    American West Chicago LF 276 7 9 100
Canseco, Jose        600   144    33    85   117    65
                       2   696   173    38   101   130    69
                    American West Oakland LF 319 4 14 165
Carter, Joe          663   200    29   108   121    32
                       4  1447   404    57   210   222    68
                    American East Cleveland RF 241 8 6 250
Clark, Jack          232    55     9    34    23    45
                      12  4405  1213   194   702   705   625
                    National East StLouis 1B 623 35 3 1300
Cruz, Jose           479   133    10    48    72    55
                      17  7472  2147   153   980  1032   854
                    National West Houston LF 237 5 4 773.333
Cruz, Julio          209    45     0    38    19    42
                      10  3859   916    23   557   279   478
                    American West Chicago 2B 132 205 5 .
Davis, Jody          528   132    21    61    74    41
                       6  2641   671    97   273   383   226
                    National East Chicago C 885 105 8 1008.333
Dwyer, Jim           160    39     8    18    31    22
                      14  2128   543    56   304   268   298
                    American East Baltimore DO 33 3 0 275
Franco, Julio        599   183    10    80    74    32
                       5  2482   715    27   330   326   158
                    American East Cleveland SS 231 374 18 775
Gantner, Jim         497   136     7    58    38    26
                      11  3871  1066    40   450   367   241
                    American East Milwaukee 2B 304 347 10 850
Grubb, Johnny        210    70    13    32    51    28
                      15  4040  1130    97   544   462   551
                    American East Detroit DH 0 0 0 365
Hairston, Jerry      225    61     5    32    26    26
                      11  1568   408    25   202   185   257
                    American West Chicago UT 132 9 0 .
Howell, Jack         151    41     4    26    21    19
                       2   288    68     9    45    39    35
                    American West California 3B 28 56 2 95
Kruk, John           278    86     4    33    38    45
                       1   278    86     4    33    38    45
                    National West SanDiego LF 102 4 2 110
Leonard, Jeffrey     341    95     6    48    42    20
                      10  2964   808    81   379   428   221
                    National West SanFrancisco LF 158 4 5 100
Morrison, Jim        537   147    23    58    88    47
                      10  2744   730    97   302   351   174
                    National East Pittsburgh 3B 92 257 20 277.5
Moses, John          399   102     3    56    34    34
                       5   670   167     4    89    48    54
                    American West Seattle CF 211 9 3 80
Mumphrey, Jerry      309    94     5    37    32    26
                      13  4618  1330    57   616   522   436
                    National East Chicago OF 161 3 3 600
Orsulak, Joe         401   100     2    60    19    28
                       4   876   238     2   126    44    55
                    National East Pittsburgh RF 193 11 4 .
Orta, Jorge          336    93     9    35    46    23
                      15  5779  1610   128   730   741   497
                    American West KansasCity DH 0 0 0 .
Presley, Jim         616   163    27    83   107    32
                       3  1437   377    65   181   227    82
                    American West Seattle 3B 110 308 15 200
Quirk, Jamie         219    47     8    24    26    17
                      12  1188   286    23   100   125    63
                    American West KansasCity CS 260 58 4 .
Ray, Johnny          579   174     7    67    78    58
                       6  3053   880    32   366   337   218
                    National East Pittsburgh 2B 280 479 5 657
Reed, Jeff           165    39     2    13     9    16
                       3   196    44     2    18    10    18
                    American West Minneapolis C 332 19 2 75
Rice, Jim            618   200    20    98   110    62
                      13  7127  2163   351  1104  1289   564
                    American East Boston LF 330 16 8 2412.5
Royster, Jerry       257    66     5    31    26    32
                      14  3910   979    33   518   324   382
                    National West SanDiego UT 87 166 14 250
Russell, John        315    76    13    35    60    25
                       3   630   151    24    68    94    55
                    National East Philadelphia C 498 39 13 155
Samuel, Juan         591   157    16    90    78    26
                       4  2020   541    52   310   226    91
                    National East Philadelphia 2B 290 440 25 640
Shelby, John         404    92    11    54    49    18
                       6  1354   325    30   188   135    63
                    American East Baltimore OF 222 5 5 300
Skinner, Joel        315    73     5    23    37    16
                       4   450   108     6    38    46    28
                    American West Chicago C 227 15 3 110
Stone, Jeff          249    69     6    32    19    20
                       4   702   209    10    97    48    44
                    National East Philadelphia OF 103 8 2 .
Sundberg, Jim        429    91    12    41    42    57
                      13  5590  1397    83   578   579   644
                    American West KansasCity C 686 46 4 825
Traber, Jim          212    54    13    28    44    18
                       2   233    59    13    31    46    20
                    American East Baltimore UT 243 23 5 .
Uribe, Jose          453   101     3    46    43    61
                       3   948   218     6    96    72    91
                    National West SanFrancisco SS 249 444 16 195
Willard, Jerry       161    43     4    17    26    22
                       3   707   179    21    77    99    76
                    American West Oakland C 300 12 2 .
Youngblood, Joel     184    47     5    20    28    18
                      11  3327   890    74   419   382   304
                    National West SanFrancisco OF 49 2 0 450
Bass, Kevin          591   184    20    83    79    38
                       5  1689   462    40   219   195    82
                    National West Houston RF 303 12 5 630
Daniels, Kal         181    58     6    34    23    22
                       1   181    58     6    34    23    22
                    National West Cincinnati OF 88 0 3 86.5
Gibson, Kirk         441   118    28    84    86    68
                       8  2723   750   126   433   420   309
                    American East Detroit RF 190 2 2 1300
Griffey, Ken         490   150    21    69    58    35
                      14  6126  1839   121   983   707   600
                    American East NewYork OF 96 5 3 1000
Hernandez, Keith     551   171    13    94    83    94
                      13  6090  1840   128   969   900   917
                    National East NewYork 1B 1199 149 5 1800
Hrbek, Kent          550   147    29    85    91    71
                       6  2816   815   117   405   474   319
                    American West Minneapolis 1B 1218 104 10 1310
Landreaux, Ken       283    74     4    34    29    22
                      10  3919  1062    85   505   456   283
                    National West LosAngeles OF 145 5 7 737.5
McReynolds, Kevin    560   161    26    89    96    66
                       4  1789   470    65   233   260   155
                    National West SanDiego CF 332 9 8 625
Mitchell, Kevin      328    91    12    51    43    33
                       2   342    94    12    51    44    33
                    National East NewYork OS 145 59 8 125
Moreland, Keith      586   159    12    72    79    53
                       9  3082   880    83   363   477   295
                    National East Chicago RF 181 13 4 1043.333
Oberkfell, Ken       503   136     5    62    48    83
                      10  3423   970    20   408   303   414
                    National West Atlanta 3B 65 258 8 725
Phelps, Ken          344    85    24    69    64    88
                       7   911   214    64   150   156   187
                    American West Seattle DH 0 0 0 300
Puckett, Kirby       680   223    31   119    96    34
                       3  1928   587    35   262   201    91
                    American West Minneapolis CF 429 8 6 365
Stillwell, Kurt      279    64     0    31    26    30
                       1   279    64     0    31    26    30
                    National West Cincinnati SS 107 205 16 75
Durham, Leon         484   127    20    66    65    67
                       7  3006   844   116   436   458   377
                    National East Chicago 1B 1231 80 7 1183.333
Dykstra, Len         431   127     8    77    45    58
                       2   667   187     9   117    64    88
                    National East NewYork CF 283 8 3 202.5
Herndon, Larry       283    70     8    33    37    27
                      12  4479  1222    94   557   483   307
                    American East Detroit OF 156 2 2 225
Lacy, Lee            491   141    11    77    47    37
                      15  4291  1240    84   615   430   340
                    American East Baltimore RF 239 8 2 525
Matuszek, Len        199    52     9    26    28    21
                       6   805   191    30   113   119    87
                    National West LosAngeles O1 235 22 5 265
Moseby, Lloyd        589   149    21    89    86    64
                       7  3558   928   102   513   471   351
                    American East Toronto CF 371 6 6 787.5
Parrish, Lance       327    84    22    53    62    38
                      10  4273  1123   212   577   700   334
                    American East Detroit C 483 48 6 800
Parrish, Larry       464   128    28    67    94    52
                      13  5829  1552   210   740   840   452
                    American West Texas DH 0 0 0 587.5
Rivera, Luis         166    34     0    20    13    17
                       1   166    34     0    20    13    17
                    National East Montreal SS 64 119 9 .
Sheets, Larry        338    92    18    42    60    21
                       3   682   185    36    88   112    50
                    American East Baltimore DH 0 0 0 145
Smith, Lonnie        508   146     8    80    44    46
                       9  3148   915    41   571   289   326
                    American West KansasCity LF 245 5 9 .
Whitaker, Lou        584   157    20    95    73    63
                      10  4704  1320    93   724   522   576
                    American East Detroit 2B 276 421 11 420
Aldrete, Mike        216    54     2    27    25    33
                       1   216    54     2    27    25    33
                    National West SanFrancisco 1O 317 36 1 75
Barrett, Marty       625   179     4    94    60    65
                       5  1696   476    12   216   163   166
                    American East Boston 2B 303 450 14 575
Brown, Mike          243    53     4    18    26    27
                       4   853   228    23   101   110    76
                    National East Pittsburgh OF 107 3 3 .
Davis, Mike          489   131    19    77    55    34
                       7  2051   549    62   300   263   153
                    American West Oakland RF 310 9 9 780
Diaz, Mike           209    56    12    22    36    19
                       2   216    58    12    24    37    19
                    National East Pittsburgh O1 201 6 3 90
Duncan, Mariano      407    93     8    47    30    30
                       2   969   230    14   121    69    68
                    National West LosAngeles SS 172 317 25 150
Easler, Mike         490   148    14    64    78    49
                      13  3400  1000   113   445   491   301
                    American East NewYork DH 0 0 0 700
Fitzgerald, Mike     209    59     6    20    37    27
                       4   884   209    14    66   106    92
                    National East Montreal C 415 35 3 .
Hall, Mel            442   131    18    68    77    33
                       6  1416   398    47   210   203   136
                    American East Cleveland LF 233 7 7 550
Hatcher, Mickey      317    88     3    40    32    19
                       8  2543   715    28   269   270   118
                    American West Minneapolis UT 220 16 4 .
Heath, Mike          288    65     8    30    36    27
                       9  2815   698    55   315   325   189
                    National East StLouis C 259 30 10 650
Kingery, Mike        209    54     3    25    14    12
                       1   209    54     3    25    14    12
                    American West KansasCity OF 102 6 3 68
LaValliere, Mike     303    71     3    18    30    36
                       3   344    76     3    20    36    45
                    National East StLouis C 468 47 6 100
Marshall, Mike       330    77    19    47    53    27
                       6  1928   516    90   247   288   161
                    National West LosAngeles RF 149 8 6 670
Pagliarulo, Mike     504   120    28    71    71    54
                       3  1085   259    54   150   167   114
                    American East NewYork 3B 103 283 19 175
Salas, Mark          258    60     8    28    33    18
                       3   638   170    17    80    75    36
                    American West Minneapolis C 358 32 8 137
Schmidt, Mike        552   160    37    97   119    89
                      15  7292  1954   495  1347  1392  1354
                    National East Philadelphia 3B 78 220 6 2127.333
Scioscia, Mike       374    94     5    36    26    62
                       7  1968   519    26   181   199   288
                    National West LosAngeles C 756 64 15 875
Tettleton, Mickey    211    43    10    26    35    39
                       3   498   116    14    59    55    78
                    American West Oakland C 463 32 8 120
Thompson, Milt       299    75     6    38    23    26
                       3   580   160     8    71    33    44
                    National East Philadelphia CF 212 1 2 140
Webster, Mitch       576   167     8    89    49    57
                       4   822   232    19   132    83    79
                    National East Montreal CF 325 12 8 210
Wilson, Mookie       381   110     9    61    45    32
                       7  3015   834    40   451   249   168
                    National East NewYork OF 228 7 5 800
Wynne, Marvell       288    76     7    34    37    15
                       4  1644   408    16   198   120   113
                    National West SanDiego OF 203 3 3 240
Young, Mike          369    93     9    43    42    49
                       5  1258   323    54   181   177   157
                    American East Baltimore LF 149 1 6 350
Esasky, Nick         330    76    12    35    41    47
                       4  1367   326    55   167   198   167
                    National West Cincinnati 1B 512 30 5 .
Guillen, Ozzie       547   137     2    58    47    12
                       2  1038   271     3   129    80    24
                    American West Chicago SS 261 459 22 175
McDowell, Oddibe     572   152    18   105    49    65
                       2   978   249    36   168    91   101
                    American West Texas CF 325 13 3 200
Moreno, Omar         359    84     4    46    27    21
                      12  4992  1257    37   699   386   387
                    National West Atlanta RF 151 8 5 .
Smith, Ozzie         514   144     0    67    54    79
                       9  4739  1169    13   583   374   528
                    National East StLouis SS 229 453 15 1940
Virgil, Ozzie        359    80    15    45    48    63
                       7  1493   359    61   176   202   175
                    National West Atlanta C 682 93 13 700
Bradley, Phil        526   163    12    88    50    77
                       4  1556   470    38   245   167   174
                    American West Seattle LF 250 11 1 750
Garner, Phil         313    83     9    43    41    30
                      14  5885  1543   104   751   714   535
                    National West Houston 3B 58 141 23 450
Incaviglia, Pete     540   135    30    82    88    55
                       1   540   135    30    82    88    55
                    American West Texas RF 157 6 14 172
Molitor, Paul        437   123     9    62    55    40
                       9  4139  1203    79   676   390   364
                    American East Milwaukee 3B 82 170 15 1260
O'Brien, Pete        551   160    23    86    90    87
                       5  2235   602    75   278   328   273
                    American West Texas 1B 1224 115 11 .
Rose, Pete           237    52     0    15    25    30
                      24 14053  4256   160  2165  1314  1566
                    National West Cincinnati 1B 523 43 6 750
Sheridan, Pat        236    56     6    41    19    21
                       5  1257   329    24   166   125   105
                    American East Detroit OF 172 1 4 190
Tabler, Pat          473   154     6    61    48    29
                       6  1966   566    29   250   252   178
                    American East Cleveland 1B 846 84 9 580
Belliard, Rafael     309    72     0    33    31    26
                       5   354    82     0    41    32    26
                    National East Pittsburgh SS 117 269 12 130
Burleson, Rick       271    77     5    35    29    33
                      12  4933  1358    48   630   435   403
                    American West California UT 62 90 3 450
Bush, Randy          357    96     7    50    45    39
                       5  1394   344    43   178   192   136
                    American West Minneapolis LF 167 2 4 300
Cerone, Rick         216    56     4    22    18    15
                      12  2796   665    43   266   304   198
                    American East Milwaukee C 391 44 4 250
Cey, Ron             256    70    13    42    36    44
                      16  7058  1845   312   965  1128   990
                    National East Chicago 3B 41 118 8 1050
Deer, Rob            466   108    33    75    86    72
                       3   652   142    44   102   109   102
                    American East Milwaukee RF 286 8 8 215
Dempsey, Rick        327    68    13    42    29    45
                      18  3949   939    78   438   380   466
                    American East Baltimore C 659 53 7 400
Gedman, Rich         462   119    16    49    65    37
                       7  2131   583    69   244   288   150
                    American East Boston C 866 65 6 .
Hassey, Ron          341   110     9    45    49    46
                       9  2331   658    50   249   322   274
                    American East NewYork C 251 9 4 560
Henderson, Rickey    608   160    28   130    74    89
                       8  4071  1182   103   862   417   708
                    American East NewYork CF 426 4 6 1670
Jackson, Reggie      419   101    18    65    58    92
                      20  9528  2510   548  1509  1659  1342
                    American West California DH 0 0 0 487.5
Jones, Ruppert       393    90    17    73    49    64
                      11  4223  1056   139   618   551   514
                    American West California RF 205 5 4 .
Kittle, Ron          376    82    21    42    60    35
                       5  1770   408   115   238   299   157
                    American West Chicago DH 0 0 0 425
Knight, Ray          486   145    11    51    76    40
                      11  3967  1102    67   410   497   284
                    National East NewYork 3B 88 204 16 500
Kutcher, Randy       186    44     7    28    16    11
                       1   186    44     7    28    16    11
                    National West SanFrancisco OF 99 3 1 .
Law, Rudy            307    80     1    42    36    29
                       7  2421   656    18   379   198   184
                    American West KansasCity OF 145 2 2 .
Leach, Rick          246    76     5    35    39    13
                       6   912   234    12   102    96    80
                    American East Toronto DO 44 0 1 250
Manning, Rick        205    52     8    31    27    17
                      12  5134  1323    56   643   445   459
                    American East Milwaukee OF 155 3 2 400
Mulliniks, Rance     348    90    11    50    45    43
                      10  2288   614    43   295   273   269
                    American East Toronto 3B 60 176 6 450
Oester, Ron          523   135     8    52    44    52
                       9  3368   895    39   377   284   296
                    National West Cincinnati 2B 367 475 19 750
Quinones, Rey        312    68     2    32    22    24
                       1   312    68     2    32    22    24
                    American East Boston SS 86 150 15 70
Ramirez, Rafael      496   119     8    57    33    21
                       7  3358   882    36   365   280   165
                    National West Atlanta S3 155 371 29 875
Reynolds, R.J.       402   108     9    63    48    40
                       4  1034   278    16   135   125    79
                    National East Pittsburgh LF 190 2 9 190
Roenicke, Ron        275    68     5    42    42    61
                       6   961   238    16   128   104   172
                    National East Philadelphia OF 181 3 2 191
Sandberg, Ryne       627   178    14    68    76    46
                       6  3146   902    74   494   345   242
                    National East Chicago 2B 309 492 5 740
Santana, Rafael      394    86     1    38    28    36
                       4  1089   267     3    94    71    76
                    National East NewYork SS 203 369 16 250
Schu, Rick           208    57     8    32    25    18
                       3   653   170    17    98    54    62
                    National East Philadelphia 3B 42 94 13 140
Sierra, Ruben        382   101    16    50    55    22
                       1   382   101    16    50    55    22
                    American West Texas OF 200 7 6 97.5
Smalley, Roy         459   113    20    59    57    68
                      12  5348  1369   155   713   660   735
                    American West Minneapolis DH 0 0 0 740
Thompson, Robby      549   149     7    73    47    42
                       1   549   149     7    73    47    42
                    National West SanFrancisco 2B 255 450 17 140
Wilfong, Rob         288    63     3    25    33    16
                      10  2682   667    38   315   259   204
                    American West California 2B 135 257 7 341.667
Williams, Reggie     303    84     4    35    32    23
                       2   312    87     4    39    32    23
                    National West LosAngeles CF 179 5 3 .
Yount, Robin         522   163     9    82    46    62
                      13  7037  2019   153  1043   827   535
                    American East Milwaukee CF 352 9 1 1000
Balboni, Steve       512   117    29    54    88    43
                       6  1750   412   100   204   276   155
                    American West KansasCity 1B 1236 98 18 100
Bradley, Scott       220    66     5    20    28    13
                       3   290    80     5    27    31    15
                    American West Seattle C 281 21 3 90
Bream, Sid           522   140    16    73    77    60
                       4   730   185    22    93   106    86
                    National East Pittsburgh 1B 1320 166 17 200
Buechele, Steve      461   112    18    54    54    35
                       2   680   160    24    76    75    49
                    American West Texas 3B 111 226 11 135
Dunston, Shawon      581   145    17    66    68    21
                       2   831   210    21   106    86    40
                    National East Chicago SS 320 465 32 155
Fletcher, Scott      530   159     3    82    50    47
                       6  1619   426    11   218   149   163
                    American West Texas SS 196 354 15 475
Garvey, Steve        557   142    21    58    81    23
                      18  8759  2583   271  1138  1299   478
                    National West SanDiego 1B 1160 53 7 1450
Jeltz, Steve         439    96     0    44    36    65
                       4   711   148     1    68    56    99
                    National East Philadelphia SS 229 406 22 150
Lombardozzi, Steve   453   103     8    53    33    52
                       2   507   123     8    63    39    58
                    American West Minneapolis 2B 289 407 6 105
Owen, Spike          528   122     1    67    45    51
                       4  1716   403    12   211   146   155
                    American West Seattle SS 209 372 17 350
Sax, Steve           633   210     6    91    56    59
                       6  3070   872    19   420   230   274
                    National West LosAngeles 2B 367 432 16 90
Armas, Tony          425   112    11    40    58    24
                      11  4513  1134   224   542   727   230
                    American East Boston CF 247 4 8 .
Bernazard, Tony      562   169    17    88    73    53
                       8  3181   841    61   450   342   373
                    American East Cleveland 2B 351 442 17 530
Brookens, Tom        281    76     3    42    25    20
                       8  2658   657    48   324   300   179
                    American East Detroit UT 106 144 7 341.667
Brunansky, Tom       593   152    23    69    75    53
                       6  2765   686   133   369   384   321
                    American West Minneapolis RF 315 10 6 940
Fernandez, Tony      687   213    10    91    65    27
                       4  1518   448    15   196   137    89
                    American East Toronto SS 294 445 13 350
Flannery, Tim        368   103     3    48    28    54
                       8  1897   493     9   207   162   198
                    National West SanDiego 2B 209 246 3 326.667
Foley, Tom           263    70     1    26    23    30
                       4   888   220     9    83    82    86
                    National East Montreal UT 81 147 4 250
Gwynn, Tony          642   211    14   107    59    52
                       5  2364   770    27   352   230   193
                    National West SanDiego RF 337 19 4 740
Harper, Terry        265    68     8    26    30    29
                       7  1337   339    32   135   163   128
                    National West Atlanta OF 92 5 3 425
Harrah, Toby         289    63     7    36    41    44
                      17  7402  1954   195  1115   919  1153
                    American West Texas 2B 166 211 7 .
Herr, Tommy          559   141     2    48    61    73
                       8  3162   874    16   421   349   359
                    National East StLouis 2B 352 414 9 925
Hulett, Tim          520   120    17    53    44    21
                       4   927   227    22   106    80    52
                    American West Chicago 3B 70 144 11 185
Kennedy, Terry       432   114    12    46    57    37
                       9  3373   916    82   347   477   238
                    National West SanDiego C 692 70 8 920
Landrum, Tito        205    43     2    24    17    20
                       7   854   219    12   105    99    71
                    National East StLouis OF 131 6 1 286.667
Laudner, Tim         193    47    10    21    29    24
                       6  1136   256    42   129   139   106
                    American West Minneapolis C 299 13 5 245
O'Malley, Tom        181    46     1    19    18    17
                       5   937   238     9    88    95   104
                    American East Baltimore 3B 37 98 9 .
Paciorek, Tom        213    61     4    17    22     3
                      17  4061  1145    83   488   491   244
                    American West Texas UT 178 45 4 235
Pena, Tony           510   147    10    56    52    53
                       7  2872   821    63   307   340   174
                    National East Pittsburgh C 810 99 18 1150
Pendleton, Terry     578   138     1    56    59    34
                       3  1399   357     7   149   161    87
                    National East StLouis 3B 133 371 20 160
Perez, Tony          200    51     2    14    29    25
                      23  9778  2732   379  1272  1652   925
                    National West Cincinnati 1B 398 29 7 .
Phillips, Tony       441   113     5    76    52    76
                       5  1546   397    17   226   149   191
                    American West Oakland 2B 160 290 11 425
Puhl, Terry          172    42     3    17    14    15
                      10  4086  1150    57   579   363   406
                    National West Houston OF 65 0 0 900
Raines, Tim          580   194     9    91    62    78
                       8  3372  1028    48   604   314   469
                    National East Montreal LF 270 13 6 .
Simmons, Ted         127    32     4    14    25    12
                      19  8396  2402   242  1048  1348   819
                    National West Atlanta UT 167 18 6 500
Teufel, Tim          279    69     4    35    31    32
                       4  1359   355    31   180   148   158
                    National East NewYork 2B 133 173 9 277.5
Wallach, Tim         480   112    18    50    71    44
                       7  3031   771   110   338   406   239
                    National East Montreal 3B 94 270 16 750
Coleman, Vince       600   139     0    94    29    60
                       2  1236   309     1   201    69   110
                    National East StLouis LF 300 12 9 160
Hayes, Von           610   186    19   107    98    74
                       6  2728   753    69   399   366   286
                    National East Philadelphia 1B 1182 96 13 1300
Law, Vance           360    81     5    37    44    37
                       7  2268   566    41   279   257   246
                    National East Montreal 2B 170 284 3 525
Backman, Wally       387   124     1    67    27    36
                       7  1775   506     6   272   125   194
                    National East NewYork 2B 186 290 17 550
Boggs, Wade          580   207     8   107    71   105
                       5  2778   978    32   474   322   417
                    American East Boston 3B 121 267 19 1600
Clark, Will          408   117    11    66    41    34
                       1   408   117    11    66    41    34
                    National West SanFrancisco 1B 942 72 11 120
Joyner, Wally        593   172    22    82   100    57
                       1   593   172    22    82   100    57
                    American West California 1B 1222 139 15 165
Krenchicki, Wayne    221    53     2    21    23    22
                       8  1063   283    15   107   124   106
                    National East Montreal 13 325 58 6 .
McGee, Willie        497   127     7    65    48    37
                       5  2703   806    32   379   311   138
                    National East StLouis CF 325 9 3 700
Randolph, Willie     492   136     5    76    50    94
                      12  5511  1511    39   897   451   875
                    American East NewYork 2B 313 381 20 875
Tolleson, Wayne      475   126     3    61    43    52
                       6  1700   433     7   217    93   146
                    American West Chicago 3B 37 113 7 385
Upshaw, Willie       573   144     9    85    60    78
                       8  3198   857    97   470   420   332
                    American East Toronto 1B 1314 131 12 960
Wilson, Willie       631   170     9    77    44    31
                      11  4908  1457    30   775   357   249
                    American West KansasCity CF 408 4 3 1000
;