#!/usr/bin/perl
use Config; 
#Prints to standard output the commands needed to run the first mic
#distribution estimation experiment.  The commands put their output in
#experiment1 subdirectory of the current directory and assume that the
#distribution estimation code is in distr.jar in the current
#directory.  The resultant commands can then be divided up into
#different files and run on different processors or machines for
#parallelization.


#477 random number seeds. This list came from random.org and was
#originally 1908 hexadecimal values from 0..65535 inclusive arranged
#in 4 columns that were pasted together in a text editor.
my @seeds = (0x700da2b114dbefb2, 0x019aea3d9d48eacb, 0xb03b6f6ea69bb064, 0xba153a7e41ab7466, 0xc50f74e4f8f3a759, 0x5bfd60712344d97a, 0xf75686c46a50608d, 0x4901a9908030bafb, 0x3c0f4af6554f3cc1, 0xef01f6c53f248c8b, 0x03a47c743bbcd4aa, 0x9ecd872edda126bd, 0x4e372c1119c35b2a, 0x7dd765cdf584ec2c, 0xb411908e098adf05, 0x7b2b455760a93c03, 0xf813da07a8155915, 0xf07fb5e014ce3e80, 0x0922e3fce56ccdc2, 0x5f14b71962adcd40, 0xc8bcf701cbec9240, 0x671dd770f2160a4a, 0x686ded2b209edcda, 0x8610578ac7668016, 0xbd8baa9c82a0bed7, 0xc9e01f0c2ccd3b94, 0x6f2cb15fe85e1bb7, 0x5881e683b84b41e8, 0x4ac530e7ab500c9b, 0x05bedcc1ddd27553, 0x08ecc9451ad54842, 0x8e5f6edcb6a4b4d1, 0xdd57389f1f8a028f, 0x4eb0cd4cab3602bd, 0x215aee4fee827114, 0x681288d6c9a9bd58, 0x71f33a41a973cdf3, 0x1601285f40ecb70a, 0xfe508f9522eb4aba, 0x03e98b553351cfbe, 0x80516f8d01829b1a, 0x2e48562254430c07, 0xcba764d5be11dd64, 0xf08549ee0098ad70, 0x898bfec162135b60, 0x3a78c2d64500b925, 0x08bd64577320dca7, 0x5ec6bae3084a0cd6, 0xc18b9210bc4a8923, 0x86341478eec0bf89, 0x637aaed1e494ae52, 0xf7c7f1ccf654163d, 0x9a28bf39683a9483, 0xb68f661b5e82be60, 0x91e034cf34cc34fe, 0x47009db918517efd, 0x0b1356fd04c1b7e6, 0x17bd712a04308082, 0xce91b4b85b42b0f0, 0x20e9100ebcb0c082, 0x843edbd17932ce4e, 0xd302fe98f50e3972, 0x40ab9e3f255ae22f, 0x2e417c03a75ec60c, 0x3299e81daf5956b5, 0xc743c6d14a095394, 0x1246836b639c9aee, 0x092ddffcaffecd27, 0xa5f1ee943cc7fc13, 0xe29465773d172015, 0xc8fdf672577eb436, 0x98dc1c9206da329a, 0x2d1bb102b5158737, 0x8685958cc564a7cd, 0xaccdb8238c098256, 0xc9d93633c6c44b0e, 0x8f014f1da6afd84b, 0xcf514e792c322dd8, 0x68f10329d7c931db, 0x5bde7fcc08f7de98, 0x4e2f4c69740d46d0, 0xfd354f0891206dbb, 0xbdeca4c6d82d5ebe, 0x1511f3b32ba90a23, 0xbacd65d05b89a636, 0xdf90ea51cc085111, 0x962f7b0c5627f0a1, 0xb9a2e4b3bd6857b7, 0x227c6a36a1651be0, 0xa49529e8b169c356, 0x8884a45b218e4643, 0xebf12d5d48b548d6, 0x87f58ef618dcb25a, 0x6b6382103101933c, 0x2fe8a20550e7da45, 0x0da397d7fba6342c, 0xf712c8a804e5b3e2, 0xd306b3dc1a209603, 0xb82953bf9700b9a8, 0x13c2438a2c0b1953, 0xe84085c0d4e0b150, 0x6fb86d6b85013320, 0x6192da959ddf0ad1, 0xfa7b398a7a5e12a9, 0x8d337fcb1a83a453, 0xfc8ce998756447e4, 0xdbae451c4f1a843f, 0xeb264fe1b9106105, 0x6890f06d9a01a505, 0xbd31ac745af709b1, 0x07c9088ee322fbcb, 0x15f66afff3611d4c, 0x0a066e103fca2b45, 0x73d0c10a35db1aa2, 0x0690e6ea9d482249, 0x937c7682e1e26bf8, 0x433f05a1fabbac0d, 0x982166e86cbd674d, 0x4d4ad1712356876f, 0x75db1facb3e273da, 0x32a02c2fdb5fc2df, 0xd14c25d3ff8b9511, 0xc75df40641b3e516, 0x1e32cd3985b190dd, 0x60ee9cba23d3d269, 0x5f9aa96ce07b4187, 0x4f16e0ac28c93843, 0x09e192c41dbccb49, 0xe8400fadc097fc7f, 0x8649248c90bea0c3, 0xed68b21ae3bbd6e9, 0x41ee49a064114a21, 0xdab8ef836798b407, 0x728e0715041e5e2a, 0x8310cbb5f861f300, 0xca1c7f2cb19bc636, 0xae44bc35d5314fef, 0xfcd3452c4aafd5b9, 0xdeba47d0e8cdf4c2, 0xac222b07ac36f653, 0xc565215ce8de4c90, 0xd2bf639d2b6ff2ae, 0xee5fbe1a1dc54972, 0xb2fcfdf6a8fb6e05, 0x689df297c9265628, 0x7d0ca9dd4abd65f4, 0x7cfbe0f8e1cd0a70, 0x70229cde85130ae5, 0x9fcbbd53c921d44d, 0xb63a4ac3ece355e0, 0xa6b7086eca26e069, 0x02e532403136cb99, 0x731f8ef91d708e8e, 0x38b8c957d5555ffc, 0x95d3de3961a4d3cb, 0x58fc94df9a916d29, 0xaebf19cf2e00f8aa, 0xd9efc68626ee8564, 0xbd450fd5e510a836, 0x17c6d1600eb8c7fd, 0xf293b3deb9db6d85, 0xa75b328d80b4c48c, 0x125232b2d207959b, 0xdb7b64b0406e5ad3, 0xbc02e77ce8e2e9ea, 0xe3bd9e6c53fd3293, 0x03841e04fb94c2ed, 0x265e4943abcca298, 0xd790c1699653a364, 0xbdcbf11dda9686c8, 0xad6e55b421392c56, 0x6fdbd98f01aba858, 0x8d360d9b2741e390, 0x1fc8496311601c0b, 0x6aac143840f3c0e8, 0x79674ba0252bbac6, 0x0da35279c9c5d597, 0x547f14b5d17d5a4a, 0x1f66698a3a55187c, 0xb17d31174cbd8ff0, 0x9e75cf6ddbe33b6c, 0x225b7aeff487b1b9, 0x1123d45a898b6152, 0x7c5de6928d7cc6fa, 0x8941a06d91a8c5aa, 0x758b1cc677b1f967, 0x1405cbae3dbb4b9b, 0x7e72c04463d154a7, 0x57489ed3ab85b00c, 0x004e4891331c592b, 0x2df46099a54da8f4, 0x7502f92135276e02, 0xda6b003e03194398, 0x47c16ca83b14e8f3, 0x3f383406f047e126, 0x1191049bcf21c8dc, 0x8cd26418b3631727, 0x28de88c71c2f218f, 0x53dff2ba282b0e04, 0x321efe38a00cea58, 0xd09bd9cf94e44e9b, 0x613f6cb26b32ae11, 0xfd3c2a6ea3389dcd, 0x5e951db02505ceeb, 0x42d10f16e87848ae, 0xc064c5d9cf941d8b, 0x4fe30557d89d0e6e, 0x5bab96b90677c10c, 0x41dc759c5fb04e5b, 0x11489ee43b07c27d, 0xf146a68ee86cefab, 0x7043926a3f0ebb42, 0xc440aca942b616ab, 0x7fe796a333abf8a4, 0xbc41786d2585b4b6, 0x9e253c48fbd4028e, 0x4c8baf294c6faec0, 0xc3ae59ae6d45d50a, 0xba3f045113d9a9a3, 0x5b3eacf6a34d350c, 0xa412b71f4db22363, 0x78311d966cf41b29, 0xd638c0dd28a2cdf1, 0xcdd3217df05a5084, 0x14145583f34df0f7, 0xd1eb268fed254235, 0xa07bbf9724f27b77, 0xb5550ec38c350a28, 0xf4efcd841b7a5385, 0x43f36128edfe2073, 0xb96d2d8a8a23c4c9, 0x0a209ab3568611f4, 0xf3cfdeb5037562a3, 0x02a25cdb3f4b214c, 0xc5fd73297874aec4, 0x6825b85c0c762ef7, 0x1e64b46b9aec3ae1, 0xa3e02093d1376b4f, 0x25e6709d6a8f4192, 0x784a336477d253cd, 0x2c01911100cf4f5b, 0x40b433a0ecb946fc, 0xd0f712055b2f9331, 0x112287dc3a9e2509, 0x6ad467883bcd9971, 0x9dabdb6bd7920b50, 0x5f85a94140cbc3ec, 0x30babb4f736ebeb7, 0x2e433c22748f2bf1, 0xca6aff31bbfb7b06, 0x96d4ce5e5e0b1dd1, 0x06336e3b6e7f6830, 0xcb6d2467800032cc, 0x8cace51ece8fbfe2, 0x412a31b7cd6f87a7, 0x50f1550c69ce12d0, 0x92df22d3194102ea, 0x46bd9ddc5da26f9c, 0x204c7de26b4c03fd, 0xd06b6649d850f8c3, 0x031ed79e494a4f72, 0x2157257964bc954a, 0x85cbe8728ef77b5c, 0x072bf44881e3dead, 0x5ba2769231d98d4f, 0x209995473642522d, 0x61f7e04161836220, 0x83a53950877c2fb1, 0x81bf8dc8a8e8593a, 0xee25b2aaf4d322f0, 0x2583f37615240661, 0xcb079107a41db670, 0x4fc830c02a2be70e, 0x8b77ab84a78393f5, 0xec26d9aff2f0f8f7, 0x9e4d435de6aac5d6, 0x55b69257743b717c, 0xf5ddc5489d778594, 0x5493b135e93b5cf1, 0x9664f013058bc44b, 0x266797313f555bc9, 0xe18a7ff7b93fa870, 0xaf7798c7a970711e, 0x6f8cbbf5a735f580, 0x03dea8adbedc7f17, 0x245acc708ad3101b, 0xaa687c89a3446e94, 0x9eb6cba976179cc0, 0xfde6a8e00334f963, 0x3df06052a5bcf3d3, 0x085940082a37c75a, 0x4798246dd391e946, 0xa37403ab23c8ca9e, 0x3dd1df3a3e676053, 0x50320381daaa4c6b, 0x5e33366dd83741e0, 0x439490873dc013e8, 0x71e7747f27d62fca, 0x0d0334ad8c92334b, 0x0d987089b44920c1, 0xdf08472d88b4134a, 0x760961cdcb165dd8, 0x983936d63686c881, 0x4f623382af96925e, 0x9a752dc81283384c, 0x239277f595a88391, 0xfa13f98f66d56e5c, 0x86e012f410381364, 0xa715f80e7cffd580, 0xda7972d30391dc5e, 0xd8ae4d5f5ab399d0, 0x3f603a46e7de15f9, 0x08fee9caa6d668e5, 0xecbd6a99fe5db9a6, 0x0453d9c3c7ad53c6, 0x9a3e4b41a2da2280, 0x8e6c5629d30b3bc7, 0x558322d518872e44, 0xdd132753baaadd17, 0x986d8a7e2a9e5425, 0x237789acaf547e82, 0x27eb895b259033f6, 0x3a51e14193643ed1, 0xc77999988b45b472, 0xa7b745108d2c4226, 0xc7a917d3b0aaf74a, 0xc4101b41ea9e3376, 0xf1e73e18a0665ee6, 0xe91bd2045a0b0ad0, 0xefa91de551c01e44, 0x99dbc33360a4f169, 0xbdb1ae6bbe129244, 0xf5fc036c32dc20ff, 0xd9c8c57ffc28a01c, 0x9d8b3fae2cae7827, 0x11f2c4c7d855a7f5, 0xb02f7fa5b2fe41a1, 0x77062c5b1469a369, 0x693fc3d30dac93c5, 0x8d71bac78d245693, 0x4f42e64d08243519, 0x72e6665af38c71c1, 0x9376ddf78f36f4ff, 0x8cfccc555ab22ba5, 0xcd56c8dca22cb74f, 0xaa62bcb13f4f8730, 0xa9398d11d47bba44, 0x894d7f10617684ef, 0x621bbba8c22c635d, 0x47a8275de8ac065d, 0x21b00bda6558c12f, 0xfb7391724b163d10, 0x99dea03365c5bc2b, 0x750a6a50a196ed79, 0xc64bb3cae7b2b8b0, 0x852f7e262c7435c6, 0xa777a56c6a23d801, 0x1877b5d6596a3b7e, 0x045250955884f8d3, 0x1de15e962cd24065, 0xa14346a6be5e94df, 0x0abdfa5be9e9425d, 0x0a0a8b18443c5e78, 0x27416811d47c9e42, 0x6dcb75723d899482, 0xa088d6e51328f4f3, 0xf448fa5ca0600fc4, 0x0d002882933341fa, 0x075cd484cbe5039b, 0xe65636fe352bc224, 0x94a5796df0b6cb05, 0xc938c1b3c5dc4831, 0xd4b8b18e47e5cbb2, 0xac059e807fd2e6b1, 0xdb19e0ea4d3d09eb, 0xbde4e8387fcdd4d9, 0x3ed289b0dc41017e, 0x2428360ec73d7a6e, 0x2c508ce1e2a526f5, 0xf451bcdc69b855bf, 0x27da3d291a29ec47, 0xf9922cc534ff3fe2, 0x6bc75df0fb45fba5, 0x3e9ed8c73d4b2b4a, 0x6c71c14db1235aa7, 0x6fcd09c30d4f47f5, 0xd500eeb25bb0b307, 0xc89de4beb6b373cc, 0x1744fa319c4a66bf, 0x79a5b1934b9506e5, 0x1dcc6304ac4bec17, 0x0973230a0de6a110, 0x8760d138ae4d55ff, 0xdbb84ad252abe9d8, 0xa7bd0a184b386592, 0x7d463bba79d9b72b, 0x21b7334fa4e08742, 0x44b0d1c0d13db4f2, 0xac55f0016d3377d4, 0xbfcd4b80a0a864b5, 0x0a14952a7faf41a1, 0x39a78d7309675405, 0xefc9c4f2cbecf630, 0x7a3301ec82593fdc, 0xbcab6cbfb22cbb86, 0x35c1877126b67118, 0x4ef8fb8393904698, 0x9167bbb7c11ed707, 0xc8b884e30ae16137, 0x2312145cc5a62ebe, 0x4c080edafbde137c, 0xabc0d7fdc059b479, 0xb633e1ca88e3f0ca, 0xa3afd9ad6da63f09, 0x38adba9cd8577462, 0x0e22f6a7fcc3cb30, 0x34e176ff69c73ff7, 0xe4e2e50fff7b1fdf, 0x86b75dd9485e969d, 0xa2471968ff2c06ac, 0x6e31a2e6b9b40fc5, 0x701014cd0f3f9c81, 0x293e85a009a86c70, 0xa65ffe3b15516ab6, 0xa113597e7862ed00, 0x52898f9eda1681b9, 0x2c0d7d3d964f6cd8, 0x6e59da96c9cd5d32, 0x261d90d8cfada9ff, 0x37e2375849b060e9, 0x01bbb9bf59962d1f, 0x6b80fe407c8020be, 0x95df62e19a90cd2a, 0x992205f7a31375e5, 0x94f69652c4d38ed0, 0xf43691f461aa1225, 0x956d02aaee0850b2, 0x9e95c215dc0fa8b8, 0x507c8622985dfc0f, 0xdb5406a10b36e921, 0x1350dbb9a080e925, 0x571920267a307342, 0x646a722496251dba, 0x973c616243a27200, 0xa74c6436df677ea3, 0xe3cf14a17b2bb529, 0xea58bcd86c887db2, 0xbe5dbb71d2041944, 0x7697f10ec1d219e6, 0xdbc3a0b4cce5f4be, 0xd7da9cc9f235210b, 0xee1acb476ded7b43, 0x7ef9b495b0c2ea29, 0xb97b324f4f8a6ccf, 0x5b6e3cee527d9034, 0xa1c5c7b0353eb537, 0xc8ce24482d2d79ad, 0xb52ee28e61c6b7b0, 0xab3d586f8311b645, 0xf3eed0b9be9d2455, 0x974ef0d3133f4b36, 0x4cb9477fe9a357aa, 0xa4f5b4e4ab5802c8, 0x72bdb44b5931b79c, 0x2909c9a065955d1b, 0x6319c942e949976f, 0x0c81df589e248d71, 0x5a2f9b9d517f0268, 0x69626d408a81e872, 0xc7fa18fb48349069, 0x7b56c967c2045129, 0x11d0a32bb21f5618, 0x6c707e9a567fcc43, 0x25d8a1b3e92801a3, 0x4925967c98589582, 0xa13f7e46f04fe29a, 0xaa6744ed1fab0b7f);

#All the relations except the random relation (which is treated
#specially since noise conditions should not make a difference)
my @relations = ("parabolic", "cubic1", "cubic2", "exp2", "exp10", "exp1e10", "sinhalfpi", "sin01pi", "sin02pi", "sin03pi", "sin04pi", "cos07pi", "sin08pi", "sin09pi", "sin10pi", "sin13pi", "cos14pi", "sin16pi", "sin32pi", "varfr5c", "varfr6s", "varfr7s", "2sin2_3", "2sin4_10", "categorical01", "categorical02", "categorical05", "categorical11", "categorical23", "categorical47", "categorical95", "lines1", "lines2", "lines3", "lines4", "lines5", "x", "circle", "lineparab", "spike", "sigmoid", "L", "L_lop", "slsin0811116", "slsin2105110", "slsin2110106", "slsin2833033", "slsin3137037", "almostflat", "23halton", "sin2046pi", "steeppoly");

#The id for the cooresponding entry in the relation list
my @relationids = (1, 10, 11, 20, 21, 22, 30, 31, 32, 33, 34, 37, 38, 39, 40, 43, 44, 46, 62, 85, 86, 87, 92, 94, 150, 151, 152, 153, 154, 155, 156, 161, 162, 163, 164, 165, 180, 190, 200, 250, 300, 350, 351, 408, 421, 423, 428, 431, 10001, 10002, 10003, 10004);

#Check for 64 bit number support (necessary for the random number seeds
unless($Config{use64bitint} eq 'define' || $Config{longsize} >= 8){
   print STDERR "Error: cannot generate commands.  This installation of ".
       "perl does not support 64-bit numbers\n";
   exit(-1);
}

my $seed = shift @seeds;
my $filename = sprintf("experiment1/%05d_random_x000_y000.ser",0);
print "echo \`date\` \": started $filename\" >> experiment1/log\n";
printf "java -jar distr.jar generate -xstd 0 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 4608 -c 15 -seed $seed > $filename\n";
print "echo \`date\` \": finished $filename\" >> experiment1/log\n";

for(my $idx = 0; $idx < @relations; ++$idx){
    my $rel = $relations[$idx];
    my $id = sprintf("%05d",$relationids[$idx]);
    for my $xNoise (0,0.1,0.3){
	my $nameX = sprintf( "x%03d", $xNoise * 100);
	for my $yNoise (0,0.1,0.3){
	    my $nameY = sprintf("y%03d", $yNoise * 100);
	    $seed = shift @seeds;
	    $filename = "experiment1/${id}_${rel}_${nameX}_${nameY}.ser"; 
	    print "echo \`date\` \": started $filename\" >> experiment1/log\n";
	    print "java -jar distr.jar generate ".
		"-xstd $xNoise -ystd $yNoise -rel random ".
		"-nsamp 5,6,7,8,9,10,12,14,19,30,60,100 ".
		"-inst 512 -c 15 -seed $seed > ".
		"$filename\n";
	    print "echo \`date\` \": finished $filename\" >> experiment1/log\n";
	}
    }
}
